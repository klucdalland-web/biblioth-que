/// Résultat d'un repository avec indication d'origine (réseau vs cache).
class RepositoryResult<T> {
  const RepositoryResult(this.data, {this.fromCache = false});

  final T data;

  /// `true` si les données proviennent du cache local (mode hors ligne).
  final bool fromCache;
}
