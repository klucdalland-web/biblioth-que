'use strict';

requireAuth();
loadSidebarUser();

const errorBox = document.getElementById('dashboard-error');

function showError(message) {
  if (!errorBox) return;
  errorBox.textContent = message;
  errorBox.classList.remove('hidden');
}

function setText(id, value) {
  const el = document.getElementById(id);
  if (el) el.textContent = value ?? '—';
}

async function chargerStats() {
  try {
    const stats = await apiFetch('/stats');

    setText('stat-total-livres', stats.livres);
    setText('stat-total-adherents', stats.adherents);
    setText('stat-emprunts-cours', stats.emprunts_en_cours);
    setText('stat-emprunts-retard', stats.emprunts_en_retard);

    const topLivre = stats.top_livres && stats.top_livres[0];
    setText(
      'stat-livre-populaire',
      topLivre ? `${topLivre.titre} (${topLivre.nb_emprunts})` : 'Aucun'
    );

    const topAdherent = stats.top_adherents && stats.top_adherents[0];
    setText(
      'stat-adherent-actif',
      topAdherent ? `${topAdherent.nom} (${topAdherent.nb_emprunts})` : 'Aucun'
    );
  } catch (err) {
    showError(err.message || 'Impossible de charger les statistiques');
  }
}

chargerStats();
