#!/usr/bin/env bash
# =============================================================================
#  dotfiles backup — syncs current configs → git repo → GitHub
#  Run manually:        bash backup.sh
#  Install timer:       bash backup.sh --install-timer
#  Remove timer:        bash backup.sh --remove-timer
# =============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info() { echo -e "${GREEN}[backup]${NC} $*"; }
warn() { echo -e "${YELLOW}[backup]${NC} $*"; }

# ── Install / remove systemd timer ────────────────────────────────────────────
if [[ "$1" == "--install-timer" ]]; then
    UNIT_DIR="$HOME/.config/systemd/user"
    mkdir -p "$UNIT_DIR"

    cat > "$UNIT_DIR/dotfiles-backup.service" <<EOF
[Unit]
Description=Daily dotfiles backup to GitHub

[Service]
Type=oneshot
ExecStart=/bin/bash $DOTFILES_DIR/backup.sh
EOF

    cat > "$UNIT_DIR/dotfiles-backup.timer" <<EOF
[Unit]
Description=Run dotfiles backup daily at 03:00

[Timer]
OnCalendar=*-*-* 03:00:00
Persistent=true
Unit=dotfiles-backup.service

[Install]
WantedBy=timers.target
EOF

    systemctl --user daemon-reload
    systemctl --user enable --now dotfiles-backup.timer
    echo -e "${GREEN}[backup]${NC} Timer installed — runs daily at 03:00"
    exit 0
fi

if [[ "$1" == "--remove-timer" ]]; then
    systemctl --user disable --now dotfiles-backup.timer 2>/dev/null || true
    rm -f "$HOME/.config/systemd/user/dotfiles-backup."{service,timer}
    systemctl --user daemon-reload
    echo "Timer removed."
    exit 0
fi

# ── Sync configs → repo ───────────────────────────────────────────────────────
info "Syncing configs..."

sync_config() {
    local name="$1"
    local src="$HOME/.config/$name"
    local dst="$DOTFILES_DIR/configs/$name"
    if [[ -d "$src" ]]; then
        rsync -a --delete \
            --exclude='__pycache__' \
            --exclude='*.pyc' \
            --exclude='.cache' \
            "$src/" "$dst/"
    fi
}

for dir in hypr quickshell kitty fish fastfetch foot fuzzel dunst rofi \
           gtk-3.0 gtk-4.0 illogical-impulse qt5ct qt6ct; do
    sync_config "$dir"
done

# Firefox
FF_PROFILE=$(find ~/.var/app/org.mozilla.firefox/config/mozilla/firefox \
    -maxdepth 1 -name "*.default-release" 2>/dev/null | head -1)
if [[ -n "$FF_PROFILE" ]]; then
    cp "$FF_PROFILE/user.js" "$DOTFILES_DIR/firefox/user.js" 2>/dev/null || true
    rsync -a --delete \
        ~/.var/app/org.mozilla.firefox/config/mozilla/firefox/firefox-themes/ \
        "$DOTFILES_DIR/firefox/themes/" 2>/dev/null || true
fi

# ── Git commit & push ─────────────────────────────────────────────────────────
cd "$DOTFILES_DIR"

if [[ -z "$(git status --porcelain)" ]]; then
    info "Nothing changed — skipping commit."
    exit 0
fi

git add -A
git commit -m "backup: $(date '+%Y-%m-%d %H:%M')"
git push origin main && info "Pushed to GitHub ✓" || warn "Push failed — check SSH key / network"
