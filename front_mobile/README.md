# front_mobile (BiblioGestion)

Application Flutter mobile pour la gestion de bibliothèque — architecture en couches (présentation GetX + domain + data),
branchée sur la même API que `front_web`.

## Prérequis

- Flutter SDK 3.13.3 ou supérieur
- iOS Simulator (macOS) ou Android Emulator
- Backend BiblioGestion en cours d'exécution

## Installation

```bash
cd front_mobile
flutter pub get
flutter run
```

Pour un appareil physique Android, vous devrez peut-être activer le débogage USB et autoriser l'installation d'applications inconnues.

## Tests

```bash
flutter test
```

Les tests unitaires couvrent la couche repository :
- `adherents_repository_test.dart` : 3 tests (succès remote, fallback cache, échec sans cache)
- `livres_repository_test.dart` : 3 tests (succès remote, fallback cache, échec sans cache)
- `auth_repository_test.dart` : 3 tests (login, me, propagation erreur)

Pour exécuter les tests avec couverture de code :
```bash
flutter test --coverage
```

## CI/CD

Le projet utilise GitHub Actions pour l'intégration continue :
- Analyse de code avec `flutter analyze`
- Exécution des tests unitaires
- Build Android APK
- Build iOS (sans signature)

Les workflows sont configurés dans `.github/workflows/ci.yml`.

## Config API

Éditer `lib/core/constants/api_constants.dart` :

| Cible | `baseUrl` |
|-------|-----------|
| Simulateur iOS | `http://127.0.0.1:3000/api` |
| Émulateur Android | `http://10.0.2.2:3000/api` |
| Téléphone (LAN) | `http://<IP_MAC>:3000/api` |

`deviceKey` doit matcher le backend.

## Architecture

L'application suit une architecture en couches (Clean Architecture) avec une séparation claire des responsabilités.

### Structure des répertoires

```
lib/
├── app/                 # Configuration application
│   ├── theme/           # Thème, couleurs, polices
│   ├── routes/          # Routes GetX et navigation
│   ├── bindings/        # Injections de dépendances GetX
│   └── widgets/         # Widgets UI réutilisables (UIKit)
├── core/                # Infrastructure partagée
│   ├── network/         # ApiClient + AuthInterceptor + ApiException
│   ├── storage/         # TokenStorage (secure) + CacheStorage (offline)
│   ├── middleware/      # GetX middlewares (auth, admin)
│   └── constants/       # Constantes API et configuration
├── domain/              # Couche domaine (contrats)
│   ├── repositories/    # Interfaces des repositories
│   └── models/          # RepositoryResult (pattern pour résultats)
├── data/                # Couche données (implémentation)
│   ├── datasources/
│   │   ├── remote/      # Appels Dio uniquement (API)
│   │   └── local/       # Cache GetStorage (offline)
│   ├── models/          # Models DTO (API ↔ Domain)
│   └── repositories/    # Implémentations repositories (orchestrent remote + local)
└── modules/             # Fonctionnalités métier
    ├── auth/            # Authentification (login, register, logout)
    ├── splash/          # Écran de chargement
    ├── login/           # Écran de connexion
    ├── register/        # Écran d'inscription
    ├── shell/           # Navigation principale (bottom nav)
    ├── dashboard/       # Dashboard avec stats
    ├── adherents/       # Gestion des adhérents
    ├── livres/          # Gestion des livres
    ├── emprunts/        # Gestion des emprunts
    ├── users/           # Gestion des utilisateurs (admin)
    └── profile/         # Profil utilisateur
```

### Choix technologiques

- **Gestion d'état** : GetX
  - Framework léger et performant
  - Gestion réactive avec Rx observables
  - Middleware pour la protection des routes
  - Injection de dépendances intégrée
  - Navigation simple et déclarative

- **Architecture** : Clean Architecture avec Repository Pattern
  - Séparation stricte entre présentation, domaine et données
  - Interfaces dans `domain/`, implémentations dans `data/`
  - Testabilité facilitée par l'inversion de dépendances

- **Réseau** : Dio
  - Client HTTP puissant avec interceptors
  - Gestion automatique des tokens JWT
  - Retry sur 401 avec refresh token

- **Stockage local** :
  - `FlutterSecureStorage` : tokens JWT sécurisés
  - `GetStorage` : cache des données (livres, adhérents, stats)

### Flux des données

1. **Vue** → **Controller** (GetX) → **Repository** (interface domain)
2. **RepositoryImpl** appelle le **RemoteDataSource** ; en succès, écrit le **LocalDataSource**
3. En cas d'erreur réseau (`timeout` / `noConnection`), lit le cache local et renvoie `RepositoryResult(fromCache: true)`
4. Le controller expose `isOfflineData` ; la vue affiche `OfflineBanner`

Les repositories **n'utilisent pas Dio directement** — uniquement via les datasources pour respecter la séparation des couches.

### Pattern Repository

Chaque repository orchestre :
- La source de données distante (API) via `RemoteDataSource`
- La source de données locale (cache) via `LocalDataSource`
- La logique de fallback hors ligne
- Les erreurs métier via `ApiException`

Exemple pour la liste des adhérents :
```dart
// 1. Tentative appel API
final data = await _remote.list(search: search);
// 2. En cas de succès, mise en cache
await _local.saveList(data, search: search);
// 3. En cas d'erreur réseau, fallback cache
if (e.isNetwork) {
  final cached = _local.readList(search: search);
  if (cached != null) return RepositoryResult(cached, fromCache: true);
}
```

### Authentification JWT + refresh

- Login/Register → `accessToken` + `refreshToken` stockés dans `FlutterSecureStorage`
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

- Lectures : réseau d'abord, fallback cache si hors ligne
- Mutations (création / suppression) : **online-only** avec message d'erreur utilisateur
- Messages réseau typés (`ApiException`) : délai dépassé, pas de connexion, 401, 5xx

### Qualité de code

`analysis_options.yaml` active `flutter_lints` + règles supplémentaires
(`prefer_single_quotes`, `avoid_print`, `unawaited_futures`, etc.).

## Fonctionnalités

- **Authentification** :
  - Login avec email/mot de passe
  - Inscription (register) pour nouveaux utilisateurs
  - Déconnexion sécurisée
  - Session restaurée automatiquement au démarrage
  - Refresh automatique des tokens JWT

- **Gestion des livres** :
  - Liste avec recherche et pagination
  - Création de nouveaux livres
  - Suppression de livres
  - Indicateur de disponibilité
  - Cache local pour mode hors ligne

- **Gestion des adhérents** :
  - Liste avec recherche
  - Création de nouveaux adhérents
  - Suppression d'adhérents
  - Cache local pour mode hors ligne

- **Gestion des emprunts** :
  - Onglets : en cours / en retard
  - Création d'emprunts
  - Marquage des retours
  - Visualisation des dates d'emprunt et de retour prévu

- **Gestion des utilisateurs (admin)** :
  - Liste des utilisateurs
  - Création de nouveaux utilisateurs
  - Modification de profil et rôle
  - Suppression d'utilisateurs

- **Profil utilisateur** :
  - Édition du nom et email
  - Changement de mot de passe
  - Déconnexion

- **Dashboard** :
  - Statistiques de la bibliothèque
  - Cache local pour mode hors ligne
