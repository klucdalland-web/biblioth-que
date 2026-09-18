'use strict';

requireAuth();
loadSidebarUser();

const tableBody = document.getElementById('livres-table-body');
const form = document.getElementById('form-new-livre');
const modal = document.getElementById('modal-new-livre');
const searchInput = document.getElementById('livres-search');
const errorBox = document.getElementById('livres-error');
const auteurSelect = document.getElementById('livre-auteur');
const prevBtn = document.getElementById('livres-prev');
const nextBtn = document.getElementById('livres-next');
const pageInfo = document.getElementById('livres-page-info');

let currentPage = 1;
const limit = 10;

function afficherErreur(message) {
  errorBox.textContent = message;
  errorBox.classList.remove('hidden');
}

function masquerErreur() {
  errorBox.classList.add('hidden');
}

function badgeStatut(statut) {
  if (statut === 'disponible') {
    return '<span class="badge badge-success">Disponible</span>';
  }
  return '<span class="badge badge-warning">Emprunté</span>';
}

function escapeHtml(str) {
  return String(str ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

async function chargerAuteurs() {
  const auteurs = await apiFetch('/auteurs');
  auteurSelect.innerHTML = '<option value="">Sélectionner un auteur</option>';
  auteurs.forEach((a) => {
    auteurSelect.insertAdjacentHTML(
      'beforeend',
      `<option value="${a.id_auteur}">${escapeHtml(a.nom)}</option>`
    );
  });
}

async function chargerLivres() {
  try {
    masquerErreur();
    const search = searchInput.value.trim();
    const params = new URLSearchParams({
      page: String(currentPage),
      limit: String(limit),
    });
    if (search) params.set('search', search);

    const data = await apiFetch(`/livres?${params.toString()}`);
    const items = data.items || [];
    const pagination = data.pagination || {
      page: 1,
      totalPages: 1,
      total: items.length,
    };

    afficherLivres(items);
    pageInfo.textContent = `Page ${pagination.page} / ${pagination.totalPages} (${pagination.total})`;
    prevBtn.disabled = pagination.page <= 1;
    nextBtn.disabled = pagination.page >= pagination.totalPages;
  } catch (err) {
    afficherErreur(err.message);
    tableBody.innerHTML =
      '<tr class="empty-row"><td colspan="5">Erreur de chargement.</td></tr>';
  }
}

function afficherLivres(livres) {
  tableBody.innerHTML = '';

  if (livres.length === 0) {
    tableBody.innerHTML =
      '<tr class="empty-row"><td colspan="5">Aucun livre trouvé.</td></tr>';
    return;
  }

  livres.forEach((l) => {
    tableBody.insertAdjacentHTML(
      'beforeend',
      `<tr data-id="${l.id_livre}">
        <td>${escapeHtml(l.titre)}</td>
        <td>${escapeHtml(l.auteur_nom)}</td>
        <td>${l.annee_publication ?? '—'}</td>
        <td>${badgeStatut(l.statut)}</td>
        <td class="text-right">
          <button class="btn-danger" title="Supprimer" type="button"
            onclick="supprimerLivre(${l.id_livre})">🗑</button>
        </td>
      </tr>`
    );
  });
}

form.addEventListener('submit', async (e) => {
  e.preventDefault();
  masquerErreur();

  const titre = document.getElementById('livre-titre').value.trim();
  const id_auteur = Number(document.getElementById('livre-auteur').value);
  const anneeRaw = document.getElementById('livre-annee').value.trim();
  const annee_publication = anneeRaw ? Number(anneeRaw) : undefined;

  if (!id_auteur) {
    afficherErreur('Veuillez sélectionner un auteur');
    return;
  }

  try {
    await apiFetch('/livres', {
      method: 'POST',
      body: JSON.stringify({
        titre,
        id_auteur,
        ...(annee_publication ? { annee_publication } : {}),
      }),
    });
    form.reset();
    modal.classList.add('hidden');
    currentPage = 1;
    chargerLivres();
  } catch (err) {
    afficherErreur(err.message);
  }
});

async function supprimerLivre(id) {
  if (!confirm('Supprimer ce livre ?')) return;
  try {
    await apiFetch(`/livres/${id}`, { method: 'DELETE' });
    chargerLivres();
  } catch (err) {
    afficherErreur(err.message);
  }
}

prevBtn.addEventListener('click', () => {
  if (currentPage > 1) {
    currentPage -= 1;
    chargerLivres();
  }
});

nextBtn.addEventListener('click', () => {
  currentPage += 1;
  chargerLivres();
});

let debounceTimer;
searchInput.addEventListener('input', () => {
  clearTimeout(debounceTimer);
  debounceTimer = setTimeout(() => {
    currentPage = 1;
    chargerLivres();
  }, 300);
});

chargerAuteurs().catch((err) => afficherErreur(err.message));
chargerLivres();
