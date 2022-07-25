#!/bin/bash
#
# Autheur:
#   Amaury Libert <amaury-libert@hotmail.com> de Blabla Linux <https://blablalinux.be>
#
# Description:
#   Installation automatisée de VirtualBox sur Linux Mint 21 et Ubuntu 22.04 à partir du dépôt tiers VirtualBox.
#
# Préambule Légal:
# 	Ce script est un logiciel libre.
# 	Vous pouvez le redistribuer et / ou le modifier selon les termes de la licence publique générale GNU telle que publiée par la Free Software Foundation; version 3.
#
# 	Ce script est distribué dans l'espoir qu'il sera utile, mais SANS AUCUNE GARANTIE; sans même la garantie implicite de QUALITÉ MARCHANDE ou d'ADÉQUATION À UN USAGE PARTICULIER.
# 	Voir la licence publique générale GNU pour plus de détails.
#
# 	Licence publique générale GNU : <https://www.gnu.org/licenses/gpl-3.0.txt>
#
echo "Effacement écran..."
clear
#
echo "Installer les paquets requis..."
apt install wget apt-transport-https gnupg2 ubuntu-keyring -y
#
echo "Importer la clé GPG..." 
wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --dearmor | tee /usr/share/keyrings/virtualbox.gpg
#
echo "Importer le dépôt VirtualBox..."
echo deb [arch=amd64 signed-by=/usr/share/keyrings/virtualbox.gpg] http://download.virtualbox.org/virtualbox/debian jammy contrib | tee /etc/apt/sources.list.d/virtualbox.list
#
echo "Rafraîchissement dépôts..."
apt update
#
echo "Installations de virtualbox..."
apt install -y virtualbox-6.1
#
echo "Téléchargement du pack d'extension USB..."
version=$(VBoxManage --version|cut -dr -f1|cut -d'_' -f1) && wget -c http://download.virtualbox.org/virtualbox/$version/Oracle_VM_VirtualBox_Extension_Pack-$version.vbox-extpack
#
echo "Installation du pack d'extension USB..."
echo "y" | VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-$version.vbox-extpack
#
echo "VirtualBox ajouts groupes..."
usermod -G vboxusers -a $SUDO_USER
usermod -G disk -a $SUDO_USER
#
echo "Suppression du pack d'extension USB VirtualBox..."
rm *.vbox-extpack
