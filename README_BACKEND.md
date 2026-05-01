# 🎓 DiploChain – Documentation Technique Backend

Bienvenue dans le cœur de **DiploChain**, une plateforme de certification de diplômes infalsifiables basée sur la blockchain Algorand. Ce document explique le fonctionnement du système pour faciliter la reprise en main du code.

---

## 🛠 Stack Technique
- **Framework :** Django 6.0.4 + Django Rest Framework (DRF)
- **Blockchain :** Algorand (SDK : `py-algorand-sdk`)
- **Authentification :** JWT (SimpleJWT) pour l'API & Sessions pour le Web
- **Traitement PDF :** `pypdf` pour le tatouage numérique
- **Documentation API :** `drf-spectacular` (Swagger/Redoc)

---

## 🏛 Architecture & Modèles

### 1. Les Rôles Utilisateurs (`accounts`)
Le système utilise un modèle `CustomUser` avec trois rôles principaux :
- **Institution/Université :** Seule entité autorisée à émettre et signer des diplômes.
- **Étudiant :** Peut consulter ses diplômes certifiés.
- **Recruteur/Public :** Peut vérifier l'authenticité d'un diplôme via un portail public.
- **Admin :** Gère la plateforme et les statistiques.

### 2. Le Modèle Diplôme (`diplomas`)
Chaque diplôme est structuré autour des **3 Piliers de Sécurité** :
- **Pilier 01 (Tatouage) :** Un identifiant unique de 12 caractères injecté dans les métadonnées du PDF.
- **Pilier 02 (Hash SHA-256) :** L'empreinte numérique unique du document watermarqué.
- **Pilier 03 (Blockchain) :** L'ID de transaction (TXID) prouvant l'ancrage sur Algorand.

---

## ⛓ Architecture de la Blockchain

### La Trésorerie (System Wallet)
Le backend gère un portefeuille maître appelé **Trésorerie**. Son rôle est de financer automatiquement les nouvelles universités lors de leur inscription.
- **Lien :** `diplomas/blockchain_utils.py`
- **Variable :** `TRESO_MNEMONIC` (dans le fichier `.env`)

### Flux d'Onboarding
1. Une université s'inscrit.
2. Django génère un nouveau couple de clés (Public/Privé) pour elle.
3. La Trésorerie lui envoie **2 ALGO** (frais de gaz) pour qu'elle devienne autonome.
4. L'université possède alors sa propre identité blockchain stockée dans le modèle `Institution`.

---

## 🚀 Flux de Certification (Le Processus)

Le processus de certification suit ces étapes rigoureuses dans le modèle `Diploma.save()` :

1. **Génération d'ID :** Création du code MIAB de 12 caractères.
2. **Watermarking :** Injection de l'ID dans le PDF via `pypdf`.
3. **Hashing :** Calcul du SHA-256 du fichier final (post-tatouage).
4. **Ancrage (Optionnel) :** L'institution appelle l'endpoint `/api/core/diplomas/{id}/anchor/`.
    - Le backend signe une transaction avec la **clé privée de l'université**.
    - Le hash est inscrit dans le champ `note` de la transaction Algorand.

---

## 🔗 Endpoints API & Documentation

La documentation est interactive et accessible via :
- **Swagger UI :** `/api/docs/`
- **Redoc :** `/api/redoc/`

*Note : Les fichiers Swagger sont servis localement via `drf-spectacular-sidecar` pour garantir l'accès hors-ligne.*

---

## ⚙️ Installation & Configuration

### 1. Variables d'Environnement (`.env`)
Créez un fichier `.env` à la racine :
```bash
ALGOD_URL="https://testnet-api.algonode.cloud"
ALGOD_TOKEN=""
TRESO_MNEMONIC="votre_mnemonique_25_mots"
TRESO_ADDRESS="votre_adresse_publique"
SECRET_KEY="votre_cle_django"
DEBUG=True
```

### 2. Déploiement sur Render
Pour déployer sur Render, utilisez les paramètres suivants :
- **Build Command :** `./render-build.sh`
- **Start Command :** `gunicorn diplomabf.wsgi:application`
- **Environment Variables :** Copiez les valeurs de votre `.env` dans les "Environment Variables" de Render.

Le script `render-build.sh` s'occupe automatiquement des migrations, des fichiers statiques et de la vérification initiale de la blockchain.

---

## 🛡 Sécurité & Supervision
- **Suivi Blockchain :** Plus besoin de terminal ! Accédez à l'onglet **"État Blockchain"** depuis votre Dashboard Admin pour surveiller la connexion et le solde.
- **Clés Privées :** Elles sont stockées en base de données. *Amélioration prévue : Chiffrement AES des clés au repos.*
- **Trésorerie :** Doit être alimentée via le [Testnet Dispenser](https://bank.testnet.algorand.network/) pour continuer à financer les nouvelles institutions.

---
*Document produit pour l'équipe Miab Diplomachain – 2026.*
