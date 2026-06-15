#!/usr/bin/env bash
set -euo pipefail

# ============================================================
#  Catppuccin Hyprland Rice - Script de Instalación
#  Basado en Catppuccin Mocha Mauve + JaKooLit window mgmt
#  Rolling release — corre `git pull` para actualizar
# ============================================================

ROJO='\033[0;31m'
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

DOTFILES_REPO="https://github.com/Slaker19/dotfiles-catppuccin"
DOTFILES_DIR="$HOME/dotfiles-catppuccin"
CONFIG_DST="$HOME/.config"
LOCAL_DST="$HOME/.local/share"

info()  { echo -e "${CYAN}[INFO]${NC} $1"; }
ok()    { echo -e "${VERDE}[OK]${NC}   $1"; }
warn()  { echo -e "${AMARILLO}[WARN]${NC} $1"; }
error() { echo -e "${ROJO}[ERR]${NC}  $1"; }
header(){ echo -e "\n${MAGENTA}━━━ $1 ━━━${NC}\n"; }

# ── Verificar root ──────────────────────────────────────────
if [[ $EUID -eq 0 ]]; then
    error "NO ejecutes este script como root. El script usa sudo cuando necesita."
    exit 1
fi

# ── Detectar distribución ───────────────────────────────────
if ! command -v pacman &>/dev/null; then
    error "Este script solo funciona en Arch Linux / CachyOS / derivados de pacman."
    exit 1
fi

DISTRO="Arch Linux"
if pacman -Qi cachyos-release &>/dev/null 2>&1; then
    DISTRO="CachyOS"
fi
info "Distribución detectada: $DISTRO"

# ── Asegurar paru (AUR helper) ──────────────────────────────
if ! command -v paru &>/dev/null; then
    warn "paru no está instalado. Instalando..."
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    (cd /tmp/paru && makepkg -si --noconfirm)
    rm -rf /tmp/paru
    ok "paru instalado"
fi

# ── Clonar / actualizar dotfiles ────────────────────────────
header "DOTFILES"
if [[ -d "$DOTFILES_DIR/.git" ]]; then
    info "Actualizando dotfiles existentes..."
    git -C "$DOTFILES_DIR" pull --ff-only
    ok "dotfiles actualizados"
else
    if [[ -d "$DOTFILES_DIR" ]]; then
        warn "$DOTFILES_DIR ya existe pero no es un repo git. Se usará como está."
    else
        info "Clonando dotfiles..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
        ok "dotfiles clonados"
    fi
fi

# ── Paquetes oficiales (pacman) ─────────────────────────────
header "PAQUETES OFICIALES"

PACMAN_PKGS=(
    # Hyprland base
    hyprland hyprpaper hypridle hyprlock xdg-desktop-portal-hyprland

    # UI
    waybar rofi swaync fastfetch ghostty

    # Qt / KDE
    qt6ct kvantum dolphin breeze
    qt6-wayland qt6-svg qt6-declarative

    # Scripts / utilidades
    jq playerctl brightnessctl bluez-utils networkmanager
    blueman polkit-kde-agent

    # Audio / multimedia
    pipewire pipewire-pulse wireplumber

    # Fonts / iconos
    ttf-jetbrains-mono-nerd noto-fonts-emoji papirus-icon-theme

    # Thumbnails / previews
    ffmpegthumbs kdegraphics-thumbnailers

    # Extras útiles
    nwg-look nwg-displays chafa awww mpvpaper
)

info "Instalando paquetes oficiales..."
sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"
ok "Paquetes oficiales instalados"

# ── Paquetes AUR ────────────────────────────────────────────
header "PAQUETES AUR"

AUR_PKGS=(
    catppuccin-gtk-theme-mocha
    cliphist
    hyprswitch
)

info "Instalando paquetes AUR..."
paru -S --needed --noconfirm "${AUR_PKGS[@]}"
ok "Paquetes AUR instalados"

# ── Instalar Quickshell ─────────────────────────────────────
header "QUICKSHELL"
if ! command -v qs &>/dev/null; then
    info "Instalando quickshell (AUR)..."
    paru -S --needed --noconfirm mainstream-quickshell-git
    ok "Quickshell instalado"
else
    ok "Quickshell ya instalado"
fi

# ── Compilar hypr-wallpicker ────────────────────────────────
header "HYPR-WALLPICKER"
if [[ ! -f "$HOME/.config/custom_wall_paper/wallpicker" ]]; then
    info "Clonando y compilando hypr-wallpicker..."
    sudo pacman -S --needed --noconfirm cmake raylib
    git clone https://github.com/Unixcraft-Studios/hypr-wallpicker.git /tmp/hypr-wallpicker
    mkdir -p /tmp/hypr-wallpicker/build
    (cd /tmp/hypr-wallpicker/build && cmake .. && make -j"$(nproc)")
    mkdir -p "$HOME/.config/custom_wall_paper"
    cp /tmp/hypr-wallpicker/build/wallpicker "$HOME/.config/custom_wall_paper/"
    rm -rf /tmp/hypr-wallpicker
    ok "hypr-wallpicker compilado e instalado"
else
    ok "hypr-wallpicker ya instalado"
fi

# ── Tema Kvantum Catppuccin ─────────────────────────────────
header "KVANTUM CATPPUCCIN"
KVANTUM_DST="$HOME/.config/Kvantum"
if [[ ! -d "$KVANTUM_DST/catppuccin-mocha-mauve" ]]; then
    info "Descargando tema Kvantum Catppuccin Mocha Mauve..."
    git clone --depth 1 https://github.com/catppuccin/kvantum /tmp/catppuccin-kvantum
    mkdir -p "$KVANTUM_DST"
    cp -r /tmp/catppuccin-kvantum/themes/catppuccin-mocha-mauve "$KVANTUM_DST/"
    rm -rf /tmp/catppuccin-kvantum
    ok "Tema Kvantum Catppuccin instalado"
else
    ok "Tema Kvantum ya existe"
fi

cat > "$KVANTUM_DST/kvantum.kvconfig" <<< "[General]
theme=catppuccin-mocha-mauve"

# ── Copiar configuraciones ──────────────────────────────────
header "INSTALANDO CONFIGURACIONES"

copy_config() {
    local src="$DOTFILES_DIR/.config/$1"
    local dst="$CONFIG_DST/$1"
    if [[ -e "$src" ]]; then
        rm -rf "$dst"
        cp -r "$src" "$dst"
        ok "→ $dst"
    else
        warn "$src no existe, saltando"
    fi
}

copy_home() {
    local src="$DOTFILES_DIR/$1"
    local dst="$HOME/$1"
    if [[ -e "$src" ]]; then
        mkdir -p "$(dirname "$dst")"
        cp -r "$src" "$dst"
        ok "→ $dst"
    fi
}

for dir in hypr waybar rofi swaync fastfetch qt6ct Kvantum gtk-3.0 gtk-4.0 \
           hypr-wallpicker ghostty btop wlogout hyprwat; do
    copy_config "$dir"
done

if [[ -d "$DOTFILES_DIR/.config/quickshell" ]]; then
    rm -rf "$CONFIG_DST/quickshell"
    mkdir -p "$CONFIG_DST/quickshell"
    rsync -a --exclude='.git' "$DOTFILES_DIR/.config/quickshell/" "$CONFIG_DST/quickshell/"
    ok "→ .config/quickshell/"
fi

copy_home ".local/share/color-schemes"
cp "$DOTFILES_DIR/.config/kdeglobals" "$CONFIG_DST/kdeglobals"
ok "→ .config/kdeglobals"

# ── Configurar gsettings ────────────────────────────────────
header "GSETTINGS"
gsettings set org.gnome.desktop.interface gtk-theme "catppuccin-mocha-mauve-standard+default" 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" 2>/dev/null || true
gsettings set org.gnome.desktop.interface font-name "JetBrains Mono Nerd Font 10" 2>/dev/null || true
ok "gsettings actualizados"

# ── Habilitar servicios ─────────────────────────────────────
header "SERVICIOS"
for svc in pipewire pipewire-pulse wireplumber bluetooth networkmanager; do
    sudo systemctl enable --now "$svc" 2>/dev/null || warn "No se pudo habilitar $svc"
done
ok "Servicios iniciados"

# ── Mensaje final ───────────────────────────────────────────
header "INSTALACIÓN COMPLETA"

echo -e "${VERDE}¡Instalación completada!${NC}"
echo ""
echo -e "${AMARILLO}Pasos siguientes:${NC}"
echo -e "  1. ${CYAN}Reinicia sesión en Hyprland${NC} para aplicar las variables de entorno"
echo -e "  2. Abrí ${MAGENTA}qt6ct${NC} y asegurate que style = kvantum"
echo -e "  3. Si querés wallpapers, copialos a ${MAGENTA}~/Wallpapers/${NC}"
echo -e "  4. Atajos clave:"
echo -e "     ${VERDE}Win+Space${NC}     → Lanzador (rofi)"
echo -e "     ${VERDE}Win+W${NC}         → Wallpaper picker"
echo -e "     ${VERDE}Win+Tab${NC}       → Workspace overview"
echo -e "     ${VERDE}Win+V${NC}         → Portapapeles (cliphist)"
echo -e "     ${VERDE}Win+F${NC}         → Navegador archivos (dolphin)"
echo -e ""
echo -e "${MAGENTA}¡Disfruta tu rice Catppuccin Mocha Mauve! 🚀${NC}"
