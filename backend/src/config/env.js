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
loadEnvFile(path.resolve(__dirname, '../../../front_web/.env'));

const hasDatabaseUrl = Boolean(process.env.DATABASE_URL);

const env = {
  port: Number(process.env.PORT) || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',
  isDev: (process.env.NODE_ENV || 'development') !== 'production',
  db: {
    connectionString: process.env.DATABASE_URL || '',
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT) || 5432,
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'postgres',
    // Supabase / cloud Postgres exige SSL en général
    ssl:
      process.env.DB_SSL === 'true' ||
      hasDatabaseUrl ||
      Boolean(process.env.SUPABASE_URL),
  },
  supabase: {
    url: process.env.SUPABASE_URL || '',
    publishableKey: process.env.SUPABASE_PUBLISHABLE_KEY || '',
    secretKey: process.env.SUPABASE_SECRET_KEY || '',
    jwksUrl: process.env.SUPABASE_JWKS_URL || '',
  },
  deviceKey: process.env.DEVICE_KEY || '',
  jwt: {
    secret: process.env.JWT_SECRET || 'dev-secret-change-me',
    expiresIn: process.env.JWT_EXPIRES_IN || '15m',
    refreshExpiresDays: Number(process.env.REFRESH_EXPIRES_DAYS) || 7,
  },
  front: {
    apiBaseUrl: process.env.API_BASE_URL || '/api',
    publicDir: path.resolve(__dirname, '../../../front_web/public'),
  },
};

module.exports = env;
