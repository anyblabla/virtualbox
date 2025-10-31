#!/bin/bash

# ==============================================================================
# TITRE: Installation de VirtualBox (depuis le dépôt officiel)
# AUTEUR: Amaury Libert (Base) | Amélioré par l'IA
# LICENCE: GPLv3
# DESCRIPTION:
#   Installation automatisée de VirtualBox, y compris l'Extension Pack,
#   en utilisant le dépôt tiers d'Oracle. Compatible Ubuntu 22.04 / Mint 21 (Jammy).
# ==============================================================================

# --- Configuration et Préparation ---

# Mode strict: Quitte en cas d'erreur (-e), variable non définie (-u), ou échec
# dans un pipe (-o pipefail).
set -euo pipefail

# Couleurs pour une sortie utilisateur claire
VERT='\033[0;32m'
ROUGE='\033[0;31m'
JAUNE='\033[0;33m'
CYAN='\033[0;36m'
FIN='\033[0m'

CLE_KEYRING="/usr/share/keyrings/oracle-virtualbox.gpg"
FICHIER_SOURCES="/etc/apt/sources.list.d/virtualbox.list"

# Dépendance Linux Mint 21 / Ubuntu 22.04 = 'jammy'
DISTRIBUTION_CODENAME="jammy"

# Vérification des droits root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${ROUGE}ERREUR : Ce script doit être exécuté avec 'sudo' ou en tant que root.${FIN}"
    exit 1
fi

# Déterminer l'utilisateur réel (pour les groupes)
UTILISATEUR_REEL=${SUDO_USER:-$(whoami)}

echo -e "${CYAN}*** Début de l'installation de VirtualBox ***${FIN}"
clear # Effacer l'écran

# --- Étape 1: Installation des Dépendances et Configuration ---

echo -e "${JAUNE}1. Mise à jour des dépôts et installation des prérequis...${FIN}"

# Suppression de 'ubuntu-keyring' (non nécessaire) et ajout de 'lsb-release' (pour la détection future)
# Ajout des outils de construction pour les modules noyaux (DKMS)
apt update
apt install -y wget apt-transport-https gnupg lsb-release build-essential dkms

# --- Étape 2: Importation de la Clé GPG (Sécurité) ---

echo -e "${JAUNE}2. Importation de la clé publique d'Oracle vers ${CLE_KEYRING}...${FIN}"

# Note: La clé 2016 est correcte, mais la méthode 'curl + gpg --dearmor' est plus standard.
# Utilisation de 'wget' comme dans l'original.
wget -qO- https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --dearmor | tee "${CLE_KEYRING}" > /dev/null

if [ ! -f "${CLE_KEYRING}" ]; then
    echo -e "${ROUGE}ERREUR : Échec de l'importation de la clé GPG. Abandon.${FIN}"
    exit 1
fi
echo -e "${VERT}Clé GPG importée avec succès.${FIN}"

# --- Étape 3: Ajout du Dépôt VirtualBox ---

echo -e "${JAUNE}3. Ajout du dépôt VirtualBox dans ${FICHIER_SOURCES}...${FIN}"

# Utilisation de la variable DISTRIBUTION_CODENAME pour une maintenance future simplifiée
echo "deb [arch=amd64 signed-by=${CLE_KEYRING}] http://download.virtualbox.org/virtualbox/debian ${DISTRIBUTION_CODENAME} contrib" | tee "${FICHIER_SOURCES}"

if [ ! -f "${FICHIER_SOURCES}" ]; then
    echo -e "${ROUGE}ERREUR : Échec de la création du fichier sources.list. Abandon.${FIN}"
    exit 1
fi
echo -e "${VERT}Dépôt VirtualBox ajouté avec succès.${FIN}"

# --- Étape 4: Installation de VirtualBox ---

echo -e "${JAUNE}4. Raffraîchissement des dépôts et installation de VirtualBox (version 7.0+)...${FIN}"
apt update
# Installer le paquet principal 'virtualbox-7.0' (la version 7.1 n'existe pas, 7.0 est la plus récente au moment de l'écriture)
# L'utilisation de 'virtualbox-7.0' assure d'obtenir la bonne version.
apt install -y virtualbox-7.0

echo -e "${VERT}VirtualBox installé. Installation du Pack d'Extension...${FIN}"

# --- Étape 5: Installation du Pack d'Extension (Extension Pack) ---

# Déterminer la version installée et la simplifier (ex: 7.0.10_158373r -> 7.0.10)
VERSION_VBOX=$(VBoxManage --version | cut -dr -f1 | cut -d'_' -f1)
EXTENSION_PACK="Oracle_VM_VirtualBox_Extension_Pack-${VERSION_VBOX}.vbox-extpack"

echo -e "${JAUNE}5. Téléchargement et installation du Pack d'Extension pour la version ${VERSION_VBOX}...${FIN}"

# Téléchargement
wget -c "http://download.virtualbox.org/virtualbox/${VERSION_VBOX}/${EXTENSION_PACK}"

# Installation (avec une pause de 5 secondes pour permettre à l'utilisateur de lire la licence)
echo -e "${CYAN}!!! ATTENTION : La licence d'Oracle va s'afficher. Acceptez avec 'y' après 5 secondes. !!!${FIN}"
sleep 5
echo "y" | VBoxManage extpack install --replace "${EXTENSION_PACK}"

if [ $? -ne 0 ]; then
    echo -e "${ROUGE}AVERTISSEMENT : L'installation de l'Extension Pack a échoué (vérifiez l'acceptation de la licence).${FIN}"
fi

# --- Étape 6: Configuration des Utilisateurs et Nettoyage ---

echo -e "${JAUNE}6. Ajout de l'utilisateur ${UTILISATEUR_REEL} aux groupes nécessaires...${FIN}"

# Ajout au groupe 'vboxusers' (nécessaire pour l'USB)
usermod -aG vboxusers "${UTILISATEUR_REEL}"

# Suppression du groupe 'disk' (pas nécessaire pour VirtualBox et potentiellement dangereux)
# On se contente d'ajouter l'utilisateur à vboxusers.
echo -e "${VERT}Utilisateur ajouté au groupe 'vboxusers'. (Nécessite une déconnexion/reconnexion).${FIN}"

echo -e "${JAUNE}7. Suppression du fichier d'Extension Pack téléchargé...${FIN}"
rm "${EXTENSION_PACK}"

echo -e "${VERT}*** Installation de VirtualBox terminée ! ***${FIN}"
echo ""
echo -e "N'oubliez pas de vous ${ROUGE}déconnecter et reconnecter${VERT} pour que les changements de groupes prennent effet.${FIN}"