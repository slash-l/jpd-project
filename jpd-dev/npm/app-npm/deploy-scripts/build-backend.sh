#!/bin/bash

echo "🚀 开始构建后端服务..."

cd backend

echo "1. 安装生产依赖..."
npm install --production

echo "2. 打包应用..."
tar -czf ../app-backend-1.0.3.tar.gz .

echo "3. 上传到 Jfrog Artifactory..."
jf rt ping
jf rt upload ../app-backend-1.0.3.tar.gz slash-npm-stage-local/app-npm/app-backend/
echo "✅ 后端构建完成: app-backend-1.0.3.tar.gz"

cd ..
