'use strict';

const APP = window.APP_CONFIG || {};
const API_BASE_URL = APP.API_BASE_URL || 'http://localhost:3000/api';
const DEVICE_KEY = APP.DEVICE_KEY || '';

function getAccessToken() {
  return localStorage.getItem('accessToken');
}

function getRefreshToken() {
  return localStorage.getItem('refreshToken');
}

function setTokens({ accessToken, refreshToken }) {
  if (accessToken) localStorage.setItem('accessToken', accessToken);
  if (refreshToken) localStorage.setItem('refreshToken', refreshToken);
}

function clearTokens() {
  localStorage.removeItem('accessToken');
  localStorage.removeItem('refreshToken');
  localStorage.removeItem('token');
}

function requireAuth() {
  if (!getAccessToken()) {
    window.location.href = 'login.html';
  }
}

/**
 * Wrapper fetch commun vers l'API backend.
 * @param {string} path - ex. '/livres' ou '/authentification/login'
 * @param {RequestInit} [options]
 * @returns {Promise<any>} data de la réponse JSON
 */
async function apiFetch(path, options = {}) {
  const headers = {
    'Content-Type': 'application/json',
    'x-device-key': DEVICE_KEY,
    ...(options.headers || {}),
  };

  const token = getAccessToken();
  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  let res;
  try {
    res = await fetch(`${API_BASE_URL}${path}`, {
      ...options,
      headers,
    });
  } catch {
    throw new Error(
      'Impossible de joindre le serveur. Vérifiez que le backend tourne sur http://localhost:3000'
    );
  }

  const json = await res.json().catch(() => ({}));

  if (!res.ok) {
    const err = new Error(json.message || `Erreur HTTP ${res.status}`);
    err.status = res.status;
    err.details = json.data;
    throw err;
  }

  return json.data;
}

async function logout() {
  const refreshToken = getRefreshToken();
  try {
    if (refreshToken) {
      await apiFetch('/authentification/logout', {
        method: 'POST',
        body: JSON.stringify({ refreshToken }),
      });
    }
  } catch {
    // on déconnecte quand même côté client
  }
  clearTokens();
  window.location.href = 'login.html';
}
