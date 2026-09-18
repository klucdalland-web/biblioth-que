class LivreModel {
  LivreModel({
    required this.id,
    required this.titre,
    required this.idAuteur,
    required this.statut,
    this.anneePublication,
    this.auteurNom,
  });

  final int id;
  final String titre;
  final int idAuteur;
  final String statut;
  final int? anneePublication;
  final String? auteurNom;

  bool get isDisponible => statut == 'disponible';

  factory LivreModel.fromJson(Map<String, dynamic> json) {
    return LivreModel(
      id: (json['id_livre'] as num?)?.toInt() ?? 0,
      titre: json['titre'] as String? ?? '',
      idAuteur: (json['id_auteur'] as num?)?.toInt() ?? 0,
      statut: json['statut'] as String? ?? 'disponible',
      anneePublication: (json['annee_publication'] as num?)?.toInt(),
      auteurNom: json['auteur_nom'] as String?,
    );
  }
}

class PaginatedLivres {
  PaginatedLivres({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.total,
  });

  final List<LivreModel> items;
  final int page;
  final int totalPages;
  final int total;

  factory PaginatedLivres.fromJson(dynamic data) {
    if (data is List) {
      final items = data
          .whereType<Map>()
          .map((e) => LivreModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return PaginatedLivres(
        items: items,
        page: 1,
        totalPages: 1,
        total: items.length,
      );
    }

    final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    final rawItems = map['items'];
    final items = (rawItems is List)
        ? rawItems
            .whereType<Map>()
            .map((e) => LivreModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <LivreModel>[];
    final pagination = map['pagination'] is Map
        ? Map<String, dynamic>.from(map['pagination'] as Map)
        : <String, dynamic>{};

    return PaginatedLivres(
      items: items,
      page: (pagination['page'] as num?)?.toInt() ?? 1,
      totalPages: (pagination['totalPages'] as num?)?.toInt() ?? 1,
      total: (pagination['total'] as num?)?.toInt() ?? items.length,
    );
  }
}
