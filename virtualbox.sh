#!/bin/bash

# ==============================================================================
# TITRE: Installation / Désinstallation de VirtualBox (Universel & Dynamique)
# AUTEUR: Amaury Libert (Blabla Linux)
# DESCRIPTION: Installe ou désinstalle proprement VirtualBox (7.2+), Extension Pack,
#              dépôt Oracle, clé GPG, groupes, etc.
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

# ==============================================================================
# FONCTION : INSTALLATION
# ==============================================================================
installer_virtualbox() {

    echo -e "${CYAN}--- Installation de VirtualBox ---${FIN}"

    # Détection système
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

    # Outils de base
    apt update && apt install -y wget gnupg lsb-release build-essential dkms

    # Dépôt Oracle
    wget -qO- https://www.virtualbox.org/download/oracle_vbox_2016.asc \
        | gpg --dearmor --yes -o "${CLE_KEYRING}"

    echo "deb [arch=amd64 signed-by=${CLE_KEYRING}] https://download.virtualbox.org/virtualbox/debian ${DISTRIBUTION_CODENAME} contrib" \
        | tee "${FICHIER_SOURCES}"

    apt update

    # Détection version
    VERSION_CIBLE=$(apt-cache search '^virtualbox-[0-9]' | awk '{print $1}' | sort -V | tail -n 1)
    echo -e "${VERT}Version détectée : ${VERSION_CIBLE}${FIN}"

    # Installation
    apt install -y "${VERSION_CIBLE}"

    # Vérification VBoxManage
    if ! command -v VBoxManage >/dev/null 2>&1; then
        echo -e "${ROUGE}VBoxManage introuvable après installation.${FIN}"
        exit 1
    fi

    # Extension Pack
    VERSION_FULL=$(VBoxManage --version | cut -dr -f1 | cut -d'_' -f1)
    URL_EXT="https://download.virtualbox.org/virtualbox/${VERSION_FULL}/Oracle_VirtualBox_Extension_Pack-${VERSION_FULL}.vbox-extpack"

    echo -e "${JAUNE}Téléchargement de l'Extension Pack...${FIN}"

    if ! wget --spider -q "$URL_EXT"; then
        echo -e "${ROUGE}Extension Pack indisponible pour ${VERSION_FULL}.${FIN}"
        exit 1
    fi

    wget --show-progress -c "$URL_EXT"
    echo "y" | VBoxManage extpack install --replace "Oracle_VirtualBox_Extension_Pack-${VERSION_FULL}.vbox-extpack"

    # Groupes
    usermod -aG vboxusers "${UTILISATEUR_REEL}"
    usermod -aG disk "${UTILISATEUR_REEL}"

    rm "Oracle_VirtualBox_Extension_Pack-${VERSION_FULL}.vbox-extpack"

    echo -e "${VERT}*** VirtualBox ${VERSION_FULL} installé avec succès ! ***${FIN}"
}

# ==============================================================================
# FONCTION : DESINSTALLATION
# ==============================================================================
desinstaller_virtualbox() {

    echo -e "${CYAN}--- Désinstallation de VirtualBox ---${FIN}"

    # Désinstallation des paquets VirtualBox
    apt remove --purge -y virtualbox-* || true

    # Suppression Extension Pack
    if command -v VBoxManage >/dev/null 2>&1; then
        VBoxManage extpack uninstall "Oracle VM VirtualBox Extension Pack" || true
    fi

    # Suppression dépôt Oracle
    rm -f "${FICHIER_SOURCES}"
    rm -f "${CLE_KEYRING}"

    # Nettoyage
    apt autoremove -y
    apt autoclean -y

    # Suppression des groupes (optionnel)
    gpasswd -d "${UTILISATEUR_REEL}" vboxusers || true
    gpasswd -d "${UTILISATEUR_REEL}" disk || true

    echo -e "${VERT}*** VirtualBox désinstallé proprement ! ***${FIN}"
}

# ==============================================================================
# MENU
# ==============================================================================
echo -e "${CYAN}==============================================${FIN}"
echo -e "${CYAN} VirtualBox - Installation / Désinstallation ${FIN}"
echo -e "${CYAN}==============================================${FIN}"
echo ""
echo "1) Installer VirtualBox"
echo "2) Désinstaller VirtualBox"
echo "3) Quitter"
echo ""
read -rp "Votre choix : " CHOIX

case "$CHOIX" in
    1) installer_virtualbox ;;
    2) desinstaller_virtualbox ;;
    3) exit 0 ;;
    *) echo -e "${ROUGE}Choix invalide.${FIN}" ;;
esac
