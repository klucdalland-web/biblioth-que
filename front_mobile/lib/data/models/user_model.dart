class UserModel {
  UserModel({
    required this.id,
    required this.nom,
    required this.email,
    required this.role,
  });

  final int id;
  final String nom;
  final String email;
  final String role;

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id_utilisateur'] as num?)?.toInt() ?? 0,
      nom: json['nom'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'bibliothecaire',
    );
  }

  Map<String, dynamic> toJson() => {
        'id_utilisateur': id,
        'nom': nom,
        'email': email,
        'role': role,
      };
}
