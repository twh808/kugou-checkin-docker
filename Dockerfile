FROM node:18-alpine
RUN apk add --no-cache nginx bash curl git
WORKDIR /app

# 克隆三个 API 实例（免费版 clone 自 lite，已带 openid 补丁）
RUN git clone --depth 1 https://github.com/MakcRe/KuGouMusicApi.git /app/normal && \
    cp -r /app/normal /app/lite && \
    cp -r /app/lite /app/free && \
    rm -rf /app/normal/.git /app/lite/.git /app/free/.git

# Patch: 微信登录时把微信 openid 回传给前端（独立脚本，避免引号转义问题）
COPY patch-openplat.js /app/patch-openplat.js
RUN cd /app/normal && node /app/patch-openplat.js module/login_openplat.js && \
    cd /app/lite && node /app/patch-openplat.js module/login_openplat.js && \
    cd /app/free && node /app/patch-openplat.js module/login_openplat.js

# 免费版实例使用独立配置（appid=3166 / clientver=24360，来自抓包）
COPY config-free.json /app/free/util/config.json

# 安装生产依赖
RUN cd /app/normal && npm install --production && \
    cd /app/lite   && npm install --production && \
    cd /app/free   && npm install --production

# 复制前端和配置
COPY public/ /usr/share/nginx/html/
COPY nginx/default.conf /etc/nginx/http.d/default.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
