# 使用官方 Node.js 运行时作为父镜像
FROM node:18-alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制 package.json 和 package-lock.json
COPY package*.json ./

# 配置 JFrog Artifactory Npm 认证 .npmrc 
# 安装依赖
RUN echo -e "email=admin@admin.com\nalways-auth=true\nregistry=https://demo.jfrogchina.com/artifactory/api/npm/slash-npm-virtual/\n//demo.jfrogchina.com/artifactory/api/npm/slash-npm-virtual/:_authToken=cmVmdGtuOjAxOjE3NjE3OTI2NDc6Mm5xclFPbUQ1VkpCbFM3eGFubG9FcUdONDI0" > /root/.npmrc && \
    cat /root/.npmrc && \
    npm install --production && \
    rm -f /root/.npmrc

# 第二阶段：创建轻量级运行时镜像
FROM node:18-alpine AS runtime

# 安装必要的系统工具（用于健康检查等）
RUN apk add --no-cache curl

# 创建非 root 用户运行应用（安全最佳实践）
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# 设置工作目录
WORKDIR /app

# 从构建阶段复制 node_modules
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules

# 复制应用源代码
COPY --chown=nextjs:nodejs . .

# 创建必要的目录并设置权限
RUN mkdir -p logs && \
    chown -R nextjs:nodejs /app

# 切换到非 root 用户
USER nextjs

# 暴露端口
EXPOSE 3001

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3001/ || exit 1

# 设置环境变量
ENV NODE_ENV=production
ENV PORT=3001

# 启动应用
CMD ["node", "server.js"]


