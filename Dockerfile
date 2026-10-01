FROM node:18-alpine
RUN apk add --no-cache nginx bash curl git
WORKDIR /app

# 克隆两个 API 实例
RUN git clone --depth 1 https://github.com/MakcRe/KuGouMusicApi.git /app/normal && \
    cp -r /app/normal /app/lite && \
    rm -rf /app/normal/.git /app/lite/.git

# Patch: 微信登录时把微信 openid 回传给前端（覆盖两个分支）
RUN cd /app/normal && node -e "
var fs=require('fs');var f='module/login_openplat.js';var s=fs.readFileSync(f,'utf8');
s=s.replace(\"response.body.data = { ...response.body.data, ...getToken };\",\"response.body.data = { ...response.body.data, ...getToken, openid: assetsTokenResp.data.openid };\");
s=s.replace(\"response.body.data['token'] = getToken;\",\"response.body.data['token'] = getToken; response.body.data['openid'] = assetsTokenResp.data.openid;\");
fs.writeFileSync(f,s);" && \
    cd /app/lite && node -e "
var fs=require('fs');var f='module/login_openplat.js';var s=fs.readFileSync(f,'utf8');
s=s.replace(\"response.body.data = { ...response.body.data, ...getToken };\",\"response.body.data = { ...response.body.data, ...getToken, openid: assetsTokenResp.data.openid };\");
s=s.replace(\"response.body.data['token'] = getToken;\",\"response.body.data['token'] = getToken; response.body.data['openid'] = assetsTokenResp.data.openid;\");
fs.writeFileSync(f,s);"

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
