'use strict';

const { AppError } = require('./errorHandler');

/**
 * À placer après authenticate.
 * Autorise uniquement les utilisateurs avec role === 'admin'.
 */
function requireAdmin(req, res, next) {
  if (!req.user || req.user.role !== 'admin') {
    throw new AppError(
      'Accès réservé aux administrateurs',
      403
    );
  }
  if (typeof next === 'function') return next();
}

module.exports = requireAdmin;
