# BiblioGestion

Application de gestion d’une bibliothèque de quartier (personnel / bibliothécaires).

| Partie | Techno |
|--------|--------|
| **backend** | Node.js (HTTP natif), **PostgreSQL (Supabase)**, JWT |
| **front_web** | HTML / CSS / JS (servi par le backend) |
| **front_mobile** | Flutter + GetX |

---

## Démo en ligne (Render)

| | |
|--|--|
| **Web** | https://biblioth-que-vo8b.onrender.com/login.html |
| **API** | https://biblioth-que-vo8b.onrender.com/api |
| **Email** | `lucdalland@gmail.com` |
| **Mot de passe** | `Nkodialuc1` |

> Sur le plan Free Render, le premier chargement peut prendre ~30–60 s (cold start).

---

## Prérequis

- **Node.js** ≥ 18
- **npm**
- Un projet **Supabase** (PostgreSQL)
- **Flutter** (SDK) pour l’app mobile — [flutter.dev](https://docs.flutter.dev/get-started/install)

---

## Structure

```
bibliotheque/
├── backend/          # API + serveur des fichiers web
├── front_web/        # Interface web
└── front_mobile/     # Application Flutter
```

---

## 1. Base de données (Supabase / PostgreSQL)

1. Crée un projet sur [Supabase](https://supabase.com)
2. Ouvre **SQL Editor**
3. Exécute dans l’ordre :
   - `backend/src/config/database.sql` (schéma)
   - `backend/src/config/insert.sql` (données de démo, optionnel)

> N’utilise **pas** l’URI « Direct » (`db.xxx.supabase.co`) depuis un Mac sans IPv6  
> → tu auras `ENOTFOUND`. Utilise le **Session pooler**.

---

## 2. Backend

### Installation

```bash
cd backend
npm install
```

### Configuration

```bash
cp .env.example .env
```

Éditer `backend/.env` :

```env
PORT=3000
NODE_ENV=development

# Session pooler (Dashboard → Connect → Session pooler)
# Mot de passe = Database password (Settings → Database), PAS la clé API
DATABASE_URL=postgresql://postgres.PROJECT_REF:YOUR_PASSWORD@aws-1-REGION.pooler.supabase.com:5432/postgres

SUPABASE_URL=https://PROJECT_REF.supabase.co
SUPABASE_PUBLISHABLE_KEY=
SUPABASE_SECRET_KEY=
SUPABASE_JWKS_URL=https://PROJECT_REF.supabase.co/auth/v1/.well-known/jwks.json

DEVICE_KEY=ma_cle_device_secrete

JWT_SECRET=une_longue_chaine_aleatoire_a_generer
JWT_EXPIRES_IN=15m
REFRESH_EXPIRES_DAYS=7
```

Configurer aussi le front (même `DEVICE_KEY`) :

```bash
cp ../front_web/.env.example ../front_web/.env
```

```env
# Local (même origine) : /api
# Prod Render :
API_BASE_URL=https://biblioth-que-vo8b.onrender.com/api
DEVICE_KEY=ma_cle_device_secrete
```

> `DEVICE_KEY` doit être **identique** côté backend et front.  
> Ne commit **jamais** `backend/.env` (secrets).

### Lancer

```bash
cd backend
npm run dev
```

| URL | Description |
|-----|-------------|
| http://127.0.0.1:3000/login.html | Interface web |
| http://127.0.0.1:3000/api/... | API REST |

Sur le réseau local (même Wi‑Fi) :

```text
http://<IP_DU_MAC>:3000
```

---

## 3. Front web

Rien à installer : le backend **sert** déjà `front_web/public`.

1. Lancer le backend (`npm run dev`)
2. Ouvrir http://127.0.0.1:3000/login.html

### Compte de base (déjà créé)

| Champ | Valeur |
|-------|--------|
| Email | `lucdalland@gmail.com` |
| Mot de passe | `Nkodialuc1` |

Connexion : https://biblioth-que-vo8b.onrender.com/login.html  
(ou en local : http://127.0.0.1:3000/login.html)

### Créer un autre compte

```bash
curl -X POST http://127.0.0.1:3000/api/authentification/register \
  -H "Content-Type: application/json" \
  -H "x-device-key: ma_cle_device_secrete" \
  -d '{"nom":"Alice","mail":"alice@mail.com","password":"azerty123","confirmation_mdp":"azerty123"}'
```

Pour rendre un utilisateur **admin** (SQL Editor Supabase) :

```sql
UPDATE utilisateurs SET role = 'admin' WHERE email = 'lucdalland@gmail.com';
```

Puis se reconnecter (le rôle est dans le JWT).

---

## 4. Front mobile (Flutter)

L’app mobile **n’est pas déployée sur Render**. Elle tourne sur un simulateur / téléphone et appelle l’API (locale ou Render).

### Lancer

```bash
cd front_mobile
flutter pub get
flutter devices          # voir simulateurs / téléphones branchés
flutter run
```

Puis se connecter avec :

| Champ | Valeur |
|-------|--------|
| Email | `lucdalland@gmail.com` |
| Mot de passe | `Nkodialuc1` |

### Config API

Fichier : `front_mobile/lib/core/constants/api_constants.dart`

**Prod (Render)** — déjà configuré :

```dart
static const String baseUrl = "https://biblioth-que-vo8b.onrender.com/api";
static const String deviceKey = "ma_cle_device_secrete";
```

`deviceKey` doit être **identique** à `DEVICE_KEY` du backend (Render / `.env`).

| Cible | `baseUrl` |
|-------|-----------|
| **Prod (Render)** | `https://biblioth-que-vo8b.onrender.com/api` |
| Simulateur iOS (API locale) | `http://127.0.0.1:3000/api` |
| Émulateur Android (API locale) | `http://10.0.2.2:3000/api` |
| Téléphone physique (API locale, même Wi‑Fi) | `http://<IP_LAN_DU_MAC>:3000/api` |

Pour basculer en local : change `baseUrl` dans le tableau ci-dessus, puis relance `flutter run`.

### Headers envoyés par l’app

- `x-device-key: ma_cle_device_secrete`
- `Authorization: Bearer <accessToken>` (après login)

### Fonctionnalités (parité web)

- Login + splash session + refresh JWT
- Dashboard /stats
- Livres, adhérents, emprunts (création, retour, retards)
- Profil (édition + mot de passe + logout)
- Users (admin uniquement)

### Build APK (Android, optionnel)

```bash
cd front_mobile
flutter build apk --release
```

Fichier généré : `front_mobile/build/app/outputs/flutter-apk/app-release.apk`

### À retenir

| Situation | Action |
|-----------|--------|
| Tester contre **Render** | Garder l’URL prod dans `api_constants.dart` |
| Premier appel lent / timeout | Cold start Free (~30–60 s) → réessayer |
| Développer avec API **locale** | Changer `baseUrl` (voir tableau) + `npm run dev` dans `backend` |
| Publier Play Store / App Store | Build release (APK / IPA) — **pas** lié à Render |

---

## 5. Déploiement (Render)

| Élément | Où |
|---------|-----|
| Base PostgreSQL | **Supabase** |
| API Node + front web | **Render** → https://biblioth-que-vo8b.onrender.com |
| App mobile Flutter | **Pas sur Render** — tourne sur device, pointe vers l’API |

Sur Render :

| Champ | Valeur |
|-------|--------|
| Root Directory | `backend` |
| Build Command | `npm install` |
| Start Command | `npm start` |

Variables d’env à coller : `DATABASE_URL` (pooler), `DEVICE_KEY`, `JWT_SECRET`, `API_BASE_URL=/api`, etc.  
(Ne pas définir `PORT` — Render le gère.)

Compte de démo : `lucdalland@gmail.com` / `Nkodialuc1`  
Web : https://biblioth-que-vo8b.onrender.com/login.html

---

## API — rappel rapide

```http
x-device-key: ma_cle_device_secrete
Authorization: Bearer <accessToken>
```

| Ressource | Préfixe |
|-----------|---------|
| Auth | `/api/authentification` |
| Auteurs | `/api/auteurs` |
| Adhérents | `/api/adherents` |
| Livres | `/api/livres` |
| Emprunts | `/api/emprunts` |
| Stats | `/api/stats` |
| Users (admin) | `/api/users` |

Collection Postman : `backend/postman/BiblioGestion.postman_collection.json`

---

## Scripts utiles

```bash
# Backend local
cd backend && npm run dev

# Mobile
cd front_mobile && flutter pub get && flutter run
```

Réimporter le schéma (⚠️ efface les tables) : coller `database.sql` dans le SQL Editor Supabase.

---

## Dépannage

| Problème | Piste |
|----------|--------|
| `ENOTFOUND db.xxx.supabase.co` | Utiliser l’URI **Session pooler**, pas Direct |
| `password authentication failed` | Mauvais mot de passe **Database** (pas la clé API) |
| `EADDRINUSE :::3000` | `lsof -i :3000` puis tuer le PID |
| `Token invalide ou expiré` | Refresh auto côté front ; sinon reconnecte-toi |
| `Clé device invalide` | Même `DEVICE_KEY` backend, `front_web` et `api_constants.dart` |
| Login OK en local, KO sur téléphone | IP LAN du Mac, pas `localhost` |
| Mobile timeout vers Render | Cold start Free → attendre / réessayer |
| Mobile KO en local (Android) | Utiliser `http://10.0.2.2:3000/api`, pas `127.0.0.1` |
| Page Utilisateurs invisible | Compte non admin → `UPDATE utilisateurs SET role = 'admin' ...` |
| Push GitHub bloqué (secrets) | Ne jamais committer `.env` |

---

## Auteur / contexte

Projet bibliothèque — Akieni Academy.
