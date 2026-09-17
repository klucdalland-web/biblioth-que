'use strict';
const { AppError } = require('./errorHandler');
const env = require('../config/env');

function deviceKey(req, res, next) {
    // Node met les headers en minuscules
    const key = req.headers['x-device-key'];
    if (!key) {
        throw new AppError('Header x-device-key manquant', 401);
    }
    if (key !== env.deviceKey) {
        throw new AppError('x-device-key invalide', 401);
    }
    if (typeof next === 'function') return next();
}
module.exports = deviceKey;