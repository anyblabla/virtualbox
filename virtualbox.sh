#!/bin/bash

# ==============================================================================
# TITRE: Installation de VirtualBox Universelle (Dynamique)
# AUTEUR: Amaury Libert (Blabla Linux)
# DESCRIPTION: Détecte la dernière version disponible (7.2+) et l'installe.
# ==============================================================================

set -euo pipefail

# Couleurs
VERT='\033[0;32m'
ROUGE='\033[0;31m'
JAUNE='\033[0;33m'
CYAN='\033[0;36m'
FIN='\033[0m'

CLE_KEYRING="/usr/share/keyrings/oracle-virtualbox.gpg"
FICHIER_SOURCES="/etc/apt/sources.list.d/virtualbox.list"

# Vérification sudo
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${ROUGE}ERREUR : Ce script doit être exécuté avec 'sudo'.${FIN}"
    exit 1
fi

UTILISATEUR_REEL=${SUDO_USER:-$(whoami)}

# --- Étape 1: Détection du système ---
ID=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)

case "$ID" in
    ubuntu|debian)
        DISTRIBUTION_CODENAME=$CODENAME
        ;;
    linuxmint)
        DISTRIBUTION_CODENAME=$(grep UBUNTU_CODENAME /etc/os-release | cut -d= -f2)
        ;;
    *)
        DISTRIBUTION_CODENAME=$CODENAME
        ;;
esac

# --- Étape 2: Installation des outils de base ---
apt update && apt install -y wget gnupg lsb-release build-essential dkms

# --- Étape 3: GPG et Dépôt ---
wget -qO- https://www.virtualbox.org/download/oracle_vbox_2016.asc \
    | gpg --dearmor --yes -o "${CLE_KEYRING}"

echo "deb [arch=amd64 signed-by=${CLE_KEYRING}] https://download.virtualbox.org/virtualbox/debian ${DISTRIBUTION_CODENAME} contrib" \
    | tee "${FICHIER_SOURCES}"

apt update

# --- Étape 4: Détection de la version la plus récente ---
VERSION_CIBLE=$(apt-cache search '^virtualbox-[0-9]' | awk '{print $1}' | sort -V | tail -n 1)

echo -e "${VERT}Dernière version trouvée dans le dépôt : ${VERSION_CIBLE}${FIN}"

# --- Étape 5: Installation ---
apt install -y "${VERSION_CIBLE}"

# Vérification VBoxManage
if ! command -v VBoxManage >/dev/null 2>&1; then
    echo -e "${ROUGE}VBoxManage introuvable après installation.${FIN}"
    exit 1
fi

# --- Étape 6: Extension Pack ---
VERSION_FULL=$(VBoxManage --version | cut -dr -f1 | cut -d'_' -f1)
URL_EXT="https://download.virtualbox.org/virtualbox/${VERSION_FULL}/Oracle_VirtualBox_Extension_Pack-${VERSION_FULL}.vbox-extpack"

echo -e "${JAUNE}Téléchargement de l'Extension Pack ${VERSION_FULL}...${FIN}"

# Vérification disponibilité Extension Pack
if ! wget --spider -q "$URL_EXT"; then
    echo -e "${ROUGE}Extension Pack indisponible pour ${VERSION_FULL}.${FIN}"
    exit 1
fi

wget --show-progress -c "$URL_EXT"

# Installation silencieuse
echo "y" | VBoxManage extpack install --replace "Oracle_VirtualBox_Extension_Pack-${VERSION_FULL}.vbox-extpack"

# --- Étape 7: Finalisation ---
usermod -aG vboxusers "${UTILISATEUR_REEL}"
usermod -aG disk "${UTILISATEUR_REEL}"   # Requis pour accéder aux clés USB physiques
rm "Oracle_VirtualBox_Extension_Pack-${VERSION_FULL}.vbox-extpack"

echo -e "${VERT}*** VirtualBox ${VERSION_FULL} installé avec succès ! ***${FIN}"
