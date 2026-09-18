'use strict';

requireAuth();
loadSidebarUser();

const errorBox = document.getElementById('profile-error');
const successBox = document.getElementById('profile-success');
const formProfile = document.getElementById('form-profile');
const formPassword = document.getElementById('form-password');

function showError(message) {
  successBox.classList.add('hidden');
  errorBox.textContent = message;
  errorBox.classList.remove('hidden');
}

function showSuccess(message) {
  errorBox.classList.add('hidden');
  successBox.textContent = message;
  successBox.classList.remove('hidden');
}

function hideAlerts() {
  errorBox.classList.add('hidden');
  successBox.classList.add('hidden');
}

function labelRole(role) {
  return role === 'admin' ? 'Administrateur' : 'Bibliothécaire';
}

async function chargerProfil() {
  try {
    hideAlerts();
    const user = await apiFetch('/authentification/me');
    document.getElementById('profile-nom').value = user.nom || '';
    document.getElementById('profile-email').value = user.email || '';
    document.getElementById('profile-role').value = labelRole(user.role);
  } catch (err) {
    showError(err.message);
  }
}

formProfile.addEventListener('submit', async (e) => {
  e.preventDefault();
  hideAlerts();

  const btn = document.getElementById('btn-save-profile');
  const label = btn.textContent;
  btn.disabled = true;
  btn.textContent = 'Enregistrement...';

  try {
    await apiFetch('/authentification/me', {
      method: 'PUT',
      body: JSON.stringify({
        nom: document.getElementById('profile-nom').value.trim(),
        mail: document.getElementById('profile-email').value.trim(),
      }),
    });
    showSuccess('Profil mis à jour');
    loadSidebarUser();
  } catch (err) {
    showError(err.message);
  } finally {
    btn.disabled = false;
    btn.textContent = label;
  }
});

formPassword.addEventListener('submit', async (e) => {
  e.preventDefault();
  hideAlerts();

  const password = document.getElementById('password-new').value;
  const confirmation_mdp = document.getElementById('password-confirm').value;

  if (password !== confirmation_mdp) {
    showError('Les mots de passe ne correspondent pas');
    return;
  }

  const btn = document.getElementById('btn-save-password');
  const label = btn.textContent;
  btn.disabled = true;
  btn.textContent = 'Modification...';

  try {
    await apiFetch('/authentification/me/password', {
      method: 'PUT',
      body: JSON.stringify({
        password_actuel: document.getElementById('password-actuel').value,
        password,
        confirmation_mdp,
      }),
    });
    formPassword.reset();
    showSuccess('Mot de passe modifié. Reconnectez-vous.');
    setTimeout(() => {
      clearTokens();
      window.location.href = 'login.html';
    }, 1500);
  } catch (err) {
    showError(err.message);
  } finally {
    btn.disabled = false;
    btn.textContent = label;
  }
});

chargerProfil();
