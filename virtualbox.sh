#!/bin/bash
#
# Autheur:
#   Amaury Libert <amaury-libert@hotmail.com> de Blabla Linux <https://blablalinux.be>
#
# Description:
#   Script d'installations logiciel VirtualBox pour Linux Mint 20+ (Cinnamon/Mate/xfce) afin d'obtenir le logiciel VirtualBox à partir du dépôt tiers VirtualBox". CE script peut-être valable aussi pour Linux Ubuntu 19.10 et 20.04.
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
echo " Ajout de la clé d'authentification et du dépôt supplémentaire virtualbox..." 
wget -q -O- http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc | apt-key add -
echo "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian eoan contrib" | tee /etc/apt/sources.list.d/virtualbox.list
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
