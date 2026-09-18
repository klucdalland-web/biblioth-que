/// Constantes API — alignées sur le backend BiblioGestion.
class ApiConstants {
  ApiConstants._();

  /// Base URL de l'API.
  /// - Simulateur iOS : http://127.0.0.1:3000/api
  /// - Émulateur Android : http://10.0.2.2:3000/api
  /// - Téléphone physique : http://<IP_LAN_DU_MAC>:3000/api
  static const String baseUrl = 'http://192.168.0.65:3000/api';

  /// Doit être identique à DEVICE_KEY du backend / front_web.
  static const String deviceKey = 'ma_cle_device_secrete';

  static const String deviceKeyHeader = 'x-device-key';

  // Auth
  static const String login = '/authentification/login';
  static const String register = '/authentification/register';
  static const String refresh = '/authentification/refresh';
  static const String logout = '/authentification/logout';
  static const String me = '/authentification/me';
  static const String mePassword = '/authentification/me/password';

  // Métier
  static const String auteurs = '/auteurs';
  static const String adherents = '/adherents';
  static const String livres = '/livres';
  static const String emprunts = '/emprunts';
  static const String empruntsRetard = '/emprunts/retard';
  static const String stats = '/stats';
  static const String users = '/users';
}
