'use strict';

/**
 * Envoie une réponse JSON standardisée :
 * { status: true|false, message: string, data: any }
 */
function sendJson(res, statusCode, data = null, message = null) {
  if (statusCode === 204) {
    res.writeHead(204);
    res.end();
    return;
  }

  const success = statusCode >= 200 && statusCode < 400;

  const payload = {
    status: success,
    message: message ?? (success ? 'Succès' : 'Erreur'),
    data: data ?? null,
  };

  const body = JSON.stringify(payload);
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Content-Length': Buffer.byteLength(body),
  });
  res.end(body);
}

module.exports = sendJson;
