'use strict';

requireAuth();
loadSidebarUser();

const tableBody = document.getElementById('adherents-table-body');
const form = document.getElementById('form-new-adherent');
const modal = document.getElementById('modal-new-adherent');
const searchInput = document.getElementById('adherents-search');
const errorBox = document.getElementById('adherents-error');

function afficherErreur(message) {
    errorBox.textContent = message;
    errorBox.classList.remove('hidden');
}

function masquerErreur() {
    errorBox.classList.add('hidden');
}

async function chargerAdherents() {
    try {
        masquerErreur();
        const search = searchInput.value.trim();
        const query = search ? `?search=${encodeURIComponent(search)}` : '';
        const adherents = await apiFetch(`/adherents${query}`);
        afficherAdherents(adherents);
    } catch (err) {
        afficherErreur(err.message);
    }
}

function afficherAdherents(adherents) {
    tableBody.innerHTML = '';

    if (adherents.length === 0) {
        tableBody.innerHTML = `<tr class="empty-row"><td colspan="3">Aucun adhérent trouvé.</td></tr>`;
        return;
    }

    adherents.forEach(a => {
        tableBody.insertAdjacentHTML('beforeend', `
      <tr data-id="${a.id_adherent}">
        <td>${a.nom}</td>
        <td>${a.contact}</td>
        <td class="text-right">
          <button class="btn-danger" title="Supprimer" onclick="supprimerAdherent(${a.id_adherent})" type="button">🗑</button>
        </td>
      </tr>
    `);
    });
}

form.addEventListener('submit', async(e) => {
    e.preventDefault();
    masquerErreur();

    const nom = `${document.getElementById('adherent-nom').value} ${document.getElementById('adherent-prenom').value}`.trim();
    const contact = document.getElementById('adherent-email').value;

    try {
        await apiFetch('/adherents', {
            method: 'POST',
            body: JSON.stringify({ nom, contact }),
        });
        form.reset();
        modal.classList.add('hidden');
        chargerAdherents();
    } catch (err) {
        afficherErreur(err.message);
    }
});

async function supprimerAdherent(id) {
    if (!confirm('Supprimer cet adhérent ?')) return;
    try {
        await apiFetch(`/adherents/${id}`, { method: 'DELETE' });
        chargerAdherents();
    } catch (err) {
        afficherErreur(err.message);
    }
}

let debounceTimer;
searchInput.addEventListener('input', () => {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(chargerAdherents, 300);
});

chargerAdherents();