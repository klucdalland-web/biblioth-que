'use strict';

const APP = window.APP_CONFIG || {};
// Relative /api → same host (localhost ou 127.0.0.1)
const API_BASE_URL = APP.API_BASE_URL || '/api';
const DEVICE_KEY = APP.DEVICE_KEY || '';

/** Évite plusieurs refresh en parallèle */
let refreshPromise = null;

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
  if (!getAccessToken() && !getRefreshToken()) {
    window.location.href = 'login.html';
  }
}

function isAuthPublicPath(path) {
  return (
    path.startsWith('/authentification/login') ||
    path.startsWith('/authentification/register') ||
    path.startsWith('/authentification/refresh') ||
    path.startsWith('/authentification/logout')
  );
}

/**
 * Renouvelle l'access token via le refresh token.
 * @returns {Promise<string>} nouvel accessToken
 */
async function refreshAccessToken() {
  if (refreshPromise) return refreshPromise;

  refreshPromise = (async () => {
    const refreshToken = getRefreshToken();
    if (!refreshToken) {
      throw new Error('Session expirée');
    }

    let res;
    try {
      res = await fetch(`${API_BASE_URL}/authentification/refresh`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-device-key': DEVICE_KEY,
        },
        body: JSON.stringify({ refreshToken }),
      });
    } catch {
      throw new Error('Impossible de joindre le serveur pour renouveler la session');
    }

    const json = await res.json().catch(() => ({}));
    if (!res.ok || !json.data?.accessToken) {
      throw new Error(json.message || 'Refresh token invalide ou expiré');
    }

    setTokens({ accessToken: json.data.accessToken });
    return json.data.accessToken;
  })().finally(() => {
    refreshPromise = null;
  });

  return refreshPromise;
}

function redirectToLogin() {
  clearTokens();
  if (!window.location.pathname.endsWith('login.html')) {
    window.location.href = 'login.html';
  }
}

/** Remplit le footer sidebar (nom / rôle) via /authentification/me */
async function loadSidebarUser() {
  const nameEl = document.querySelector('.user-name');
  const roleEl = document.querySelector('.user-role');
  const usersNav = document.querySelector('a[href="users.html"]');

  try {
    const user = await apiFetch('/authentification/me');
    if (nameEl) nameEl.textContent = user.nom || '—';
    if (roleEl) {
      roleEl.textContent =
        user.role === 'admin' ? 'Administrateur' : 'Bibliothécaire';
    }
    if (usersNav) {
      usersNav.style.display = user.role === 'admin' ? '' : 'none';
    }
    return user;
  } catch {
    return null;
  }
}

/** Redirige vers le dashboard si l'utilisateur n'est pas admin */
async function requireAdmin() {
  const user = await loadSidebarUser();
  if (!user || user.role !== 'admin') {
    window.location.href = 'dashboard.html';
    return null;
  }
  return user;
}

/**
 * Wrapper fetch commun vers l'API backend.
 * Sur 401 (token expiré) → refresh puis 1 nouvel essai.
 * @param {string} path
 * @param {RequestInit} [options]
 * @param {{ _retried?: boolean }} [meta]
 */
async function apiFetch(path, options = {}, meta = {}) {
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
      'Impossible de joindre le serveur. Vérifiez que le backend tourne (port 3000).'
    );
  }

  // Access token expiré → refresh + retry une fois
  if (
    res.status === 401 &&
    !meta._retried &&
    !isAuthPublicPath(path) &&
    getRefreshToken()
  ) {
    try {
      await refreshAccessToken();
      return apiFetch(path, options, { _retried: true });
    } catch {
      redirectToLogin();
      throw new Error('Session expirée, veuillez vous reconnecter');
    }
  }

  const json = await res.json().catch(() => ({}));

  if (!res.ok) {
    if (res.status === 401 && !isAuthPublicPath(path)) {
      redirectToLogin();
    }
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

/** Menu hamburger + drawer sidebar sur mobile */
function initMobileNav() {
  const sidebar = document.querySelector('.sidebar');
  const appContent = document.querySelector('.app-content');
  if (!sidebar || !appContent) return;
  if (document.querySelector('.mobile-topbar')) return;

  const topbar = document.createElement('div');
  topbar.className = 'mobile-topbar';
  topbar.innerHTML = `
    <button type="button" class="menu-toggle" aria-label="Ouvrir le menu">
      <span></span><span></span><span></span>
    </button>
    <p class="brand-title">BiblioGestion</p>
  `;
  appContent.insertBefore(topbar, appContent.firstChild);

  const backdrop = document.createElement('div');
  backdrop.className = 'sidebar-backdrop';
  document.body.appendChild(backdrop);

  const brand = sidebar.querySelector('.sidebar-brand');
  if (brand && !sidebar.querySelector('.sidebar-close')) {
    const closeBtn = document.createElement('button');
    closeBtn.type = 'button';
    closeBtn.className = 'sidebar-close';
    closeBtn.setAttribute('aria-label', 'Fermer le menu');
    closeBtn.textContent = '✕';
    brand.appendChild(closeBtn);
    closeBtn.addEventListener('click', closeSidebar);
  }

  function openSidebar() {
    document.body.classList.add('sidebar-open');
  }

  function closeSidebar() {
    document.body.classList.remove('sidebar-open');
  }

  topbar.querySelector('.menu-toggle').addEventListener('click', openSidebar);
  backdrop.addEventListener('click', closeSidebar);

  sidebar.querySelectorAll('.sidebar-nav a').forEach((link) => {
    link.addEventListener('click', closeSidebar);
  });
}

initMobileNav();

