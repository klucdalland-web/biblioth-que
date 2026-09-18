'use strict';

document.addEventListener('DOMContentLoaded', function () {
  const form = document.querySelector('form[method="POST"]');
  const errorBox = document.getElementById('login-error');
  const submitBtn = form.querySelector('button[type="submit"]');

  if (getAccessToken()) {
    window.location.href = 'dashboard.html';
    return;
  }

  function setLoading(loading) {
    submitBtn.disabled = loading;
    submitBtn.classList.toggle('is-loading', loading);
    submitBtn.textContent = loading ? 'Connexion…' : 'Se connecter';
  }

  function showError(message) {
    if (errorBox) {
      errorBox.textContent = message;
      errorBox.classList.remove('hidden');
    } else {
      alert(message);
    }
  }

  function hideError() {
    if (errorBox) {
      errorBox.classList.add('hidden');
      errorBox.textContent = '';
    }
  }

  form.addEventListener('submit', async function (e) {
    e.preventDefault();
    hideError();
    setLoading(true);

    const mail = document.getElementById('agent_id').value.trim();
    const password = document.getElementById('password').value;

    try {
      const data = await apiFetch('/authentification/login', {
        method: 'POST',
        body: JSON.stringify({ mail, password }),
      });

      if (!data || !data.accessToken) {
        throw new Error('Réponse serveur invalide (token manquant)');
      }

      setTokens({
        accessToken: data.accessToken,
        refreshToken: data.refreshToken,
      });

      window.location.href = 'dashboard.html';
    } catch (err) {
      showError(err.message || 'Email ou mot de passe incorrect');
      setLoading(false);
    }
  });
});
