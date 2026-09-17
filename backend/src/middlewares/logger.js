'use strict';

/**
 * Middleware de logging des requêtes HTTP.
 */
function logger(req, res, next) {
  const start = Date.now();

  res.on('finish', () => {
    const ms = Date.now() - start;
    console.log(
      `[${new Date().toISOString()}] ${req.method} ${req.url} → ${res.statusCode} (${ms}ms)`
    );
  });

  return next();
}

module.exports = logger;
