#!/bin/bash

# Salir inmediatamente si un comando falla
set -e

# ==========================================
# Funciones Modulares
# ==========================================

function configurar_repositorios() {
    echo ""
    echo "--- 1. Configurando repositorios (RPM Fusion, Terra y Flathub) ---"
    sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    echo "¡Repositorios configurados con éxito!"
    echo ""
}

function actualizar_sistema() {
    echo ""
    echo "--- 2. Actualizando paquetes core y el sistema en general ---"
    sudo dnf group upgrade -y core
    sudo dnf4 group install -y core
    sudo dnf update -y
    echo "¡Sistema y Core actualizados!"
    echo ""
}

function instalar_drivers() {
    echo ""
    echo "--- 3. Instalando controladores de NVIDIA ---"
    sudo dnf install -y akmod-nvidia
    echo "¡Controladores instalados!"
    echo ""
}

function soporte_multimedia() {
    echo ""
    echo "--- 4. Instalando codecs y soporte multimedia ---"
    sudo dnf4 group install -y multimedia
    sudo dnf swap -y 'ffmpeg-free' 'ffmpeg' --allowerasing
    sudo dnf group install -y sound-and-video
    sudo dnf install -y ffmpeg-libs libva libva-utils
    echo "¡Soporte multimedia y codecs listos!"
    echo ""
}

function ajustes_finales() {
    echo ""
    echo "--- 5. Aplicando ajustes adicionales ---"
    # Eliminar preferencias por defecto de Red Hat en Firefox
    sudo rm -f /usr/lib64/firefox/browser/defaults/preferences/firefox-redhat-default-prefs.js

    # Deshabilitar el servicio de espera de red para acelerar el arranque
    sudo systemctl disable NetworkManager-wait-online.service
    echo "¡Ajustes finales aplicados!"
    echo ""
}

# ==========================================
# Menú Principal
# ==========================================

while true; do
    echo "========================================================="
    echo "   MENÚ DE POST-INSTALACIÓN FEDORA 44"
    echo "========================================================="
    echo "1. Configuración de Repositorios"
    echo "2. Actualización del Sistema y Core"
    echo "3. Instalación de Controladores (NVIDIA)"
    echo "4. Soporte Multimedia y Codecs"
    echo "5. Ajustes Finales del Sistema"
    echo "6. Ejecutar TODO (Paso 1 al 5)"
    echo "7. Salir"
    echo "========================================================="
    read -p "Elige una opción (1-7): " opcion

    case $opcion in
        1) configurar_repositorios ;;
        2) actualizar_sistema ;;
        3) instalar_drivers ;;
        4) soporte_multimedia ;;
        5) ajustes_finales ;;
        6)
            configurar_repositorios
            actualizar_sistema
            instalar_drivers
            soporte_multimedia
            ajustes_finales
            echo "¡Toda la post-instalación fue completada con éxito!"
            ;;
        7) 
            echo "Saliendo del script..."
            exit 0 
            ;;
        *) 
            echo "Opción no válida. Por favor, ingresa un número del 1 al 7."
            echo ""
            ;;
    esac
done
