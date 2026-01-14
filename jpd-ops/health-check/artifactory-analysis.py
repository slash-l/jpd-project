import os
import sys
import gzip
import zipfile
import pandas as pd
from datetime import datetime
import plotly.graph_objs as go
from PIL import Image, ImageDraw, ImageFont
from PyPDF2 import PdfMerger
import img2pdf
import json
import shutil  # Add this import for directory removal

columns = [
    "timestamp", "trace_id", "remote_addr", "username",
    "method", "url", "status", "req_len", "res_len",
    "duration", "user_agent"
]

def safe_extract(zip_ref, target_dir, only_artifactory=False):
    for member in zip_ref.infolist():
        filename = member.filename
        try:
            filename = filename.encode('cp437').decode('utf-8')
        except Exception:
            pass
        if filename.startswith("__MACOSX") or os.path.basename(filename).startswith("._"):
            continue
        if member.is_dir():
            continue
        if only_artifactory and not filename.startswith("artifactory/"):
            continue
        dest_path = os.path.join(target_dir, filename)
        os.makedirs(os.path.dirname(dest_path), exist_ok=True)
        with zip_ref.open(member) as src, open(dest_path, "wb") as dst:
            dst.write(src.read())

def parse_log_line(line):
    if line.startswith("[!dt"):
        line = line.split(']', 1)[-1].strip()
    parts = line.strip().split("|")
    if len(parts) != len(columns):
        return None
    try:
        return {
            "timestamp": pd.to_datetime(parts[0]),
            "method": parts[4],
            "url": parts[5],
            "status": int(parts[6]),
            "req_len": int(parts[7]),
            "res_len": int(parts[8]),
            "duration": float(parts[9]) / 1000
        }
    except:
        return None

def load_logs(log_dir):
    all_data = []
    for root, _, files in os.walk(log_dir):
        files = sorted(files)
        file_set = set(files)
        for fname in files:
            full_path = os.path.join(root, fname)
            print(f"📄 Reading: {full_path}")
            if "artifactory-request-out" in fname:
                continue
            if fname.startswith("artifactory-request") and fname.endswith(".log"):
                open_fn = open
            elif fname.startswith("artifactory-request") and fname.endswith(".log.gz"):
                corresponding_log = fname[:-3]
                if corresponding_log in file_set and os.path.exists(os.path.join(root, corresponding_log)):
                    continue
                open_fn = gzip.open
            else:
                continue
            try:
                with open_fn(full_path, "rt", encoding="utf-8", errors="ignore") as f:
                    for line in f:
                        if "|GET|" in line or "|PUT|" in line or "|POST|" in line:
                            record = parse_log_line(line)
                            if record:
                                all_data.append(record)
            except Exception as e:
                print(f"❌ Failed to parse {full_path}: {e}")
    return pd.DataFrame(all_data)

def mark_upload_type(df):
    df['upload_type'] = df['method'].apply(lambda m: 'Upload' if m in ['PUT', 'POST'] else 'Other')
    return df

def categorize_duration(df):
    df['duration_category'] = pd.cut(
        df['duration'],
        bins=[0, 10, 99, float('inf')],
        labels=['0-10 seconds', '10-99 seconds', '99+ seconds'],
        right=True
    )
    return df

def categorize_language(df):
    def get_language_type(url):
        url_lower = url.lower()
        if ".tar.gz" in url_lower or ".whl" in url_lower:
            return "Python"
        elif ".jar" in url_lower or ".pom" in url_lower:
            return "Maven"
        elif "/docker/" in url_lower:
            return "Docker"
        elif "nuget" in url_lower:
            return "NuGet"
        elif "/npm/" in url_lower or "/api/npm/" in url_lower or url_lower.endswith(".tgz"):
            return "npm"
        else:
            return "Other"
    df['language_type'] = df['url'].apply(get_language_type)
    return df

def analyze(df):
    df['hour'] = df['timestamp'].dt.floor('h')
    df_no_head = df[(df['method'] != 'HEAD') & (df['res_len'] >= 0)]
    traffic = df_no_head.groupby('hour')['res_len'].sum() / (1024 * 1024)
    upload_traffic = df[df['upload_type'] == 'Upload'].groupby('hour')['req_len'].sum() / (1024 * 1024)
    connections = df.groupby('hour').size()
    duration_counts = df.groupby(['hour', 'duration_category'], observed=False).size().unstack(fill_value=0)
    language_counts = df.groupby(['hour', 'language_type'], observed=False).size().unstack(fill_value=0)
    slow_over99 = df[df['duration'] > 99]
    slow_10_99 = df[(df['duration'] > 10) & (df['duration'] <= 99)]
    return traffic, upload_traffic, connections, duration_counts, language_counts, slow_over99.groupby('hour').size(), slow_10_99.groupby('hour').size()

def plot_single_chart(title, x, ys_dict, y_title, image_path):
    fig = go.Figure()
    for name, y in ys_dict.items():
        fig.add_trace(go.Scatter(x=pd.to_datetime(x), y=y, mode='lines+markers', name=name))
    fig.update_layout(
        title=title + " (per Hour)", width=1200, height=720, template="plotly_white",
        hovermode="x unified", font=dict(size=14),
        legend=dict(orientation="h", yanchor="bottom", y=1.02, xanchor="center", x=0.5),
        margin=dict(t=80)
    )
    fig.update_yaxes(title_text=y_title)
    fig.update_xaxes(title_text="Time", tickformat="%Y-%m-%d %H:%M", tickangle=30)
    fig.write_image(image_path, width=1200, height=720, scale=8)

def get_top_slowest_download_lines(df, top_n=10):
    slow_downloads = df[(df['method'] == 'GET') & (df['res_len'] > 0)].copy()
    slow_downloads['speed_kb_per_sec'] = (slow_downloads['res_len'] / 1024) / (slow_downloads['duration'] + 0.001)
    slow_downloads_sorted = slow_downloads.sort_values(by='duration', ascending=False).head(top_n)
    return [
        f"{row['timestamp'].strftime('%Y-%m-%d %H:%M')} | {row['url'][:80]} | {row['duration']:.2f}s | {row['res_len'] / 1024 / 1024:.2f}MB"
        for _, row in slow_downloads_sorted.iterrows()
    ]


def create_summary_page(summary_items, slowest_lines, width, height, output_pdf_path, node_name):
    width = 7200
    title_text = f"Artifactory Health Check - {node_name} - {datetime.now().strftime('%Y-%m-%d')}"

    try:
        font = ImageFont.truetype("Arial.ttf", 64)
    except:
        font = ImageFont.load_default()
    row_height = font.getbbox("A")[3] + 24
    height = max(height, (len(summary_items) + len(slowest_lines)) * row_height + 680)
    img = Image.new("RGB", (width, height), "white")
    draw = ImageDraw.Draw(img)
    label_width = max(draw.textlength(label, font=font) for label, _ in summary_items) + 100
    value_start_x = label_width + 100
    try:
        title_font = ImageFont.truetype("Arial.ttf", 80)
    except:
        title_font = ImageFont.load_default()
    title_width = draw.textlength(title_text, font=title_font)
    title_x = (width - title_width) // 2
    draw.text((title_x, 30), title_text, fill="black", font=title_font)
    y = 130
    for label, value in summary_items:
        label_x = label_width - draw.textlength(label, font=font)
        draw.text((label_x, y), label, fill="black", font=font)
        draw.text((value_start_x, y), value, fill="black", font=font)
        y += row_height
    if slowest_lines:
        y += row_height
        draw.text((40, y), "🐢 Top 10 Slowest Downloads:", fill="black", font=font)
        y += row_height
        for line in slowest_lines:
            draw.text((40, y), line, fill="black", font=font)
            y += row_height
    img.save(output_pdf_path, "PDF")

def format_bytes_gb(mb): return f"{mb / 1000:.1f} GB"
def format_tb(mb): return f"{mb / 1_000_000:.2f} TB"

def parse_system_info(system_info_path):
    if not os.path.isfile(system_info_path):
        return []
    try:
        with open(system_info_path, "r") as f:
            data = json.load(f)
            host_info = data.get("Host Info", {})
            def fmt_bytes(b): return f"{int(b) / (1024 ** 3):.2f} GB"
            def fmt_mb(b): return f"{int(b) / (1024 ** 2):.2f} MB"
            return [
                ("Available Processors", host_info.get("Available Processors", "N/A")),
                ("Heap Memory (Committed)", fmt_bytes(host_info.get("Heap Memory Usage-Commited", 0))),
                ("Heap Memory (Used)", fmt_bytes(host_info.get("Heap Memory Usage-Used", 0))),
                ("Heap Memory (Max)", fmt_bytes(host_info.get("Heap Memory Usage-Max", 0))),
                ("Non-Heap Memory (Used)", fmt_mb(host_info.get("Non-Heap Memory Usage-Used", 0))),
                ("OS Architecture", host_info.get("os.arch", "N/A")),
                ("OS Name", host_info.get("os.name", "N/A")),
                ("OS Version", host_info.get("os.version", "N/A"))
            ]
    except Exception as e:
        print(f"❌ Failed to parse system-info.json: {e}")
        return []

def plot_and_save(traffic, upload_traffic, connections, duration_counts, language_counts, slow_over99, slow_10_99, df, output_dir, node_name):
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_start = df['timestamp'].min()
    log_end = df['timestamp'].max()
    total_minutes = max(1, (log_end - log_start).total_seconds() / 60)
    total_days = max(1, (log_end - log_start).total_seconds() / 86400)
    download_df = df[(df['method'] == 'GET') & (df['res_len'] > 0)]
    upload_df = df[(df['upload_type'] == 'Upload') & (df['req_len'] > 0)]
    total_download_mb = download_df['res_len'].sum() / (1024 * 1024)
    total_upload_mb = upload_df['req_len'].sum() / (1024 * 1024)
    avg_down_per_day = total_download_mb / total_days
    avg_up_per_day = total_upload_mb / total_days

    system_info_path = os.path.join(output_dir, "../system/system-info.json")
    system_info_items = parse_system_info(system_info_path)

    summary_items = [
        ("First Date", log_start.strftime('%Y-%m-%d %H:%M')),
        ("Last Date", log_end.strftime('%Y-%m-%d %H:%M')),
        ("Time Span", str(log_end - log_start)),
        ("Transfer Total Down", format_bytes_gb(total_download_mb)),
        ("Transfer Total Up", format_bytes_gb(total_upload_mb)),
        ("Average Down/Day", format_bytes_gb(avg_down_per_day)),
        ("Average Up/Day", format_bytes_gb(avg_up_per_day)),
        ("Average Down/Month", format_tb(avg_down_per_day * 30)),
        ("Average Up/Month", format_tb(avg_up_per_day * 30)),
        ("Average Down/Year", format_tb(avg_down_per_day * 365)),
        ("Average Up/Year", format_tb(avg_up_per_day * 365)),
        ("Avg Requests/Min", f"{len(df) / total_minutes:.0f}"),
        ("Avg Slow Req/Min", f"{(len(slow_10_99) + len(slow_over99)) / total_minutes:.0f}"),
        ("% Slow Requests", f"{((len(slow_10_99) + len(slow_over99)) / len(df)) * 100:.1f}%")
    ]
    summary_items = system_info_items + summary_items

    slowest_lines = get_top_slowest_download_lines(df)
    
    # Create analysis-result directory in the working directory
    analysis_result_dir = os.path.join(os.path.dirname(output_dir), "analysis-result")
    os.makedirs(analysis_result_dir, exist_ok=True)
    
    # Create a temporary directory for this node's files
    temp_dir = os.path.join(analysis_result_dir, f"temp_{node_name}_{timestamp}")
    os.makedirs(temp_dir, exist_ok=True)
    
    summary_pdf_path = os.path.join(temp_dir, f"_summary_{timestamp}.pdf")
    create_summary_page(summary_items, slowest_lines, 1200, 800, summary_pdf_path, node_name)

    charts = [
        ("Download Traffic (MB)", traffic.index, {"Traffic": traffic}, "MB", os.path.join(temp_dir, f"_traffic_{timestamp}.png")),
        ("Upload Traffic (MB)", upload_traffic.index, {"Upload Traffic": upload_traffic}, "MB", os.path.join(temp_dir, f"_upload_traffic_{timestamp}.png")),
        ("Concurrent Downloads", connections.index, {"Connections": connections}, "Request Count", os.path.join(temp_dir, f"_connections_{timestamp}.png")),
        ("Request Duration Categories", duration_counts.index, dict(duration_counts), "Request Count", os.path.join(temp_dir, f"_duration_{timestamp}.png")),
        ("Download Language Packages", language_counts.index, dict(language_counts), "Request Count", os.path.join(temp_dir, f"_languages_{timestamp}.png")),
        (f"Slow Requests > 99s (count: {slow_over99.sum()})", slow_over99.index, {"Slow >99s": slow_over99}, "Request Count", os.path.join(temp_dir, f"_slowover99_{timestamp}.png")),
        (f"Requests 10–99s (count: {slow_10_99.sum()})", slow_10_99.index, {"10–99s": slow_10_99}, "Request Count", os.path.join(temp_dir, f"_slow_10_99_{timestamp}.png"))
    ]

    pdf_parts = [summary_pdf_path]
    for title, x, ydict, ytitle, image_path in charts:
        if len(ydict) == 0:
            continue
        plot_single_chart(title, x, ydict, ytitle, image_path)
        pdf_page_path = image_path.replace(".png", ".pdf")
        with open(pdf_page_path, "wb") as f:
            f.write(img2pdf.convert(image_path))
        pdf_parts.append(pdf_page_path)
        os.remove(image_path)

    # Save the node's report to the temp directory
    node_pdf = os.path.join(temp_dir, f"artifactory_analysis_{timestamp}.pdf")
    merger = PdfMerger()
    for part in pdf_parts:
        merger.append(part)
    merger.write(node_pdf)
    merger.close()
    for part in pdf_parts:
        os.remove(part)
    
    return node_pdf

def merge_all_node_reports(base_dir):
    from PyPDF2 import PdfMerger
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    analysis_result_dir = os.path.join(base_dir, "analysis-result")
    os.makedirs(analysis_result_dir, exist_ok=True)
    merged_pdf_path = os.path.join(analysis_result_dir, f"artifactory_combined_report_{timestamp}.pdf")

    # First, collect all PDF paths from temp directories
    pdf_paths = []
    for root, dirs, _ in os.walk(analysis_result_dir):
        for dir_name in dirs:
            if dir_name.startswith("temp_"):
                temp_dir = os.path.join(root, dir_name)
                for file in os.listdir(temp_dir):
                    if file.startswith("artifactory_analysis_") and file.endswith(".pdf"):
                        pdf_paths.append(os.path.join(temp_dir, file))

    if not pdf_paths:
        print("⚠️ No node PDF reports found to merge.")
        return

    # Merge PDFs
    merger = PdfMerger()
    for pdf_path in sorted(pdf_paths):
        merger.append(pdf_path)

    # Save the merged PDF
    merger.write(merged_pdf_path)
    merger.close()
    print(f"\n📚 Combined PDF report saved at:\n{os.path.abspath(merged_pdf_path)}")

    # Clean up temp directories and logs_extracted_* directories
    for item in os.listdir(base_dir):
        if item.startswith("logs_extracted_"):
            dir_path = os.path.join(base_dir, item)
            if os.path.isdir(dir_path):
                try:
                    shutil.rmtree(dir_path)
                    print(f"🧹 Cleaned up directory: {dir_path}")
                except Exception as e:
                    print(f"⚠️ Failed to clean up directory {dir_path}: {e}")

    # Clean up temp directories in analysis-result
    for item in os.listdir(analysis_result_dir):
        if item.startswith("temp_"):
            dir_path = os.path.join(analysis_result_dir, item)
            if os.path.isdir(dir_path):
                try:
                    shutil.rmtree(dir_path)
                    print(f"🧹 Cleaned up directory: {dir_path}")
                except Exception as e:
                    print(f"⚠️ Failed to clean up directory {dir_path}: {e}")

def extract_and_process_all_nested_zips(top_zip_path, working_dir):
    print(f"🧩 Extracting main zip: {top_zip_path}")
    top_extract_dir = os.path.join(working_dir, "extracted")
    os.makedirs(top_extract_dir, exist_ok=True)
    with zipfile.ZipFile(top_zip_path, "r") as zip_ref:
        safe_extract(zip_ref, top_extract_dir)
    artifactory_zips = []
    for root, _, files in os.walk(top_extract_dir):
        for file in files:
            if ("artifactory" in file.lower() and file.endswith(".zip") and not file.startswith("._")):
                artifactory_zips.append(os.path.join(root, file))
    if not artifactory_zips:
        print("❌ No Artifactory zip files found.")
        sys.exit(1)
    for art_zip in artifactory_zips:
        node_name = os.path.splitext(os.path.basename(art_zip))[0]
        print(f"\n📦 Processing: {node_name}")
        logs_extract_dir = os.path.join(working_dir, f"logs_extracted_{node_name}")
        os.makedirs(logs_extract_dir, exist_ok=True)
        try:
            with zipfile.ZipFile(art_zip, "r") as zip_ref:
                safe_extract(zip_ref, logs_extract_dir)
        except Exception as e:
            print(f"❌ Failed to extract {art_zip}: {e}")
            continue
        logs_dir = None
        for root, dirs, _ in os.walk(logs_extract_dir):
            if "logs" in dirs:
                logs_dir = os.path.join(root, "logs")
                break
        if not logs_dir:
            print(f"⚠️ Skipping {node_name} - No logs directory found.")
            continue
        df = load_logs(logs_dir)
        if df.empty:
            print(f"⚠️ No valid log entries in {node_name}.")
            continue
        df = categorize_duration(df)
        df = categorize_language(df)
        df = mark_upload_type(df)
        traffic, upload_traffic, connections, duration_counts, language_counts, slow_over99, slow_10_99 = analyze(df)
        plot_and_save(traffic, upload_traffic, connections, duration_counts, language_counts, slow_over99, slow_10_99, df, logs_extract_dir, node_name)
        
        # Clean up temporary logs directory after processing
        try:
            shutil.rmtree(logs_extract_dir)
            print(f"🧹 Cleaned up temporary directory: {logs_extract_dir}")
        except Exception as e:
            print(f"⚠️ Failed to clean up directory {logs_extract_dir}: {e}")
    
    # Clean up the main extracted directory
    try:
        shutil.rmtree(top_extract_dir)
        print(f"🧹 Cleaned up temporary directory: {top_extract_dir}")
    except Exception as e:
        print(f"⚠️ Failed to clean up directory {top_extract_dir}: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("❌ Usage: python artifactory_analysis.py <support-bundle.zip>")
        sys.exit(1)
    zip_input = sys.argv[1]
    if not os.path.isfile(zip_input):
        print(f"❌ File not found: {zip_input}")
        sys.exit(1)
    working_dir = os.path.dirname(os.path.abspath(zip_input))
    extract_and_process_all_nested_zips(zip_input, working_dir)
    merge_all_node_reports(working_dir)

