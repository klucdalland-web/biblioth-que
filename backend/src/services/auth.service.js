'use strict';

const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const env = require('../config/env');
const tokensRepo = require('../repositories/tokens.repository');

function signAccessToken(user) {
  return jwt.sign(
    {
      id: user.id_utilisateur,
      email: user.email,
      role: user.role,
    },
    env.jwt.secret,
    { expiresIn: env.jwt.expiresIn }
  );
}

function refreshExpireAt() {
  const d = new Date();
  d.setDate(d.getDate() + env.jwt.refreshExpiresDays);
  return d.toISOString().slice(0, 19).replace('T', ' ');
}

async function issueTokens(user) {
  const accessToken = signAccessToken(user);
  const refreshToken = crypto.randomBytes(40).toString('hex');
  const expire_at = refreshExpireAt();

  await tokensRepo.create({
    id_utilisateur: user.id_utilisateur,
    refresh_token: refreshToken,
    expire_at,
  });

  return {
    accessToken,
    refreshToken,
    expiresIn: env.jwt.expiresIn,
    user: {
      id_utilisateur: user.id_utilisateur,
      nom: user.nom,
      email: user.email,
      role: user.role,
    },
  };
}

module.exports = {
  signAccessToken,
  issueTokens,
};
