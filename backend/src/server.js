'use strict';

/**
 * Point d'entrée — architecture uniquement.
 * Branche : env → router → middlewares → routes
 * (controllers / services / repositories à brancher ensuite)
 */

const http = require('http');

const env = require('./config/env');
const { Router, sendJson } = require('./utils');
const { logger, errorHandler } = require('./middlewares');

// Routes (fichiers prêts — contenu métier à écrire plus tard)
const auteursRoutes = require('./routes/auteurs.routes');
const adherentsRoutes = require('./routes/adherents.routes');
const livresRoutes = require('./routes/livres.routes');
const empruntsRoutes = require('./routes/emprunts.routes');
const statsRoutes = require('./routes/stats.routes');
const auth = require('./routes/auth.routes')

const app = new Router();

// Montage des routes sous /api
app.use('/api/auteurs', auteursRoutes);
app.use('/api/adherents', adherentsRoutes);
app.use('/api/livres', livresRoutes);
app.use('/api/emprunts', empruntsRoutes);
app.use('/api/stats', statsRoutes);


app.use('/api/authentification/', auth)


const server = http.createServer(async(req, res) => {
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