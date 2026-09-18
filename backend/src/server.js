'use strict';

/**
 * Point d'entrée — API + front web (front_web/public)
 */

const http = require('http');

const env = require('./config/env');
const { Router, sendJson, serveStatic } = require('./utils');
const { logger, errorHandler, deviceKey } = require('./middlewares');

const auteursRoutes = require('./routes/auteurs.routes');
const adherentsRoutes = require('./routes/adherents.routes');
const livresRoutes = require('./routes/livres.routes');
const empruntsRoutes = require('./routes/emprunts.routes');
const statsRoutes = require('./routes/stats.routes');
const usersRoutes = require('./routes/users.routes');
const auth = require('./routes/auth.routes');

const app = new Router();

app.use('/api/auteurs', deviceKey, auteursRoutes);
app.use('/api/adherents', deviceKey, adherentsRoutes);
app.use('/api/livres', deviceKey, livresRoutes);
app.use('/api/emprunts', deviceKey, empruntsRoutes);
app.use('/api/stats', deviceKey, statsRoutes);
app.use('/api/users', deviceKey, usersRoutes);
app.use('/api/authentification', deviceKey, auth);

function applyCors(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'Content-Type, Authorization, x-device-key'
  );
  res.setHeader(
    'Access-Control-Allow-Methods',
    'GET, POST, PUT, PATCH, DELETE, OPTIONS'
  );

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return true;
  }
  return false;
}

const server = http.createServer(async (req, res) => {
  try {
    await new Promise((resolve) => logger(req, res, resolve));

    if (applyCors(req, res)) return;

    const matched = await app.handle(req, res);

    if (!matched && !res.writableEnded) {
      const served = serveStatic(req, res);
      if (!served) {
        sendJson(res, 404, null, 'Route introuvable ');
      }
    }
  } catch (err) {
    errorHandler(err, req, res);
  }
});

server.listen(env.port, () => {
  console.log(`API + front : http://localhost:${env.port}  |  http://127.0.0.1:${env.port}`);
  console.log(`Login       : http://127.0.0.1:${env.port}/login.html`);
});

module.exports = server;
