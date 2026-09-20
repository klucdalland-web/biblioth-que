# front_mobile (BiblioGestion)

Application Flutter — architecture en couches (présentation GetX + domain + data),
branchée sur la même API que `front_web`.

## Lancer

```bash
cd front_mobile
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```

Au moins trois tests unitaires couvrent la couche repository (livres, adhérents, auth).

## Config API

Éditer `lib/core/constants/api_constants.dart` :

| Cible | `baseUrl` |
|-------|-----------|
| Simulateur iOS | `http://127.0.0.1:3000/api` |
| Émulateur Android | `http://10.0.2.2:3000/api` |
| Téléphone (LAN) | `http://<IP_MAC>:3000/api` |

`deviceKey` doit matcher le backend.

## Architecture

```
lib/
├── app/                 # Thème, routes, widgets UI
├── core/                # Réseau, stockage, constantes, middlewares
│   ├── network/         # ApiClient + AuthInterceptor + ApiException
│   └── storage/         # TokenStorage (secure) + CacheStorage (offline)
├── domain/              # Contrats (interfaces repository) + RepositoryResult
├── data/
│   ├── datasources/
│   │   ├── remote/      # Appels Dio uniquement
│   │   └── local/       # Cache GetStorage
│   ├── models/
│   └── repositories/    # Implémentations (orchestrent remote + local)
└── modules/             # Présentation GetX (controllers + views)
```

### Flux des données

1. **Vue** → **Controller** (GetX) → **Repository** (interface domain)
2. **RepositoryImpl** appelle le **RemoteDataSource** ; en succès, écrit le **LocalDataSource**
3. En cas d’erreur réseau (`timeout` / `noConnection`), lit le cache local et renvoie `RepositoryResult(fromCache: true)`
4. Le controller expose `isOfflineData` ; la vue affiche `OfflineBanner`

Les repositories **n’utilisent pas Dio directement** — uniquement via les datasources.

### Authentification JWT + refresh

- Login → `accessToken` + `refreshToken` stockés dans `FlutterSecureStorage`
- `AuthInterceptor` (classe dédiée) :
  - attache `Authorization: Bearer …` sur les requêtes non publiques
  - sur **401**, refresh single-flight via `/authentification/refresh`, puis retry
  - si le refresh échoue → clear session
- La navigation login/logout est gérée par les **vues** (pas le controller)

### Cache & mode hors ligne

| Données | Cache | TTL |
|---------|-------|-----|
| Liste livres (par page/recherche) | GetStorage | 24 h |
| Auteurs | GetStorage | 24 h |
| Adhérents | GetStorage | 24 h |
| Stats dashboard | GetStorage | 12 h |

- Lectures : réseau d’abord, fallback cache si hors ligne
- Mutations (création / suppression) : **online-only** avec message d’erreur utilisateur
- Messages réseau typés (`ApiException`) : délai dépassé, pas de connexion, 401, 5xx

### Qualité de code

`analysis_options.yaml` active `flutter_lints` + règles supplémentaires
(`prefer_single_quotes`, `avoid_print`, `unawaited_futures`, etc.).

## Fonctionnalités

- Login + splash session + refresh JWT (`AuthInterceptor`)
- Dashboard /stats (cache offline)
- Livres : liste, recherche, pagination, création, suppression (+ cache)
- Adhérents : liste, recherche, création, suppression (+ cache)
- Emprunts : onglets en cours / retard, création, retour
- Profil : édition + changement de mot de passe + logout
- Users (admin) : liste, création, édition, suppression
