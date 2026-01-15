#!/bin/bash
#!/bin/bash

# Nexus 仓库的 URL 和认证信息
NEXUS_URL="http://47.117.146.131:8083/service/rest/v1/components?repository=maven-releases"
USERNAME="admin"
PASSWORD="<nexus-admin-password>"

# 基础信息
GROUP_ID="com.mumu.maven.testdata9"
ARTIFACT_ID="testdata9"
VERSION="1.9."

# 创建 100 个不同的 txt 文件
for i in {1..1000}; do
  FILE_NAME="testfile_${i}.txt"
  echo "This is test file number ${i}." > "$FILE_NAME"

  # 上传文件到 Nexus
  echo "Uploading ${FILE_NAME} to Nexus..."

  curl -v -u $USERNAME:$PASSWORD -X POST "$NEXUS_URL" \
    -F "maven2.groupId=$GROUP_ID" \
    -F "maven2.artifactId=$ARTIFACT_ID" \
    -F "maven2.version=$VERSION$i" \
    -F "maven2.asset1=@$FILE_NAME" \
    -F "maven2.asset1.extension=txt"

  # 检查上传是否成功
  if [ $? -eq 0 ]; then
    echo "Successfully uploaded ${FILE_NAME}."
  else
    echo "Failed to upload ${FILE_NAME}."
  fi

  # 删除本地生成的临时文件（可选）
  rm "$FILE_NAME"
done

echo "All files uploaded."


