'use strict';

const { AppError } = require('./errorHandler');

/**
 * Valide req[source] selon un schéma simple.
 * source = 'body' | 'query' | 'params'
 */
function validate(schema, source = 'body') {
  return (req, res, next) => {
    const data = req[source] || {};
    const errors = [];

    for (const [field, rules] of Object.entries(schema)) {
      const value = data[field];
      const present = value !== undefined && value !== null && value !== '';

      if (rules.required && !present) {
        errors.push({ field, message: `${field} est requis` });
        continue;
      }
      if (!present) continue;

      if (rules.type === 'string' && typeof value !== 'string') {
        errors.push({ field, message: `${field} doit être une chaîne` });
        continue;
      }

      if (rules.type === 'number') {
        const num = typeof value === 'number' ? value : Number(value);
        if (Number.isNaN(num)) {
          errors.push({ field, message: `${field} doit être un nombre` });
          continue;
        }
        data[field] = num;
        if (rules.min !== undefined && num < rules.min) {
          errors.push({ field, message: `${field} doit être ≥ ${rules.min}` });
        }
        if (rules.max !== undefined && num > rules.max) {
          errors.push({ field, message: `${field} doit être ≤ ${rules.max}` });
        }
        continue;
      }

      if (typeof value === 'string') {
        if (rules.min !== undefined && value.length < rules.min) {
          errors.push({ field, message: `${field} trop court (min ${rules.min})` });
        }
        if (rules.max !== undefined && value.length > rules.max) {
          errors.push({ field, message: `${field} trop long (max ${rules.max})` });
        }
        if (rules.pattern && !rules.pattern.test(value)) {
          errors.push({ field, message: `${field} format invalide` });
        }
        if (rules.enum && !rules.enum.includes(value)) {
          errors.push({
            field,
            message: `${field} doit être l'un de : ${rules.enum.join(', ')}`,
          });
        }
        // Ex. confirmation_mdp: { match: 'password' }
        if (rules.match && value !== data[rules.match]) {
          errors.push({
            field,
            message: `${field} ne correspond pas à ${rules.match}`,
          });
        }
      }
    }

    if (errors.length > 0) {
      throw new AppError('Validation échouée', 422, errors);
    }

    req[source] = data;
    if (typeof next === 'function') return next();
  };
}

module.exports = validate;
