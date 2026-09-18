# front_mobile (BiblioGestion)

Application Flutter — architecture **GetX**, branchée sur la même API que `front_web`.

## Lancer

```bash
cd front_mobile
flutter pub get
flutter run
```

## Config API

Éditer `lib/core/constants/api_constants.dart` :

| Cible | `baseUrl` |
|-------|-----------|
| Simulateur iOS | `http://127.0.0.1:3000/api` |
| Émulateur Android | `http://10.0.2.2:3000/api` |
| Téléphone (LAN) | `http://<IP_MAC>:3000/api` |

`deviceKey` doit matcher le backend.

## Fonctionnalités (parité web)

- Login + splash session + refresh JWT
- Dashboard /stats (livres, adhérents, emprunts, retards, tops)
- Livres : liste, recherche, pagination, création, suppression
- Adhérents : liste, recherche, création, suppression
- Emprunts : onglets en cours / retard, création, retour
- Profil : édition + changement de mot de passe + logout
- Users (admin) : liste, création, édition, suppression
