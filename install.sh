#!/bin/bash

# ============================================================
# install.sh
# Fresh Arch Linux setup script for AREMSU's dotfiles
# Repo: https://github.com/AREMSU/dot_files
#
# Usage:
#   chmod +x install.sh
#   ./install.sh
# ============================================================

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()    { echo -e "${GREEN}[✓]${NC} $1"; }
warn()   { echo -e "${YELLOW}[!]${NC} $1"; }
error()  { echo -e "${RED}[✗]${NC} $1"; }
header() { echo -e "\n${BLUE}===== $1 =====${NC}\n"; }

header "AREMSU Dotfiles Install Script"

echo "This script will:"
echo "  - Install yay (AUR helper)"
echo "  - Install all packages from packages.txt and packages-aur.txt"
echo "  - Set up zsh with oh-my-zsh and powerlevel10k"
echo "  - Symlink all config files into ~/.config"
echo "  - Copy wallpapers to ~/Wallpapers"
echo "  - Set up SSH agent in .zshrc"
echo "  - Enable necessary system services"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 1

header "Updating system"
sudo pacman -Syu --noconfirm
log "System updated"

header "Installing yay"
if ! command -v yay &>/dev/null; then
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm
    cd "$REPO_DIR"
    log "yay installed"
else
    log "yay already installed"
fi

header "Installing official packages"
if [[ -f "$REPO_DIR/packages.txt" ]]; then
    PKGS=$(awk '{print $1}' "$REPO_DIR/packages.txt" | tr '\n' ' ')
    sudo pacman -S --needed --noconfirm $PKGS
    log "Official packages installed"
else
    warn "packages.txt not found, skipping"
fi

header "Installing AUR packages"
if [[ -f "$REPO_DIR/packages-aur.txt" ]]; then
    AUR_PKGS=$(awk '{print $1}' "$REPO_DIR/packages-aur.txt" | tr '\n' ' ')
    yay -S --needed --noconfirm $AUR_PKGS
    log "AUR packages installed"
else
    warn "packages-aur.txt not found, skipping"
fi

header "Setting up zsh"
if ! command -v zsh &>/dev/null; then
    sudo pacman -S --needed --noconfirm zsh
fi

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log "oh-my-zsh installed"
else
    log "oh-my-zsh already installed"
fi

if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    log "powerlevel10k installed"
else
    log "powerlevel10k already installed"
fi

if [[ "$SHELL" != "$(which zsh)" ]]; then
    chsh -s $(which zsh)
    log "zsh set as default shell"
fi

header "Installing fonts"
yay -S --needed --noconfirm \
    ttf-jetbrains-mono-nerd \
    ttf-nunito \
    ttf-comfortaa
log "Fonts installed"

header "Symlinking config files"

symlink() {
    local src="$1"
    local dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        warn "Backing up existing $dst to $dst.bak"
        mv "$dst" "$dst.bak"
    fi
    ln -sf "$src" "$dst"
    log "Linked $dst"
}

symlink "$REPO_DIR/waybar"        "$HOME/.config/waybar"
symlink "$REPO_DIR/hypr"          "$HOME/.config/hypr"
symlink "$REPO_DIR/kitty"         "$HOME/.config/kitty"
symlink "$REPO_DIR/rofi"          "$HOME/.config/rofi"
symlink "$REPO_DIR/swaync"        "$HOME/.config/swaync"
symlink "$REPO_DIR/wlogout"       "$HOME/.config/wlogout"
symlink "$REPO_DIR/pipewire"      "$HOME/.config/pipewire"
symlink "$REPO_DIR/gtk-3.0"       "$HOME/.config/gtk-3.0"
symlink "$REPO_DIR/gtk-4.0"       "$HOME/.config/gtk-4.0"
symlink "$REPO_DIR/awww"          "$HOME/.config/awww"
symlink "$REPO_DIR/environment.d" "$HOME/.config/environment.d"
log "All configs symlinked"

header "Setting up home dotfiles"
symlink "$REPO_DIR/home/.zshrc"     "$HOME/.zshrc"
symlink "$REPO_DIR/home/.p10k.zsh"  "$HOME/.p10k.zsh"
symlink "$REPO_DIR/home/.gitconfig" "$HOME/.gitconfig"
symlink "$REPO_DIR/home/.gtkrc-2.0" "$HOME/.gtkrc-2.0"
log "Home dotfiles linked"

header "Setting up SSH agent"
if ! grep -q "ssh-agent" "$HOME/.zshrc"; then
    cat >> "$HOME/.zshrc" << 'EOF'

# SSH agent
eval $(ssh-agent) > /dev/null
ssh-add ~/.ssh/id_ed25519 2>/dev/null
EOF
    log "SSH agent added to .zshrc"
else
    log "SSH agent already in .zshrc"
fi

header "Setting up wallpapers"
mkdir -p "$HOME/Wallpapers"
if [[ -d "$REPO_DIR/Wallpapers" ]]; then
    cp -n "$REPO_DIR/Wallpapers/"* "$HOME/Wallpapers/"
    log "Wallpapers copied"
else
    warn "No Wallpapers folder found in repo"
fi

header "Setting script permissions"
chmod +x "$HOME/.config/awww/theme-switch.sh"
chmod +x "$HOME/.config/awww/theme-cycle.sh"
log "Scripts made executable"

header "Enabling system services"
systemctl --user enable pipewire
systemctl --user enable pipewire-pulse
systemctl --user enable wireplumber
log "Services enabled"

header "Setting initial wallpaper and theme"
if command -v awww &>/dev/null; then
    awww-daemon &
    sleep 1
    ~/.config/awww/theme-switch.sh ~/Wallpapers/knights.jpg
    log "Initial theme set"
else
    warn "awww not found, set wallpaper manually after reboot"
fi

header "Installation Complete!"
echo ""
echo "Things to do manually after reboot:"
echo "  1. Log into Hyprland"
echo "  2. Run 'p10k configure' if prompt looks wrong"
echo "  3. Set up SSH keys for GitHub"
echo "  4. Log into Brave, Spotify, Discord, Viber, Zoom etc"
echo "  5. Set up hyprlock PAM if lock screen doesn't work"
echo ""
log "Reboot recommended: sudo reboot"
