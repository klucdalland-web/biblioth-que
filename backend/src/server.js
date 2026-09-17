'use strict';

/**
 * Point d'entrée — architecture uniquement.
 * Branche : env → router → middlewares → routes
 */

const http = require('http');

const env = require('./config/env');
const { Router, sendJson } = require('./utils');
const { logger, errorHandler, deviceKey } = require('./middlewares');

const auteursRoutes = require('./routes/auteurs.routes');
const adherentsRoutes = require('./routes/adherents.routes');
const livresRoutes = require('./routes/livres.routes');
const empruntsRoutes = require('./routes/emprunts.routes');
const statsRoutes = require('./routes/stats.routes');
const auth = require('./routes/auth.routes');

const app = new Router();

// deviceKey sur toutes les routes /api
app.use('/api/auteurs', deviceKey, auteursRoutes);
app.use('/api/adherents', deviceKey, adherentsRoutes);
app.use('/api/livres', deviceKey, livresRoutes);
app.use('/api/emprunts', deviceKey, empruntsRoutes);
app.use('/api/stats', deviceKey, statsRoutes);
app.use('/api/authentification', deviceKey, auth);

const server = http.createServer(async (req, res) => {
  try {
    await new Promise((resolve) => logger(req, res, resolve));

    const matched = await app.handle(req, res);

    if (!matched && !res.writableEnded) {
      sendJson(res, 404, null, 'Route introuvable ');
    }
  } catch (err) {
    errorHandler(err, req, res);
  }
});

server.listen(env.port, () => {
  console.log(`Serveur démarré sur http://localhost:${env.port}`);
});

module.exports = server;
