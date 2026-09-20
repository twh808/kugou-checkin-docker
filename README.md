# 酷狗账户信息工具（kugoulogin）

基于 [KuGouMusicApi](https://github.com/MakcRe/KuGouMusicApi) 双实例 + Nginx 反代的酷狗账户信息查询工具。支持 **普通版 / 概念版** 两种平台，支持 **验证码登录** 和 **扫码登录**，登录后即可查看并复制账户信息（会员、歌单等），一键复制 `mid#dfid#uid#token` 拼接串。

## 镜像信息

| 项目 | 说明 |
|---|---|
| 镜像 | `twh808/kugoulogin:latest` |
| 支持架构 | linux/amd64、linux/arm64 |
| Docker Hub | https://hub.docker.com/r/twh808/kugoulogin |
| 容器内服务端口 | Nginx `6062`（普通版 API `3000`、概念版 API `3001` 仅容器内） |

## 快速安装（docker run）

### 方式一：Host 网络模式（推荐，不占用其他端口）

容器直接使用宿主机网络栈，Nginx 直接监听宿主机 **6062** 端口，不占用 80 / 443 / 8080 等常用端口。

```bash
docker run -d \
  --name kugou-checkin \
  --network host \
  --restart unless-stopped \
  twh808/kugoulogin:latest
```

### 方式二：桥接网络模式（标准 Docker 网络）

通过端口映射暴露服务，适合不支持 host 模式的环境（如 Docker Desktop for Mac/Windows）。

```bash
docker run -d \
  --name kugou-checkin \
  -p 6062:6062 \
  --restart unless-stopped \
  twh808/kugoulogin:latest
```

启动后浏览器访问：`http://机器IP:6062`

- 页面顶部可切换 普通版 / 概念版（两种平台的登录 Token 不通用，切换后需重新登录）
- 支持 **验证码登录**（手机号 + 短信验证码）和 **扫码登录**（酷狗音乐 App 扫码）
- 登录成功后显示账户信息卡片，支持逐行复制、「复制全部（文本）」、「复制全部（JSON）」、「复制拼接串」（`mid#dfid#uid#token`）

## 其他安装方式

**docker compose（Host 网络模式）**

```bash
mkdir kugou-checkin && cd kugou-checkin
# 将仓库根目录的 docker-compose.yml 保存到本目录
docker compose up -d
```

compose 文件已使用 `network_mode: host`，无需端口映射。

**docker compose（桥接网络模式）**

将 `docker-compose.yml` 中的 `network_mode: host` 替换为：

```yaml
ports:
  - "6062:6062"
```

**Portainer 图形界面**

1. Images → Pull image → 输入 `twh808/kugoulogin:latest` → Pull the image
2. Containers → Add container
   - Name: `kugou-checkin`
   - Image: `twh808/kugoulogin:latest`
   - Network:
     - Host 模式：选 **Host**，不配置端口映射
     - 桥接模式：选 **Bridge**，Network ports 填 `6062` → `6062`
   - Restart policy: `Unless stopped`
3. Deploy the container

## 更新镜像

- 改前端页面：编辑 `public/index.html` 并提交，push 自动触发构建
- 更新酷狗 API 源码：进入仓库 Actions → **Build Multi-Arch Docker Image** → **Run workflow**（构建时会自动拉取最新源码）
- 更新服务器容器：

```bash
docker pull twh808/kugoulogin:latest
docker restart kugou-checkin
# 或使用 compose: docker compose up -d
```

## 排障速查

| 现象 | 处理 |
|---|---|
| 页面 502 Bad Gateway | `docker logs kugou-checkin`；`docker exec kugou-checkin cat /var/log/kugou-normal.log`（普通版）/ `kugou-lite.log`（概念版） |
| 端口被占用 | host 模式下容器占用宿主机 6062，先确认 `ss -tlnp \| grep 6062` 是否空闲 |
| 发送验证码报错 | 酷狗接口可能要求滑块验证，请查看页面提示的原始错误信息 |
| 扫码登录无响应 | 确认网络能访问酷狗 API，二维码有效期约 2 分钟，过期需重新生成 |

## 本地构建（可选）

```bash
docker build -t twh808/kugoulogin .
```
