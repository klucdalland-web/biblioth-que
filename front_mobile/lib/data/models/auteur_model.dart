class AuteurModel {
  AuteurModel({
    required this.id,
    required this.nom,
    this.nationalite,
  });

  final int id;
  final String nom;
  final String? nationalite;

  factory AuteurModel.fromJson(Map<String, dynamic> json) {
    return AuteurModel(
      id: (json['id_auteur'] as num?)?.toInt() ?? 0,
      nom: json['nom'] as String? ?? '',
      nationalite: json['nationalite'] as String?,
    );
  }
}
