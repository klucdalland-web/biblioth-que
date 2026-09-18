'use strict';

const path = require('path');
const fs = require('fs');
const env = require('../config/env');

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
};

/**
 * Sert les fichiers de front_web/public + injecte /js/config.js depuis .env
 */
function serveStatic(req, res) {
  const publicDir = env.front.publicDir;
  const url = new URL(req.url || '/', `http://${req.headers.host || 'localhost'}`);
  let pathname = decodeURIComponent(url.pathname);

  if (pathname === '/') pathname = '/login.html';

  // Config front dynamiquement depuis front_web/.env
  if (pathname === '/js/config.js') {
    const body = `'use strict';
window.APP_CONFIG = ${JSON.stringify({
      API_BASE_URL: env.front.apiBaseUrl,
      DEVICE_KEY: env.deviceKey,
    }, null, 2)};
`;
    res.writeHead(200, {
      'Content-Type': MIME['.js'],
      'Cache-Control': 'no-store',
    });
    res.end(body);
    return true;
  }

  const filePath = path.normalize(path.join(publicDir, pathname));
  if (!filePath.startsWith(publicDir)) {
    res.writeHead(403);
    res.end('Forbidden');
    return true;
  }

  if (!fs.existsSync(filePath) || !fs.statSync(filePath).isFile()) {
    return false;
  }

  const ext = path.extname(filePath).toLowerCase();
  const type = MIME[ext] || 'application/octet-stream';
  const data = fs.readFileSync(filePath);

  res.writeHead(200, {
    'Content-Type': type,
    'Content-Length': data.length,
  });
  res.end(data);
  return true;
}

module.exports = serveStatic;
