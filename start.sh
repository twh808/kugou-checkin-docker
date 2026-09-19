#!/bin/bash
set -e

echo "=========================================="
echo "  酷狗账户信息工具 · 容器启动中"
echo "=========================================="

# ---- 普通版 ----
cd /app/normal
[ -f .env ] || cp .env.example .env
grep -q "^platform=" .env && sed -i "s/^platform=.*/platform=''/" .env || echo "platform=''" >> .env
grep -q "^PORT=" .env && sed -i "s/^PORT=.*/PORT=3000/" .env || echo "PORT=3000" >> .env

echo "[1/3] 启动普通版 API (端口 3000)..."
node app.js > /var/log/kugou-normal.log 2>&1 &

# ---- 概念版 ----
cd /app/lite
[ -f .env ] || cp .env.example .env
grep -q "^platform=" .env && sed -i "s/^platform=.*/platform='lite'/" .env || echo "platform='lite'" >> .env
grep -q "^PORT=" .env && sed -i "s/^PORT=.*/PORT=3001/" .env || echo "PORT=3001" >> .env

echo "[2/3] 启动概念版 API (端口 3001)..."
node app.js > /var/log/kugou-lite.log 2>&1 &

# ---- 等待就绪 ----
echo "[3/3] 等待 API 就绪..."
for i in $(seq 1 30); do
    if curl -s http://127.0.0.1:3000 > /dev/null 2>&1 && \
       curl -s http://127.0.0.1:3001 > /dev/null 2>&1; then
        echo "      两个 API 均已就绪"
        break
    fi
    sleep 1
done

echo ""
echo "=========================================="
echo "  启动 Nginx（对外端口 6062，host 模式）"
echo "  前端页面:   http://localhost:6062/"
echo "  普通版 API: http://localhost:6062/api/normal/"
echo "  概念版 API: http://localhost:6062/api/lite/"
echo "=========================================="
echo ""

nginx -g "daemon off;"
