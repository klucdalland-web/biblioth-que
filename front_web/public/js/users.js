'use strict';

requireAuth();

const tableBody = document.getElementById('users-table-body');
const errorBox = document.getElementById('users-error');
const formNew = document.getElementById('form-new-user');
const formEdit = document.getElementById('form-edit-user');
const modalNew = document.getElementById('modal-new-user');
const modalEdit = document.getElementById('modal-edit-user');
const modalError = document.getElementById('user-modal-error');
const editError = document.getElementById('user-edit-error');

let currentUserId = null;

function showError(el, message) {
  el.textContent = message;
  el.classList.remove('hidden');
}

function hideError(el) {
  el.classList.add('hidden');
}

function escapeHtml(str) {
  return String(str ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function labelRole(role) {
  return role === 'admin' ? 'Administrateur' : 'Bibliothécaire';
}

async function chargerUsers() {
  try {
    hideError(errorBox);
    const users = await apiFetch('/users');
    afficherUsers(users || []);
  } catch (err) {
    showError(errorBox, err.message);
    tableBody.innerHTML =
      '<tr class="empty-row"><td colspan="4">Erreur de chargement.</td></tr>';
  }
}

function ouvrirEdition(id, nom, email, role) {
  hideError(editError);
  document.getElementById('edit-user-id').value = id;
  document.getElementById('edit-user-nom').value = nom;
  document.getElementById('edit-user-email').value = email;
  const roleSelect = document.getElementById('edit-user-role');
  roleSelect.value = role;
  const isSelf = currentUserId && Number(id) === Number(currentUserId);
  roleSelect.disabled = Boolean(isSelf);
  roleSelect.title = isSelf
    ? 'Vous ne pouvez pas modifier votre propre rôle'
    : '';
  modalEdit.classList.remove('hidden');
}

function afficherUsers(users) {
  tableBody.innerHTML = '';

  if (!users.length) {
    tableBody.innerHTML =
      '<tr class="empty-row"><td colspan="4">Aucun utilisateur.</td></tr>';
    return;
  }

  users.forEach((u) => {
    const isSelf = currentUserId && u.id_utilisateur === currentUserId;
    const nomAttr = escapeHtml(u.nom).replace(/'/g, '&#39;');
    const emailAttr = escapeHtml(u.email).replace(/'/g, '&#39;');
    tableBody.insertAdjacentHTML(
      'beforeend',
      `<tr data-id="${u.id_utilisateur}">
        <td>${escapeHtml(u.nom)}${isSelf ? ' <em>(vous)</em>' : ''}</td>
        <td>${escapeHtml(u.email)}</td>
        <td>${escapeHtml(labelRole(u.role))}</td>
        <td class="text-right">
          <button class="btn btn-secondary" type="button"
            onclick="ouvrirEdition(${u.id_utilisateur}, '${nomAttr}', '${emailAttr}', '${escapeHtml(u.role)}')">Modifier</button>
          ${
            isSelf
              ? ''
              : `<button class="btn-danger" type="button" title="Supprimer"
                   onclick="supprimerUser(${u.id_utilisateur})">🗑</button>`
          }
        </td>
      </tr>`
    );
  });
}

formNew.addEventListener('submit', async (e) => {
  e.preventDefault();
  hideError(modalError);

  const btn = formNew.querySelector('button[type="submit"]');
  const label = btn.textContent;
  btn.disabled = true;
  btn.textContent = 'Création...';

  try {
    await apiFetch('/users', {
      method: 'POST',
      body: JSON.stringify({
        nom: document.getElementById('user-nom').value.trim(),
        mail: document.getElementById('user-email').value.trim(),
        password: document.getElementById('user-password').value,
        role: document.getElementById('user-role').value,
      }),
    });
    formNew.reset();
    modalNew.classList.add('hidden');
    chargerUsers();
  } catch (err) {
    showError(modalError, err.message);
  } finally {
    btn.disabled = false;
    btn.textContent = label;
  }
});

formEdit.addEventListener('submit', async (e) => {
  e.preventDefault();
  hideError(editError);

  const id = document.getElementById('edit-user-id').value;
  const btn = formEdit.querySelector('button[type="submit"]');
  const label = btn.textContent;
  btn.disabled = true;
  btn.textContent = 'Enregistrement...';

  try {
    const isSelf = currentUserId && Number(id) === Number(currentUserId);
    const payload = {
      nom: document.getElementById('edit-user-nom').value.trim(),
      mail: document.getElementById('edit-user-email').value.trim(),
    };
    // Ne pas renvoyer un rôle modifié pour son propre compte
    if (!isSelf) {
      payload.role = document.getElementById('edit-user-role').value;
    }

    await apiFetch(`/users/${id}`, {
      method: 'PUT',
      body: JSON.stringify(payload),
    });
    modalEdit.classList.add('hidden');
    chargerUsers();
    loadSidebarUser();
  } catch (err) {
    showError(editError, err.message);
  } finally {
    btn.disabled = false;
    btn.textContent = label;
  }
});

async function supprimerUser(id) {
  if (!confirm('Supprimer cet utilisateur ?')) return;
  try {
    await apiFetch(`/users/${id}`, { method: 'DELETE' });
    chargerUsers();
  } catch (err) {
    showError(errorBox, err.message);
  }
}

requireAdmin().then((user) => {
  if (!user) return;
  currentUserId = user.id_utilisateur;
  chargerUsers();
});
