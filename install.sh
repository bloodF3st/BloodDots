#!/usr/bin/env bash
# =============================================================================
#  BloodDots installer — Arch Linux / Hyprland / Catppuccin Mocha
#  Usage: bash install.sh [--no-packages] [--no-configs] [--no-system]
# =============================================================================
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
BOLD='\033[1m'

info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
step()    { echo -e "\n${BOLD}$*${NC}"; }
confirm() { read -rp "$* [y/N] " ans; [[ "$ans" =~ ^[Yy]$ ]]; }

SKIP_PACKAGES=0; SKIP_CONFIGS=0; SKIP_SYSTEM=0
for arg in "$@"; do
    case "$arg" in
        --no-packages) SKIP_PACKAGES=1 ;;
        --no-configs)  SKIP_CONFIGS=1 ;;
        --no-system)   SKIP_SYSTEM=1 ;;
    esac
done

# ── 1. Check OS ────────────────────────────────────────────────────────────────
[[ -f /etc/arch-release ]] || error "This installer is for Arch Linux only."

step "── 2. AUR helper ────────────────────────────────────────────────────────"
if ! command -v yay &>/dev/null; then
    info "Installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin && makepkg -si --noconfirm
    cd "$DOTFILES_DIR"
fi

# ── 3. Packages ────────────────────────────────────────────────────────────────
if [[ $SKIP_PACKAGES -eq 0 ]]; then
    step "── 3. Packages ──────────────────────────────────────────────────────────"

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
        fish kitty foot starship fastfetch neofetch

        # Bar / launcher / notifications
        waybar dunst rofi fuzzel

        # Neovim
        neovim

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
        papirus-icon-theme

        # Tools
        git github-cli fzf parallel pacman-contrib udiskie
        gnome-keyring polkit-gnome flatpak

        # Apps
        tty-clock
    )

    AUR_PKGS=(
        # illogical-impulse / Quickshell
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

        # Extras
        swayosd-git
        wf-recorder
        zen-browser-bin
        waybar-git
    )

    sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}" || warn "Some pacman packages failed"
    yay -S --needed --noconfirm "${AUR_PKGS[@]}" || warn "Some AUR packages failed"

    # Flatpak — Firefox
    info "Installing Firefox via Flatpak..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install --noninteractive flathub org.mozilla.firefox || warn "Firefox Flatpak failed"
    xdg-settings set default-web-browser org.mozilla.firefox.desktop 2>/dev/null || true
fi

# ── 4. System configs ──────────────────────────────────────────────────────────
if [[ $SKIP_SYSTEM -eq 0 && -d "$DOTFILES_DIR/system" ]]; then
    step "── 4. System configs ────────────────────────────────────────────────────"

    if [[ -f "$DOTFILES_DIR/system/pacman.conf" ]]; then
        info "Applying pacman.conf..."
        sudo cp "$DOTFILES_DIR/system/pacman.conf" /etc/pacman.conf
    fi

    if [[ -f "$DOTFILES_DIR/system/environment" ]]; then
        info "Applying /etc/environment..."
        sudo cp "$DOTFILES_DIR/system/environment" /etc/environment
    fi

    if [[ -f "$DOTFILES_DIR/system/locale.conf" ]]; then
        info "Applying locale.conf..."
        sudo cp "$DOTFILES_DIR/system/locale.conf" /etc/locale.conf
    fi
fi

# ── 5. Home dotfiles ───────────────────────────────────────────────────────────
if [[ $SKIP_CONFIGS -eq 0 && -d "$DOTFILES_DIR/home" ]]; then
    step "── 5. Home dotfiles ─────────────────────────────────────────────────────"

    for f in bashrc bash_profile profile gitconfig gtkrc-2.0 Xresources; do
        src="$DOTFILES_DIR/home/.$f"
        [[ -f "$DOTFILES_DIR/home/$f" ]] && src="$DOTFILES_DIR/home/$f"
        # also try without dot
        [[ ! -f "$src" ]] && src="$DOTFILES_DIR/home/.$f"
        [[ -f "$src" ]] || continue
        dst="$HOME/.$f"
        [[ -e "$dst" ]] && mv "$dst" "${dst}.bak"
        cp "$src" "$dst"
        info "Installed $dst"
    done
fi

# ── 6. XDG configs ────────────────────────────────────────────────────────────
if [[ $SKIP_CONFIGS -eq 0 ]]; then
    step "── 6. XDG configs (~/.config) ──────────────────────────────────────────"

    backup_and_copy() {
        local src="$1" dst="$2"
        if [[ -e "$dst" && ! -L "$dst" ]]; then
            warn "Backup: $dst → ${dst}.bak"
            mv "$dst" "${dst}.bak"
        fi
        mkdir -p "$(dirname "$dst")"
        cp -r "$src" "$dst"
        info "Installed $(basename "$dst")"
    }

    CONFIG_DIRS=(
        hypr quickshell kitty fish fastfetch
        foot fuzzel dunst rofi waybar nvim
        gtk-3.0 gtk-4.0 illogical-impulse
        qt5ct qt6ct
    )

    for dir in "${CONFIG_DIRS[@]}"; do
        [[ -d "$DOTFILES_DIR/configs/$dir" ]] && \
            backup_and_copy "$DOTFILES_DIR/configs/$dir" "$HOME/.config/$dir"
    done

    # starship.toml
    if [[ -f "$DOTFILES_DIR/configs/starship.toml" ]]; then
        cp "$DOTFILES_DIR/configs/starship.toml" "$HOME/.config/starship.toml"
        info "Installed starship.toml"
    fi

    # ── 7. Firefox chrome ──────────────────────────────────────────────────────
    step "── 7. Firefox chrome ────────────────────────────────────────────────────"
    FF_PROFILE=$(find ~/.var/app/org.mozilla.firefox/config/mozilla/firefox \
        -maxdepth 1 -name "*.default-release" 2>/dev/null | head -1)

    if [[ -n "$FF_PROFILE" ]]; then
        [[ -f "$DOTFILES_DIR/firefox/user.js" ]] && \
            cp "$DOTFILES_DIR/firefox/user.js" "$FF_PROFILE/user.js"
        if [[ -d "$DOTFILES_DIR/firefox/themes" ]]; then
            mkdir -p "$FF_PROFILE/chrome"
            cp -r "$DOTFILES_DIR/firefox/themes/"* "$FF_PROFILE/chrome/" 2>/dev/null || true
        fi
        info "Firefox profile updated: $FF_PROFILE"
    else
        warn "Firefox profile not found — launch Firefox once, then re-run."
    fi
fi

# ── 8. Shell ───────────────────────────────────────────────────────────────────
step "── 8. Default shell ─────────────────────────────────────────────────────"
FISH_BIN="$(command -v fish 2>/dev/null || true)"
if [[ -n "$FISH_BIN" && "$SHELL" != "$FISH_BIN" ]]; then
    info "Setting fish as default shell..."
    grep -qF "$FISH_BIN" /etc/shells || echo "$FISH_BIN" | sudo tee -a /etc/shells
    chsh -s "$FISH_BIN"
fi

# ── 9. Services ────────────────────────────────────────────────────────────────
step "── 9. User services ─────────────────────────────────────────────────────"
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true
systemctl --user enable --now waybar 2>/dev/null || true

# ── 10. Auto-backup timer ─────────────────────────────────────────────────────
step "── 10. Daily backup timer ───────────────────────────────────────────────"
[[ -x "$DOTFILES_DIR/backup.sh" ]] && "$DOTFILES_DIR/backup.sh" --install-timer

info ""
info "✅  BloodDots installed!"
info "    → Reboot or re-login to start Hyprland."
info "    → On first login: hyprctl reload"
