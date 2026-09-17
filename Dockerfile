FROM node:18-alpine
RUN apk add --no-cache nginx bash curl git
WORKDIR /app

# 克隆两个 API 实例
RUN git clone --depth 1 https://github.com/MakcRe/KuGouMusicApi.git /app/normal && \
    cp -r /app/normal /app/lite && \
    rm -rf /app/normal/.git /app/lite/.git

# 安装生产依赖
RUN cd /app/normal && npm install --production && \
    cd /app/lite   && npm install --production

# 复制前端和配置
COPY public/ /usr/share/nginx/html/
COPY nginx/default.conf /etc/nginx/http.d/default.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
