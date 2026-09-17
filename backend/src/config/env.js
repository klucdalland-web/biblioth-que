'use strict';

const path = require('path');
const fs = require('fs');

/**
 * Charge le fichier .env (KEY=VALUE) sans dépendance externe.
 */
function loadEnvFile(filePath) {
    if (!fs.existsSync(filePath)) return;

    const lines = fs.readFileSync(filePath, 'utf8').split('\n');

    for (const raw of lines) {
        const line = raw.trim();
        if (!line || line.startsWith('#')) continue;

        const eq = line.indexOf('=');
        if (eq === -1) continue;

        const key = line.slice(0, eq).trim();
        let value = line.slice(eq + 1).trim();

        if (
            (value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'"))
        ) {
            value = value.slice(1, -1);
        }

        if (process.env[key] === undefined) {
            process.env[key] = value;
        }
    }
}

loadEnvFile(path.resolve(process.cwd(), '.env'));

const env = {
    port: Number(process.env.PORT) || 3000,
    nodeEnv: process.env.NODE_ENV || 'development',
    isDev: (process.env.NODE_ENV || 'development') !== 'production',
    db: {
        host: process.env.DB_HOST || 'localhost',
        port: Number(process.env.DB_PORT) || 3306,
        user: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD || '',
        database: process.env.DB_NAME || 'bibliotheque',
    },
    deviceKey: process.env.DEVICE_KEY || '',
    jwt: {
        secret: process.env.JWT_SECRET || 'dev-secret-change-me',
        expiresIn: process.env.JWT_EXPIRES_IN || '15m',
        refreshExpiresDays: Number(process.env.REFRESH_EXPIRES_DAYS) || 7,
    },
};

module.exports = env;