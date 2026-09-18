class StatsModel {
  StatsModel({
    required this.livres,
    required this.adherents,
    required this.empruntsEnCours,
    required this.empruntsEnRetard,
    this.auteurs = 0,
    this.livresDisponibles = 0,
    this.topLivres = const [],
    this.topAdherents = const [],
  });

  final int livres;
  final int adherents;
  final int empruntsEnCours;
  final int empruntsEnRetard;
  final int auteurs;
  final int livresDisponibles;
  final List<TopLivreStat> topLivres;
  final List<TopAdherentStat> topAdherents;

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    final topLivresRaw = json['top_livres'];
    final topAdherentsRaw = json['top_adherents'];

    return StatsModel(
      livres: (json['livres'] as num?)?.toInt() ?? 0,
      adherents: (json['adherents'] as num?)?.toInt() ?? 0,
      empruntsEnCours: (json['emprunts_en_cours'] as num?)?.toInt() ?? 0,
      empruntsEnRetard: (json['emprunts_en_retard'] as num?)?.toInt() ?? 0,
      auteurs: (json['auteurs'] as num?)?.toInt() ?? 0,
      livresDisponibles: (json['livres_disponibles'] as num?)?.toInt() ?? 0,
      topLivres: topLivresRaw is List
          ? topLivresRaw
              .whereType<Map>()
              .map((e) => TopLivreStat.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      topAdherents: topAdherentsRaw is List
          ? topAdherentsRaw
              .whereType<Map>()
              .map((e) => TopAdherentStat.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}

class TopLivreStat {
  TopLivreStat({required this.titre, required this.nbEmprunts});

  final String titre;
  final int nbEmprunts;

  factory TopLivreStat.fromJson(Map<String, dynamic> json) {
    return TopLivreStat(
      titre: json['titre'] as String? ?? '',
      nbEmprunts: (json['nb_emprunts'] as num?)?.toInt() ?? 0,
    );
  }
}

class TopAdherentStat {
  TopAdherentStat({required this.nom, required this.nbEmprunts});

  final String nom;
  final int nbEmprunts;

  factory TopAdherentStat.fromJson(Map<String, dynamic> json) {
    return TopAdherentStat(
      nom: json['nom'] as String? ?? '',
      nbEmprunts: (json['nb_emprunts'] as num?)?.toInt() ?? 0,
    );
  }
}
