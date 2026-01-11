# 📦 `virtualbox.sh`

## Script d'installation de VirtualBox à partir du dépôt tiers officiel (Universel)

-----

### 🇫🇷 **Description du projet**

Ce script Bash automatise l'installation de **VirtualBox 7.2+** en configurant dynamiquement le dépôt tiers officiel d'Oracle. 

Le script détecte automatiquement votre distribution et sa base (Debian, Ubuntu ou Mint) pour installer la version la plus récente disponible, incluant le **Pack d'Extension (Extension Pack)**. L'utilisation du dépôt officiel garantit l'accès aux dernières fonctionnalités et correctifs de sécurité dès leur sortie.

**Compatibilité :**
Le script est optimisé pour :
* **Debian 12 (Bookworm) & 13 (Trixie)**
* **Ubuntu 22.04 (Jammy) & 24.04 (Noble)**
* **Linux Mint 21.x & 22.x**

### 🇬🇧 **Project Description**

This Bash script automates the installation of **VirtualBox 7.2+** by dynamically configuring the official Oracle third-party repository.

The script automatically detects your distribution and its base (Debian, Ubuntu, or Mint) to install the latest available version, including the **Extension Pack**. Using the official repository ensures access to the latest features and security patches as soon as they are released.

**Compatibility:**
The script is optimized for:
* **Debian 12 (Bookworm) & 13 (Trixie)**
* **Ubuntu 22.04 (Jammy) & 24.04 (Noble)**
* **Linux Mint 21.x & 22.x**

-----

### 🛠️ **Installation et utilisation / Installation and Usage**

1.  **Rendre le script exécutable :**
    ```bash
    chmod +x virtualbox.sh
    ```

2.  **Lancer l'installation avec les droits `sudo` :**
    ```bash
    sudo ./virtualbox.sh
    ```

**Actions automatisées :**
* Importation sécurisée de la clé GPG d'Oracle.
* Détection automatique du "Codename" de la distribution.
* Installation de `dkms` et des dépendances de construction.
* Installation de la version la plus récente (ex: 7.2).
* Téléchargement et installation automatique de l'Extension Pack.
* Ajout de l'utilisateur aux groupes `vboxusers` et `disk`.

-----

### 📺 **Démonstration**

| Vidéo | Chaîne | Lien |
| :--- | :--- | :--- |
| **Mon script Virtualbox pour Mint 21** | Blabla Linux | [Regarder la Démonstration](http://www.youtube.com/watch?v=IiWoVe8r9FQ) |

> *Note : Bien que la vidéo présente Mint 21, le script a été mis à jour pour supporter Debian 13 et les versions supérieures de VirtualBox.*

-----

### 📝 **Licence**

Ce projet est sous licence GNU GPL (v2.0).
