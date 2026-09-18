class EmpruntModel {
  EmpruntModel({
    required this.id,
    required this.idAdherent,
    required this.idLivre,
    required this.statut,
    this.adherentNom,
    this.livreTitre,
    this.dateEmprunt,
    this.dateRetourPrevue,
    this.dateRetourReelle,
  });

  final int id;
  final int idAdherent;
  final int idLivre;
  final String statut;
  final String? adherentNom;
  final String? livreTitre;
  final String? dateEmprunt;
  final String? dateRetourPrevue;
  final String? dateRetourReelle;

  bool get canReturn => dateRetourReelle == null || dateRetourReelle!.isEmpty;

  factory EmpruntModel.fromJson(Map<String, dynamic> json) {
    return EmpruntModel(
      id: (json['id_emprunt'] as num?)?.toInt() ?? 0,
      idAdherent: (json['id_adherent'] as num?)?.toInt() ?? 0,
      idLivre: (json['id_livre'] as num?)?.toInt() ?? 0,
      statut: json['statut'] as String? ?? 'en_cours',
      adherentNom: json['adherent_nom'] as String?,
      livreTitre: json['livre_titre'] as String?,
      dateEmprunt: json['date_emprunt']?.toString(),
      dateRetourPrevue: json['date_retour_prevue']?.toString(),
      dateRetourReelle: json['date_retour_reelle']?.toString(),
    );
  }
}
