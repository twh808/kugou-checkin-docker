// 酷狗免费版（yutc/speeder 提现网关）代理服务
// 参数来自抓包: appid=3166, clientver=24360, spec=15, 盐 NVPh5oo715z5DIWAeQlhMDsWXXQV4hwt
const express = require('express');
const crypto = require('crypto');
const app = express();
const PORT = process.env.PORT || 3002;

const SALT = 'NVPh5oo715z5DIWAeQlhMDsWXXQV4hwt';
const APPID = '3166';
const CLIENTVER = '24360';
const SRCAPPID = '2919';
const SPEC = '15';
const BASE = 'https://gateway.kugou.com';
const NETS = ['wifi', '3gnet', '4gnet', '5gnet'];

function md5(s) {
  return crypto.createHash('md5').update(String(s)).digest('hex');
}

function signWeb(params) {
  const s = Object.keys(params).sort().map((k) => k + '=' + params[k]).join('');
  return md5(SALT + s + SALT);
}

function genUA() {
  const net = NETS[Math.floor(Math.random() * NETS.length)];
  return 'Android13-1080-' + CLIENTVER + '-47-0-mobileCallProtocol-' + net + '(13)';
}

function buildParams(q, extra) {
  const mid = q.mid || '';
  const dfid = q.dfid || '';
  const uid = q.uid || '';
  const token = q.token || '';
  const uuid = q.uuid || mid || '';
  const p = {
    srcappid: SRCAPPID,
    clientver: CLIENTVER,
    clienttime: String(Date.now()),
    mid: mid,
    uuid: uuid,
    dfid: dfid,
    appid: APPID,
    userid: uid,
    token: token,
    from: 'client',
    spec: SPEC,
  };
  Object.assign(p, extra || {});
  p.signature = signWeb(p);
  return p;
}

function proxy(req, res, path, extra) {
  const p = buildParams(req.query, extra);
  const url = BASE + path + '?' + new URLSearchParams(p).toString();
  fetch(url, {
    headers: { 'User-Agent': genUA(), 'Connection': 'Keep-Alive' },
    timeout: 8000,
  })
    .then(async (r) => {
      const text = await r.text();
      let json;
      try { json = JSON.parse(text); } catch (e) { json = { raw: text, http: r.status }; }
      res.json(json);
    })
    .catch((e) => {
      res.status(502).json({ status: 0, error: String((e && e.message) || e) });
    });
}

// 免费版用户信息（余额/昵称）
app.get('/user/info', (req, res) => proxy(req, res, '/yutc/speeder/v1/user/info'));
// 免费版提现档位
app.get('/levels', (req, res) => proxy(req, res, '/yutc/speeder/v1/withdraw/levels'));

app.listen(PORT, () => console.log('free-api (yutc/speeder proxy) listening on ' + PORT));
