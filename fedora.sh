#!/bin/bash

# Salir inmediatamente si un comando falla
set -e

echo "Iniciando script de post-instalación para Fedora 44..."

# ==========================================
# 1. Configuración de Repositorios
# ==========================================
echo "Configurando repositorios (RPM Fusion, Terra y Flathub)..."
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# ==========================================
# 2. Actualización del Sistema y Core
# ==========================================
echo "Actualizando paquetes core y el sistema en general..."
sudo dnf group upgrade -y core
sudo dnf4 group install -y core
sudo dnf update -y

# ==========================================
# 3. Controladores (Drivers)
# ==========================================
echo "Instalando controladores de NVIDIA..."
sudo dnf install -y akmod-nvidia

# ==========================================
# 4. Soporte Multimedia y Codecs
# ==========================================
echo "Instalando codecs y soporte multimedia..."
sudo dnf4 group install -y multimedia
sudo dnf swap -y 'ffmpeg-free' 'ffmpeg' --allowerasing
sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf group install -y sound-and-video
sudo dnf install -y ffmpeg-libs libva libva-utils

# ==========================================
# 5. Ajustes Finales del Sistema
# ==========================================
echo "Aplicando ajustes adicionales..."
# Eliminar preferencias por defecto de Red Hat en Firefox
sudo rm -f /usr/lib64/firefox/browser/defaults/preferences/firefox-redhat-default-prefs.js

# Deshabilitar el servicio de espera de red para acelerar el arranque
sudo systemctl disable NetworkManager-wait-online.service

echo "¡Post-instalación completada con éxito!"
