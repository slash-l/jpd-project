#!/bin/bash

echo "🚀 开始构建前端应用..."

cd frontend

echo "1. 安装依赖..."
npm install

echo "2. 执行构建..."
npm run build

echo "3. 打包构建产物..."
tar -czf ../app-frontend-1.0.0.tar.gz -C dist .

echo "4. 上传到 Jfrog Artifactory..."
jf rt ping
jf rt upload ../app-frontend-1.0.0.tar.gz slash-npm-stage-local/app-npm/app-frontend/
echo "✅ 前端构建完成: app-frontend-1.0.0.tar.gz"

cd ..
