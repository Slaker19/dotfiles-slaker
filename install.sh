#!/usr/bin/env bash
set -euo pipefail

ROJO='\033[0;31m'
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

DOTFILES_REPO="https://github.com/Slaker19/dotfiles-slaker"
DOTFILES_DIR="$HOME/dotfiles-slaker"
BACKUP_DIR="$HOME/.config/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

info()  { echo -e "${CYAN}[INFO]${NC} $1"; }
ok()    { echo -e "${VERDE}[OK]${NC}   $1"; }
warn()  { echo -e "${AMARILLO}[WARN]${NC} $1"; }
error() { echo -e "${ROJO}[ERR]${NC}  $1"; }
header(){ echo -e "\n${MAGENTA}━━━ $1 ━━━${NC}\n"; }

if [[ $EUID -eq 0 ]]; then
    error "NO ejecutes como root. El script usa sudo cuando necesita."
    exit 1
fi

if ! command -v pacman &>/dev/null; then
    error "Solo funciona en Arch Linux / CachyOS / derivados."
    exit 1
fi

DISTRO="Arch Linux"
pacman -Qi cachyos-release &>/dev/null 2>&1 && DISTRO="CachyOS"
info "Distribución: $DISTRO"

DETECT_GPU() {
    local gpu
    gpu=$(lspci 2>/dev/null | grep -i "vga\|3d\|display" || echo "")
    if echo "$gpu" | grep -qi nvidia; then echo "nvidia"
    elif echo "$gpu" | grep -qi "amd\|ati\|radeon"; then echo "amd"
    elif echo "$gpu" | grep -qi intel; then echo "intel"
    else echo "unknown"; fi
}
GPU=$(DETECT_GPU)
info "GPU detectada: $GPU"

header "AUR HELPER"
AUR_HELPER=""
for helper in paru yay; do
    if command -v "$helper" &>/dev/null; then
        AUR_HELPER="$helper"
        ok "$helper detectado"
        break
    fi
done

if [[ -z "$AUR_HELPER" ]]; then
    warn "Instalando paru (AUR helper)..."
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    (cd /tmp/paru && makepkg -si --noconfirm)
    rm -rf /tmp/paru
    AUR_HELPER="paru"
    ok "paru instalado"
fi

header "DOTFILES"
if [[ -d "$DOTFILES_DIR/.git" ]]; then
    info "Actualizando dotfiles..."
    git -C "$DOTFILES_DIR" pull --ff-only
    ok "actualizados"
else
    if [[ -d "$DOTFILES_DIR" ]]; then
        warn "$DOTFILES_DIR existe pero no es git. Se usará igual."
    else
        info "Clonando dotfiles..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
        ok "clonados"
    fi
fi

header "PAQUETES OFICIALES"

PACMAN_PKGS=(
    # === Hyprland y ecosistema ===
    hyprland hyprpaper hypridle hyprlock
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

    # === Interfaz de usuario ===
    waybar rofi swaync fastfetch wlogout

    # === Terminal ===
    ghostty btop

    # === Gestor de archivos ===
    nautilus

    # === Qt ===
    qt6ct kvantum
    qt5-wayland qt6-wayland qt6-svg qt6-declarative

    # === Sonido ===
    pipewire pipewire-pulse wireplumber

    # === Bluetooth ===
    bluez bluez-utils blueman

    # === Red ===
    networkmanager network-manager-applet

    # === Autenticación ===
    polkit polkit-kde-agent

    # === Herramientas ===
    jq playerctl brightnessctl grim slurp
    wl-clipboard libnotify

    # === Fuentes e íconos ===
    ttf-jetbrains-mono-nerd noto-fonts-emoji
    papirus-icon-theme capitaine-cursors

    # === Utilidades ===
    nwg-look nwg-displays chafa
    unzip wget curl rsync openssh git

    # === Compilación (wallpicker) ===
    cmake raylib

    # === Wallpaper (CachyOS) ===
    awww

    # === Display Manager ===
    sddm
)

if [[ "$GPU" = "nvidia" ]]; then
    PACMAN_PKGS+=(nvidia-dkms nvidia-utils libva-nvidia-driver)
elif [[ "$GPU" = "amd" ]]; then
    PACMAN_PKGS+=(mesa vulkan-radeon libva-mesa-driver)
elif [[ "$GPU" = "intel" ]]; then
    PACMAN_PKGS+=(mesa vulkan-intel libva-intel-driver)
fi

info "Instalando paquetes oficiales..."
sudo pacman -S --needed --noconfirm --ask 4 "${PACMAN_PKGS[@]}"
ok "Paquetes oficiales instalados"

header "INSTALANDO CONFIGURACIONES"

WALLPAPER_DIR="$HOME/Wallpapers"

# Backup de configs existentes
if [[ -d "$HOME/.config/hypr" ]] || [[ -d "$HOME/.config/waybar" ]]; then
    mkdir -p "$BACKUP_DIR"
    for dir in hypr waybar rofi swaync fastfetch qt6ct Kvantum gtk-3.0 gtk-4.0 \
               hypr-wallpicker ghostty btop wlogout hyprwat quickshell; do
        [[ -d "$HOME/.config/$dir" ]] && cp -r "$HOME/.config/$dir" "$BACKUP_DIR/"
    done
    ok "Backup creado en $BACKUP_DIR"
fi

copy_config() {
    local src="$DOTFILES_DIR/.config/$1"
    local dst="$HOME/.config/$1"
    if [[ -e "$src" ]]; then
        rm -rf "$dst"
        cp -r "$src" "$dst"
        ok "→ .config/$1"
    fi
}

copy_home() {
    local src="$DOTFILES_DIR/$1"
    local dst="$HOME/$1"
    if [[ -e "$src" ]]; then
        mkdir -p "$(dirname "$dst")"
        cp -r "$src" "$dst"
        ok "→ $1"
    fi
}

# Copiar configs
for dir in hypr waybar rofi swaync fastfetch qt6ct Kvantum gtk-3.0 gtk-4.0 \
           hypr-wallpicker ghostty btop wlogout hyprwat; do
    copy_config "$dir"
done

if [[ -d "$DOTFILES_DIR/.config/quickshell" ]]; then
    rm -rf "$HOME/.config/quickshell"
    mkdir -p "$HOME/.config/quickshell"
    rsync -a --exclude='.git' "$DOTFILES_DIR/.config/quickshell/" "$HOME/.config/quickshell/"
    ok "→ .config/quickshell/"
fi

copy_home ".local/share/color-schemes"
cp "$DOTFILES_DIR/.config/kdeglobals" "$HOME/.config/kdeglobals"
ok "→ .config/kdeglobals"

# Reemplazar placeholders en las configs YA COPIADAS (no en el clon)
header "REEMPLAZANDO PLACEHOLDERS"
find "$HOME/.config" -type f \
    \( -name '*.conf' -o -name '*.rasi' -o -name '*.sh' \) \
    -exec sed -i "s|__WALLPAPER_DIR__|$WALLPAPER_DIR|g" {} + 2>/dev/null || true
ok "Placeholders reemplazados"

header "WALLPAPERS"
mkdir -p "$HOME/Wallpapers"
if [[ -d "$DOTFILES_DIR/Wallpapers" ]] && [[ -z "$(ls -A "$HOME/Wallpapers" 2>/dev/null)" ]]; then
    cp "$DOTFILES_DIR"/Wallpapers/* "$HOME/Wallpapers/"
    ok "Wallpapers copiados a ~/Wallpapers/"
else
    ok "Wallpapers ya existen o no hay en el repo"
fi

header "HYPR-WALLPICKER"
if [[ ! -f "$HOME/.config/custom_wall_paper/wallpicker" ]]; then
    info "Clonando y compilando hypr-wallpicker..."
    git clone https://github.com/Unixcraft-Studios/hypr-wallpicker.git /tmp/hypr-wallpicker
    (cd /tmp/hypr-wallpicker && make -j"$(nproc)") || warn "Falló compilación de hypr-wallpicker (puedes compilarlo manualmente)"
    if [[ -f /tmp/hypr-wallpicker/wallpicker ]]; then
        mkdir -p "$HOME/.config/custom_wall_paper"
        cp /tmp/hypr-wallpicker/wallpicker "$HOME/.config/custom_wall_paper/"
        rm -rf /tmp/hypr-wallpicker
        ok "hypr-wallpicker compilado"
    fi
else
    ok "hypr-wallpicker ya existe"
fi

header "KVANTUM CATPPUCCIN"
KVANTUM_DST="$HOME/.config/Kvantum"
if [[ ! -d "$KVANTUM_DST/catppuccin-mocha-mauve" ]]; then
    info "Descargando tema Kvantum Catppuccin..."
    git clone --depth 1 https://github.com/catppuccin/kvantum /tmp/catppuccin-kvantum || true
    if [[ -d /tmp/catppuccin-kvantum/themes/catppuccin-mocha-mauve ]]; then
        mkdir -p "$KVANTUM_DST"
        cp -r /tmp/catppuccin-kvantum/themes/catppuccin-mocha-mauve "$KVANTUM_DST/"
        rm -rf /tmp/catppuccin-kvantum
        ok "Tema Kvantum instalado"
    else
        warn "No se pudo descargar tema Kvantum"
    fi
else
    ok "Tema Kvantum ya existe"
fi

cat > "$KVANTUM_DST/kvantum.kvconfig" <<< "[General]
theme=catppuccin-mocha-mauve" || true

header "PAQUETES AUR"

AUR_PKGS=(
    catppuccin-gtk-theme-mocha
    cliphist
    hyprswitch
    mainstream-quickshell-git
    hyprwat-bin
    mpvpaper
    brave-origin-bin
)

info "Instalando paquetes AUR..."
set +e
$AUR_HELPER -S --needed --noconfirm "${AUR_PKGS[@]}"
AUR_EXIT=$?
set -e
if [[ $AUR_EXIT -eq 0 ]]; then
    ok "Paquetes AUR instalados"
else
    warn "Algunos paquetes AUR fallaron. Puedes instalarlos manualmente después."
fi

header "GSETTINGS"
gsettings set org.gnome.desktop.interface gtk-theme "catppuccin-mocha-mauve-standard+default" 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" 2>/dev/null || true
gsettings set org.gnome.desktop.interface font-name "JetBrains Mono Nerd Font 10" 2>/dev/null || true
gsettings set org.gnome.desktop.interface cursor-theme "capitaine-cursors" 2>/dev/null || true
ok "gsettings actualizados"

header "CONFIG NVIDIA"
if [[ "$GPU" = "nvidia" ]]; then
    echo "env = LIBVA_DRIVER_NAME,nvidia" >> "$HOME/.config/hypr/environments.conf"
    echo "env = __GLX_VENDOR_LIBRARY_NAME,nvidia" >> "$HOME/.config/hypr/environments.conf"
    echo "env = WLR_NO_HARDWARE_CURSORS,1" >> "$HOME/.config/hypr/environments.conf"
    echo "env = WLR_DRM_NO_MODIFIERS,1" >> "$HOME/.config/hypr/environments.conf"
    ok "Variables NVIDIA añadidas"
else
    ok "No aplica (GPU $GPU)"
fi

header "SERVICIOS"

# Servicios de sistema
for svc in bluetooth NetworkManager sddm; do
    sudo systemctl enable --now "$svc" 2>/dev/null || warn "No se pudo habilitar $svc"
done

# Servicios de usuario
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || \
    warn "No se pudieron habilitar los servicios de usuario"

ok "Servicios iniciados"

header "INSTALACIÓN COMPLETA"
echo -e "${VERDE}¡Todo listo!${NC}"
echo ""
echo -e "${AMARILLO}Para aplicar:${NC}"
echo -e "  1. ${CYAN}Reiniciá sesión en Hyprland${NC}"
echo -e "     (SDDM está habilitado, seleccioná Hyprland)"
echo -e ""
echo -e "${AMARILLO}Atajos clave:${NC}"
echo -e "  ${VERDE}Win+Enter${NC}  Terminal (ghostty)"
echo -e "  ${VERDE}Win+D${NC}      Lanzador (rofi)"
echo -e "  ${VERDE}Win+W${NC}      Wallpaper picker"
echo -e "  ${VERDE}Win+Tab${NC}    Workspace overview"
echo -e "  ${VERDE}Win+Shift+V${NC}  Portapapeles"
echo -e "  ${VERDE}Win+E${NC}      Archivos (nautilus)"
echo -e "  ${VERDE}Win+Q${NC}      Cerrar ventana"
echo -e "  ${VERDE}Win+F${NC}      Fullscreen"
echo -e ""
echo -e "${MAGENTA}Catppuccin Mocha Mauve — Slaker19${NC}"
