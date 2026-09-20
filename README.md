# 酷狗账户信息工具（kugoulogin）

基于 [KuGouMusicApi](https://github.com/MakcRe/KuGouMusicApi) 双实例 + Nginx 反代的酷狗账户信息查询工具。支持 **普通版 / 概念版** 两种平台，手机号 + 验证码登录后即可查看并复制账户信息（会员、歌单等），一键复制 `mid#dfid#uid#token` 拼接串。

## 镜像信息

| 项目 | 说明 |
|---|---|
| 镜像 | `twh808/kugoulogin:latest` |
| 支持架构 | linux/amd64、linux/arm64 |
| Docker Hub | https://hub.docker.com/r/twh808/kugoulogin |
| 容器内服务端口 | Nginx `6062`（普通版 API `3000`、概念版 API `3001` 仅容器内） |

## 快速安装（docker run，host 网络模式）

容器使用 host 网络模式，Nginx 直接监听宿主机 **6062** 端口，不占用 80 / 443 / 8080 等常用端口。

```bash
docker run -d \
  --name kugou-checkin \
  --network host \
  --restart unless-stopped \
  twh808/kugoulogin:latest
```

启动后浏览器访问：`http://机器IP:6062`

- 页面顶部可切换 普通版 / 概念版（两种平台的登录 Token 不通用，切换后需重新登录）
- 输入手机号 → 发送验证码 → 输入验证码 → 登录
- 登录成功后显示账户信息卡片，支持逐行复制、「复制全部（文本）」、「复制全部（JSON）」、「复制拼接串」（`mid#dfid#uid#token`）

## 其他安装方式

**docker compose（host 网络模式）**

```bash
mkdir kugou-checkin && cd kugou-checkin
# 将仓库根目录的 docker-compose.yml 保存到本目录
docker compose up -d
```

compose 文件已使用 `network_mode: host`，无需端口映射。

**Portainer 图形界面（host 网络模式）**

1. Images → Pull image → 输入 `twh808/kugoulogin:latest` → Pull the image
2. Containers → Add container
   - Name: `kugou-checkin`
   - Image: `twh808/kugoulogin:latest`
   - Network: 选择 **Host**（不要选 bridge，不要配置端口映射）
   - Restart policy: `Unless stopped`
3. Deploy the container

> 注意：host 模式下不需要也不能配置端口映射，容器直接使用宿主机网络栈，占用 6062 端口。

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
| 端口被占用 | host 模式下容器占用宿主机 6062，先确认 `ss -tlnp | grep 6062` 是否空闲 |
| 发送验证码报错 | 酷狗接口可能要求滑块验证，请查看页面提示的原始错误信息 |

## 本地构建（可选）

```bash
docker build -t twh808/kugoulogin .
```
