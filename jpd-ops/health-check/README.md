# Artifactory Health Check Analysis Tool

### Overview
This tool analyzes Artifactory support bundle logs to generate comprehensive health check reports. It processes log files to create visualizations and statistics about system performance, traffic patterns, and potential issues.

### Features
- Extracts and processes nested Artifactory support bundle ZIP files
- Analyzes download/upload traffic patterns
- Tracks request durations and identifies slow requests
- Categorizes requests by package type (Python, Maven, Docker, npm, etc.)
- Generates detailed PDF reports with charts and statistics
- Combines reports from multiple nodes into a single comprehensive report

### Requirements
- Python 3.6+
- Required Python packages:
  - pandas
  - plotly
  - Pillow (PIL)
  - PyPDF2
  - img2pdf

### Installation in a virtual env
# 1. 创建虚拟环境
/opt/homebrew/bin/python3.13 -m venv venv

# 2. 激活虚拟环境
source venv/bin/activate

# 3. 安装依赖包
pip install -r requirements.txt

# 4. 运行脚本
python artifactory-analysis.py <support-bundle.zip>

# 完成后退出虚拟环境
deactivate

python 13.3 ok  
python 11 error  

###

### Installation
```bash
pip install pandas plotly Pillow PyPDF2 img2pdf
```

### Usage
```bash
python artifactory-analysis.py <support-bundle.zip>
```

### Output
The tool generates a PDF report containing:
- System information summary
- Traffic analysis charts
- Request duration statistics
- Package type distribution
- Top 10 slowest downloads
- Combined report for multi-node installations
