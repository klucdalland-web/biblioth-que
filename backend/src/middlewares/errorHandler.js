'use strict';

const sendJson = require('../utils/sendJson');
const env = require('../config/env');

class AppError extends Error {
  constructor(message, statusCode = 400, details) {
    super(message);
    this.name = 'AppError';
    this.statusCode = statusCode;
    this.details = details;
  }
}

function errorHandler(err, req, res) {
  const statusCode = err.statusCode || 500;
  const data = err.details ?? (env.isDev && statusCode >= 500 ? { stack: err.stack } : null);

  if (!res.writableEnded) {
    sendJson(res, statusCode, data, err.message || 'Erreur interne du serveur');
  }

  if (statusCode >= 500) {
    console.error(err);
  }
}

function asyncHandler(fn) {
  return async (req, res) => {
    try {
      await fn(req, res);
    } catch (err) {
      errorHandler(err, req, res);
    }
  };
}

module.exports = {
  AppError,
  errorHandler,
  asyncHandler,
};
