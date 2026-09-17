'use strict';

const parseBody = require('../utils/parseBody');
const { AppError } = require('./errorHandler');

/**
 * Parse le JSON de la requête et le met dans req.body.
 * À placer AVANT validate() sur les routes POST/PUT/PATCH.
 */
async function withBody(req, res, next) {
  try {
    req.body = (await parseBody(req)) || {};
  } catch (err) {
    if (err.code === 'INVALID_JSON') {
      throw new AppError(
        "Le corps de la requête n'est pas un JSON valide. Vérifiez le format (guillemets, virgules, accolades).",
        400
      );
    }
    if (err.code === 'PAYLOAD_TOO_LARGE') {
      throw new AppError(
        'Le contenu envoyé est trop volumineux. Réduisez la taille de la requête.',
        413
      );
    }
    throw err;
  }

  if (typeof next === 'function') return next();
}

module.exports = withBody;
