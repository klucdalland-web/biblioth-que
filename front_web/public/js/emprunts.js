'use strict';

requireAuth();
loadSidebarUser();

const tableBody = document.getElementById('emprunts-table-body');
const form = document.getElementById('form-new-emprunt');
const modal = document.getElementById('modal-new-emprunt');
const errorBox = document.getElementById('emprunts-error');
const modalError = document.getElementById('emprunt-modal-error');
const adherentSelect = document.getElementById('emprunt-adherent');
const livreSelect = document.getElementById('emprunt-livre');
const dateRetourInput = document.getElementById('emprunt-date-retour');
const tabEnCours = document.getElementById('tab-en-cours');
const tabEnRetard = document.getElementById('tab-en-retard');

let ongletActif = 'en_cours';

function afficherErreur(el, message) {
  el.textContent = message;
  el.classList.remove('hidden');
}

function masquerErreur(el) {
  el.classList.add('hidden');
}

function escapeHtml(str) {
  return String(str ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function formatDate(value) {
  if (!value) return '—';
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return String(value).slice(0, 10);
  return d.toLocaleDateString('fr-FR');
}

function defaultRetourDate() {
  const d = new Date();
  d.setDate(d.getDate() + 14);
  return d.toISOString().slice(0, 10);
}

function badgeStatut(statut) {
  if (statut === 'en_retard') {
    return '<span class="badge badge-danger">En retard</span>';
  }
  if (statut === 'retourne') {
    return '<span class="badge badge-success">Retourné</span>';
  }
  return '<span class="badge badge-warning">En cours</span>';
}

async function chargerSelects() {
  const [adherents, livresData] = await Promise.all([
    apiFetch('/adherents'),
    apiFetch('/livres?page=1&limit=200'),
  ]);

  adherentSelect.innerHTML = '<option value="">Sélectionner un adhérent</option>';
  (adherents || []).forEach((a) => {
    adherentSelect.insertAdjacentHTML(
      'beforeend',
      `<option value="${a.id_adherent}">${escapeHtml(a.nom)}</option>`
    );
  });

  const livres = (livresData.items || livresData || []).filter(
    (l) => l.statut === 'disponible'
  );
  livreSelect.innerHTML = '<option value="">Sélectionner un livre</option>';
  livres.forEach((l) => {
    livreSelect.insertAdjacentHTML(
      'beforeend',
      `<option value="${l.id_livre}">${escapeHtml(l.titre)}</option>`
    );
  });

  dateRetourInput.value = defaultRetourDate();
}

async function chargerEmprunts() {
  try {
    masquerErreur(errorBox);
    tableBody.innerHTML =
      '<tr class="empty-row"><td colspan="6">Chargement...</td></tr>';

    let emprunts;
    if (ongletActif === 'en_retard') {
      emprunts = await apiFetch('/emprunts/retard');
      emprunts = (emprunts || []).map((e) => ({ ...e, statut: 'en_retard' }));
    } else {
      const all = await apiFetch('/emprunts');
      emprunts = (all || []).filter((e) => !e.date_retour_reelle);
    }

    afficherEmprunts(emprunts);
  } catch (err) {
    afficherErreur(errorBox, err.message);
    tableBody.innerHTML =
      '<tr class="empty-row"><td colspan="6">Erreur de chargement.</td></tr>';
  }
}

function afficherEmprunts(emprunts) {
  tableBody.innerHTML = '';

  if (!emprunts.length) {
    tableBody.innerHTML =
      '<tr class="empty-row"><td colspan="6">Aucun emprunt trouvé.</td></tr>';
    return;
  }

  emprunts.forEach((e) => {
    const peutRetourner = !e.date_retour_reelle;
    tableBody.insertAdjacentHTML(
      'beforeend',
      `<tr data-id="${e.id_emprunt}">
        <td>${escapeHtml(e.adherent_nom)}</td>
        <td>${escapeHtml(e.livre_titre)}</td>
        <td>${formatDate(e.date_emprunt)}</td>
        <td>${formatDate(e.date_retour_prevue)}</td>
        <td>${badgeStatut(e.statut)}</td>
        <td class="text-right">
          ${
            peutRetourner
              ? `<button class="btn btn-secondary" type="button"
                   onclick="retournerEmprunt(${e.id_emprunt})">Retour</button>`
              : '—'
          }
        </td>
      </tr>`
    );
  });
}

function activerOnglet(onglet) {
  ongletActif = onglet;
  tabEnCours.classList.toggle('active', onglet === 'en_cours');
  tabEnRetard.classList.toggle('active', onglet === 'en_retard');
  chargerEmprunts();
}

tabEnCours.addEventListener('click', () => activerOnglet('en_cours'));
tabEnRetard.addEventListener('click', () => activerOnglet('en_retard'));

form.addEventListener('submit', async (e) => {
  e.preventDefault();
  masquerErreur(modalError);
  masquerErreur(errorBox);

  const id_adherent = Number(adherentSelect.value);
  const id_livre = Number(livreSelect.value);
  const date_retour_prevue = dateRetourInput.value;

  if (!id_adherent || !id_livre || !date_retour_prevue) {
    afficherErreur(modalError, 'Veuillez remplir tous les champs');
    return;
  }

  const btn = form.querySelector('button[type="submit"]');
  const label = btn.textContent;
  btn.disabled = true;
  btn.textContent = 'Enregistrement...';

  try {
    await apiFetch('/emprunts', {
      method: 'POST',
      body: JSON.stringify({ id_adherent, id_livre, date_retour_prevue }),
    });
    form.reset();
    dateRetourInput.value = defaultRetourDate();
    modal.classList.add('hidden');
    await chargerSelects();
    await chargerEmprunts();
  } catch (err) {
    afficherErreur(modalError, err.message);
  } finally {
    btn.disabled = false;
    btn.textContent = label;
  }
});

async function retournerEmprunt(id) {
  if (!confirm('Marquer ce livre comme retourné ?')) return;
  try {
    masquerErreur(errorBox);
    await apiFetch(`/emprunts/${id}/retour`, {
      method: 'PUT',
      body: JSON.stringify({}),
    });
    await chargerSelects();
    await chargerEmprunts();
  } catch (err) {
    afficherErreur(errorBox, err.message);
  }
}

chargerSelects().catch((err) => afficherErreur(errorBox, err.message));
chargerEmprunts();
