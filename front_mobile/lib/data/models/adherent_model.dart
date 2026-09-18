class AdherentModel {
  AdherentModel({
    required this.id,
    required this.nom,
    required this.contact,
  });

  final int id;
  final String nom;
  final String contact;

  factory AdherentModel.fromJson(Map<String, dynamic> json) {
    return AdherentModel(
      id: (json['id_adherent'] as num?)?.toInt() ?? 0,
      nom: json['nom'] as String? ?? '',
      contact: json['contact'] as String? ?? '',
    );
  }
}
