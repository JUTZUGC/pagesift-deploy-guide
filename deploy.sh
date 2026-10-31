#!/usr/bin/env bash
set -euo pipefail
# pagesift 一键部署脚本（第三方指南）——按官方文档封装
# 官方文档：https://github.com/YOLOW92/pagesift#readme
# 更新日期：2026-10-31
# 类型：docker
cd "$(dirname "${BASH_SOURCE[0]}")"

command -v git >/dev/null 2>&1 || { echo "需要先安装 Git"; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "需要先安装 Docker"; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "需要 Docker Compose v2（docker compose 子命令）"; exit 1; }

mkdir -p .download
cd .download

docker run -d --name pagesift -p 3002:3002 -v pagesift-data:/data -e PAGESIFT_API_KEYS=sk-test ghcr.io/yolow92/pagesift:0.81.4
sleep 3
curl -s http://127.0.0.1:3002/r/https://example.com -H "Authorization: Bearer sk-test"
echo "已启动：服务在 3002 端口，返回内容应为该页面的 Markdown"

echo ""
if command -v curl >/dev/null 2>&1; then
  echo "等待服务启动：http://127.0.0.1:3002"
  ready=0
  for _ in $(seq 1 30); do
    if curl -sS -o /dev/null "http://127.0.0.1:3002" 2>/dev/null; then ready=1; break; fi
    sleep 2
  done
  if [ "$ready" = "1" ]; then
    echo "服务已就绪"
  else
    echo "警告：60 秒内未探测到 http://127.0.0.1:3002，请手动打开确认或查看日志"
    exit 1
  fi
else
  echo "未检测到 curl，跳过启动探测；请手动访问 http://127.0.0.1:3002 确认"
fi
echo "部署完成，浏览器访问 http://127.0.0.1:3002"
echo "若结果异常或需要改配置，请参考官方文档：https://github.com/YOLOW92/pagesift#readme"
