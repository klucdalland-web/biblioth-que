'use strict';

/**
 * Lit et parse le corps JSON d'une requête HTTP.
 */
function parseBody(req, options = {}) {
  const maxBytes = options.maxBytes ?? 1_000_000;

  return new Promise((resolve, reject) => {
    const chunks = [];
    let size = 0;

    req.on('data', (chunk) => {
      size += chunk.length;
      if (size > maxBytes) {
        const err = new Error('PAYLOAD_TOO_LARGE');
        err.statusCode = 413;
        err.code = 'PAYLOAD_TOO_LARGE';
        reject(err);
        req.destroy();
        return;
      }
      chunks.push(chunk);
    });

    req.on('end', () => {
      if (chunks.length === 0) {
        resolve(null);
        return;
      }

      try {
        resolve(JSON.parse(Buffer.concat(chunks).toString('utf8')));
      } catch {
        const err = new Error('INVALID_JSON');
        err.statusCode = 400;
        err.code = 'INVALID_JSON';
        reject(err);
      }
    });

    req.on('error', reject);
  });
}

module.exports = parseBody;
