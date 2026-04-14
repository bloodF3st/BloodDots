#!/usr/bin/env bash
# =============================================================================
#  dotfiles installer — Arch Linux / Hyprland / Catppuccin Mocha
#  Usage: bash install.sh
# =============================================================================
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
confirm() { read -rp "$* [y/N] " ans; [[ "$ans" =~ ^[Yy]$ ]]; }

# ── 1. Check OS ────────────────────────────────────────────────────────────────
[[ -f /etc/arch-release ]] || error "This installer is for Arch Linux only."

# ── 2. Install yay if missing ─────────────────────────────────────────────────
if ! command -v yay &>/dev/null; then
    info "Installing yay (AUR helper)..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin && makepkg -si --noconfirm
    cd "$DOTFILES_DIR"
fi

# ── 3. Packages ────────────────────────────────────────────────────────────────
info "Installing packages..."

PACMAN_PKGS=(
    # Core Wayland / Hyprland
    hyprland hypridle hyprlock hyprpolkitagent
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    wayland-protocols wl-clipboard wl-clip-persist

    # Audio
    pipewire pipewire-alsa pipewire-jack pipewire-pulse
    wireplumber pamixer easyeffects

    # UI toolkit
    qt5ct qt6ct kvantum gtk2
    nwg-look nwg-displays

    # Shell & terminal
    fish kitty foot fastfetch neofetch

    # Bar / launcher / notifications
    dunst rofi fuzzel

    # Bluetooth / network
    blueman bluez-utils network-manager-applet

    # Screen / media
    grim slurp satty swayosd brightnessctl playerctl
    ffmpegthumbs swww mpvpaper ffmpeg

    # Clipboard history
    cliphist

    # Fonts & themes
    noto-fonts noto-fonts-cjk noto-fonts-emoji
    ttf-jetbrains-mono-nerd

    # Tools
    git github-cli fzf parallel pacman-contrib udiskie
    gnome-keyring polkit-gnome

    # Apps
    tty-clock
)

AUR_PKGS=(
    # HyDE / illogical-impulse
    illogical-impulse-basic
    illogical-impulse-hyprland
    illogical-impulse-quickshell-git
    illogical-impulse-audio
    illogical-impulse-backlight
    illogical-impulse-fonts-themes
    illogical-impulse-gtk
    illogical-impulse-portal
    illogical-impulse-python
    illogical-impulse-screencapture
    illogical-impulse-toolkit
    illogical-impulse-widgets
    illogical-impulse-bibata-modern-classic-bin

    # Catppuccin
    catppuccin-gtk-theme-mocha
    catppuccin-cursors-mocha
    papirus-folders-catppuccin-git

    # Firefox (Flatpak — installed separately below)

    # Extras
    swayosd-git
    wf-recorder
    zen-browser-bin
)

sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}" || warn "Some pacman packages failed"
yay -S --needed --noconfirm "${AUR_PKGS[@]}" || warn "Some AUR packages failed"

# ── 4. Flatpak — Firefox ───────────────────────────────────────────────────────
if ! command -v flatpak &>/dev/null; then
    info "Installing Flatpak..."
    sudo pacman -S --needed --noconfirm flatpak
fi
info "Installing Firefox via Flatpak..."
flatpak install --noninteractive flathub org.mozilla.firefox || warn "Firefox Flatpak install failed"
xdg-settings set default-web-browser org.mozilla.firefox.desktop 2>/dev/null || true

# ── 5. Copy configs ────────────────────────────────────────────────────────────
info "Copying configs..."

backup_and_link() {
    local src="$1" dst="$2"
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        warn "Backing up existing $dst → ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    mkdir -p "$(dirname "$dst")"
    cp -r "$src" "$dst"
}

CONFIG_DIRS=(
    hypr quickshell kitty fish fastfetch
    foot fuzzel dunst rofi
    gtk-3.0 gtk-4.0 illogical-impulse
    qt5ct qt6ct
)

for dir in "${CONFIG_DIRS[@]}"; do
    [[ -d "$DOTFILES_DIR/configs/$dir" ]] && \
        backup_and_link "$DOTFILES_DIR/configs/$dir" "$HOME/.config/$dir"
done

# ── 6. Firefox userChrome / user.js ────────────────────────────────────────────
info "Applying Firefox chrome..."
FF_PROFILE=$(find ~/.var/app/org.mozilla.firefox/config/mozilla/firefox \
    -maxdepth 1 -name "*.default-release" 2>/dev/null | head -1)

if [[ -n "$FF_PROFILE" ]]; then
    cp "$DOTFILES_DIR/firefox/user.js" "$FF_PROFILE/user.js"
    mkdir -p "$FF_PROFILE/chrome"
    cp -r "$DOTFILES_DIR/firefox/themes/"* \
        "$(dirname "$FF_PROFILE")/firefox-themes/" 2>/dev/null || true
    info "Firefox profile updated: $FF_PROFILE"
else
    warn "Firefox profile not found — launch Firefox once first, then re-run."
fi

# ── 7. Set fish as default shell ───────────────────────────────────────────────
if [[ "$SHELL" != "$(command -v fish)" ]]; then
    info "Setting fish as default shell..."
    command -v fish | sudo tee -a /etc/shells
    chsh -s "$(command -v fish)"
fi

# ── 8. Enable services ─────────────────────────────────────────────────────────
info "Enabling user services..."
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true

# ── 9. Setup auto-backup timer ────────────────────────────────────────────────
info "Installing daily backup timer..."
"$DOTFILES_DIR/backup.sh" --install-timer

info ""
info "✅ Installation complete!"
info "   → Reboot or log out and back in to start Hyprland."
info "   → On first login: hyprctl reload"
