'use strict';

const jwt = require('jsonwebtoken');
const env = require('../config/env');
const { AppError } = require('./errorHandler');

/**
 * Vérifie Authorization: Bearer <accessToken>
 * et place le payload dans req.user.
 */
function authenticate(req, res, next) {
  const header = req.headers.authorization || '';
  const [scheme, token] = header.split(' ');

  if (scheme !== 'Bearer' || !token) {
    throw new AppError(
      'Token manquant. Envoyez Authorization: Bearer <accessToken>',
      401
    );
  }

  try {
    req.user = jwt.verify(token, env.jwt.secret);
  } catch {
    throw new AppError('Token invalide ou expiré', 401);
  }

  if (typeof next === 'function') return next();
}

module.exports = authenticate;
