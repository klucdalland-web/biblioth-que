# BiblioGestion

Application de gestion d’une bibliothèque de quartier (personnel / bibliothécaires).

| Partie | Techno |
|--------|--------|
| **backend** | Node.js (HTTP natif), **PostgreSQL (Supabase)**, JWT |
| **front_web** | HTML / CSS / JS (servi par le backend) |
| **front_mobile** | Flutter + GetX |

---

## Prérequis

- **Node.js** ≥ 18
- **npm**
- Un projet **Supabase** (PostgreSQL)
- (optionnel) **Flutter** pour l’app mobile

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
API_BASE_URL=/api
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

### Premier compte

```bash
curl -X POST http://127.0.0.1:3000/api/authentification/register \
  -H "Content-Type: application/json" \
  -H "x-device-key: ma_cle_device_secrete" \
  -d '{"nom":"Alice","mail":"alice@mail.com","password":"azerty123","confirmation_mdp":"azerty123"}'
```

Pour rendre un utilisateur **admin** (SQL Editor Supabase) :

```sql
UPDATE utilisateurs SET role = 'admin' WHERE email = 'alice@mail.com';
```

Puis se reconnecter (le rôle est dans le JWT).

---

## 4. Front mobile (Flutter)

```bash
cd front_mobile
flutter pub get
flutter run
```

Configurer l’URL de l’API (pas `localhost` sur un téléphone physique) :

```text
http://192.168.x.x:3000/api
```

Headers :

- `x-device-key: ma_cle_device_secrete`
- `Authorization: Bearer <accessToken>`

---

## 5. Déploiement (rappel)

| Élément | Où |
|---------|-----|
| Base PostgreSQL | **Supabase** (déjà) |
| API Node + front web | **Railway** (ou Render / Fly.io) |

Sur Railway : déployer le dossier `backend`, coller les variables du `.env`  
(surtout `DATABASE_URL` pooler, `DEVICE_KEY`, `JWT_SECRET`).

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
cd backend && npm run dev
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
| `Clé device invalide` | Même `DEVICE_KEY` dans `backend/.env` et `front_web/.env` |
| Login OK en local, KO sur téléphone | IP LAN du Mac, pas `localhost` |
| Page Utilisateurs invisible | Compte non admin → `UPDATE utilisateurs SET role = 'admin' ...` |
| Push GitHub bloqué (secrets) | Ne jamais committer `.env` |

---

## Auteur / contexte

Projet bibliothèque — Akieni Academy.
