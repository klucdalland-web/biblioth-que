# BiblioGestion

Application de gestion d’une bibliothèque de quartier (personnel / bibliothécaires).

| Partie | Techno |
|--------|--------|
| **backend** | Node.js (HTTP natif), MySQL, JWT |
| **front_web** | HTML / CSS / JS (servi par le backend) |
| **front_mobile** | Flutter + GetX |

---

## Prérequis

- **Node.js** ≥ 18
- **MySQL** ≥ 8
- **npm**
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

## 1. Base de données

Créer la base et les tables :

```bash
mysql -u root -p < backend/src/config/database.sql
```

Ou dans MySQL Workbench / CLI : exécuter le contenu de `backend/src/config/database.sql`.

---

## 2. Backend

### Installation

```bash
cd backend
npm install
```

### Configuration

Copier l’exemple d’environnement :

```bash
cp .env.example .env
```

Éditer `backend/.env` :

```env
PORT=3000
NODE_ENV=development

DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=bibliotheque
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




### Lancer

```bash
cd backend
npm run dev
```

Le serveur démarre sur le port **3000** :

| URL | Description |
|-----|-------------|
| http://127.0.0.1:3000/login.html | Interface web |
| http://127.0.0.1:3000/api/... | API REST |



Sur le réseau local (même Wi‑Fi) :

```text
http://<IP_DU_MAC>:3000
```

Exemple : `http://192.168.0.65:3000`

---

## 3. Front web

Rien à installer à part : le backend **sert** déjà `front_web/public`.

1. Lancer le backend (`npm run dev`)
2. Ouvrir http://127.0.0.1:3000/login.html

### Premier compte

Via register :

```bash
curl -X POST http://127.0.0.1:3000/api/authentification/register \
  -H "Content-Type: application/json" \
  -H "x-device-key: ma_cle_device_secrete" \
  -d '{"nom":"Alice","mail":"alice@mail.com","password":"azerty123","confirmation_mdp":"azerty123"}'
```

Pour rendre un utilisateur **admin** (gestion des users) :

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

Configurer l’URL de l’API vers la machine qui héberge le backend, par ex. :

```text
http://192.168.0.65:3000/api
```

(pas `localhost` depuis un téléphone physique — `localhost` pointe vers le téléphone).

Headers requis comme le web :

- `x-device-key: ma_cle_device_secrete`
- `Authorization: Bearer <accessToken>`

---

## API — rappel rapide

Toutes les routes (sauf health éventuel) exigent le header :

```http
x-device-key: ma_cle_device_secrete
```

Routes protégées (hors login / register / refresh / logout) :

```http
Authorization: Bearer <accessToken>
```

| Ressource | Préfixe |
|-----------|---------|
| Auth | `/api/authentification` (`login`, `register`, `refresh`, `logout`, `me`) |
| Auteurs | `/api/auteurs` |
| Adhérents | `/api/adherents` |
| Livres | `/api/livres` |
| Emprunts | `/api/emprunts` |
| Stats | `/api/stats` |
| Users (admin) | `/api/users` |

---

## Scripts utiles

```bash
# Backend en mode watch
cd backend && npm run dev

# Réimporter le schéma SQL (⚠️ efface les données)
mysql -u root -p < backend/src/config/database.sql
```

---

## Dépannage

| Problème | Piste |
|----------|--------|
| `EADDRINUSE :::3000` | Un process occupe déjà le port → `lsof -i :3000` puis tuer le PID |
| `Token invalide ou expiré` | Le front web refresh automatiquement ; sinon reconnecte-toi |
| `Clé device invalide` | Vérifier `DEVICE_KEY` dans `backend/.env` et `front_web/.env` |
| Login OK en local, KO sur téléphone | Utiliser l’IP LAN du Mac, pas `localhost` |
| Page Utilisateurs invisible | Compte non admin → `UPDATE utilisateurs SET role = 'admin' ...` |

---

## Auteur / contexte

Projet bibliothèque — Akieni Academy.
