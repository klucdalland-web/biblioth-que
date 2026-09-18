import 'package:front_mobile/data/models/user_model.dart';

class AuthTokensModel {
  AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn,
    this.user,
  });

  final String accessToken;
  final String refreshToken;
  final String? expiresIn;
  final UserModel? user;

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      expiresIn: json['expiresIn'] as String?,
      user: json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
