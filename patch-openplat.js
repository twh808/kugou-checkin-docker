// 构建时补丁：让 KuGouMusicApi 的 /login/openplat 把微信 openid 回传给前端
// 用法: node patch-openplat.js <login_openplat.js 路径>
// 覆盖两个分支: 正常(object)分支 与 降级(string)分支
const fs = require('fs');
const path = process.argv[2] || 'module/login_openplat.js';
if (!fs.existsSync(path)) {
  console.error('[patch-openplat] 文件不存在:', path);
  process.exit(1);
}
let s = fs.readFileSync(path, 'utf8');
const before = s;
s = s.replace(
  'response.body.data = { ...response.body.data, ...getToken };',
  'response.body.data = { ...response.body.data, ...getToken, openid: assetsTokenResp.data.openid };'
);
s = s.replace(
  "response.body.data['token'] = getToken;",
  "response.body.data['token'] = getToken; response.body.data['openid'] = assetsTokenResp.data.openid;"
);
if (s === before) {
  console.error('[patch-openplat] 警告: 未匹配到任何替换目标, 文件可能已变化');
  process.exit(2);
}
fs.writeFileSync(path, s);
console.log('[patch-openplat] patched:', path);
