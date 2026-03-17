#!/bin/bash
# =============================================================================
#  Fancy Desktop Rice Script for Fedora + GNOME
#  modular · gum-powered · cyberpunk flavored
#  deps: gum, figlet, lolcat
# =============================================================================

# ─────────────────────────────────────────────
#  CONFIG
# ─────────────────────────────────────────────

EXTENSIONS=(
    "arcmenu@arcmenu.com"
    "blur-my-shell@aunetx"
    "just-perfection-desktop@just-perfection"
    "dash2dock-lite@icedman.github.com"
    "burn-my-windows@schneegans.github.com"
    "compiz-windows-effect@hermes83.github.com"
    "kiwi@kemma"
)

ASSETS_DIR="$HOME/fancy-desktop/assets"
DOTFILES_DIR="$ASSETS_DIR/dotfiles"
FONTS_DIR="$ASSETS_DIR/fonts"

# ─────────────────────────────────────────────
#  COLORS
# ─────────────────────────────────────────────

CYAN='\033[38;5;51m'
MAGENTA='\033[38;5;201m'
YELLOW='\033[38;5;226m'
RED='\033[38;5;196m'
GREEN='\033[38;5;82m'
DIM='\033[2m'
RESET='\033[0m'
BOLD='\033[1m'

# ─────────────────────────────────────────────
#  HELPERS
# ─────────────────────────────────────────────

banner() {
    echo ""
    if command -v lolcat &>/dev/null; then
        figlet -f standard "$1" | lolcat --freq 0.3 --seed 42
    else
        echo -e "${CYAN}${BOLD}"
        figlet -f standard "$1"
        echo -e "${RESET}"
    fi
    echo ""
}

section() {
    gum style \
        --foreground="#00eeff" \
        --border=rounded \
        --border-foreground="#00eeff" \
        --padding="0 2" \
        --margin="1 0" \
        "⚡ $1"
}

success() { gum style --foreground="#00c878" "  ✓ $1"; }
skip()    { gum style --foreground="#888888" "  ─ skipping: $1"; }
fail()    { gum style --foreground="#ff2d5a" "  ✗ $1"; }
info()    { gum style --foreground="#3399ff" "  → $1"; }

confirm() {
    gum confirm "$1" \
        --prompt.foreground="#00eeff" \
        --selected.background="#00eeff"
}

# Shows a gum spinner while running a background command
run_spin() {
    local label="$1"; shift
    gum spin --spinner dot --title "$label" -- "$@"
}

# Streams command output through gum pager / live output
run_with_output() {
    local label="$1"; shift
    info "$label"
    "$@"
}

# Runs a command directly (interactive — e.g. sudo installers)
run_direct() {
    local label="$1"; shift
    info "$label"
    "$@"
}

# ─────────────────────────────────────────────
#  SUDO PRIME  (cache credentials up front)
# ─────────────────────────────────────────────

prime_sudo() {
    info "caching sudo credentials"
    sudo -v
    # Keep sudo alive for the duration of the script
    ( while true; do sudo -n true; sleep 50; done ) &
    SUDO_KEEPALIVE_PID=$!
    trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT
}

# ─────────────────────────────────────────────
#  INSTALL GUM  (Charmbracelet COPR — Fedora)
# ─────────────────────────────────────────────

install_gum() {
    if command -v gum &>/dev/null; then return; fi

    echo -e "${CYAN}installing gum...${RESET}"

    # Enable the official Charmbracelet COPR and install
    sudo dnf copr enable -y charmbracelet/charmbracelet
    sudo dnf install -y gum

    # Also grab figlet and lolcat while we're here
    sudo dnf install -y figlet
    # lolcat: available in RPM Fusion or via gem
    if ! command -v lolcat &>/dev/null; then
        if sudo dnf install -y lolcat 2>/dev/null; then
            : # installed from repos
        elif command -v gem &>/dev/null; then
            sudo gem install lolcat
        fi
    fi
}

# ─────────────────────────────────────────────
module_system_update() {
    section "System Update"
    if confirm "Run full system update?"; then
        run_with_output "updating system packages" \
            sudo dnf upgrade -y --refresh
        success "system updated"
    else
        skip "system update"
    fi
}

# ─────────────────────────────────────────────
module_shell() {
    section "Shell Setup"
    if confirm "Install Zsh + Oh-My-Zsh?"; then
        run_with_output "installing zsh" sudo dnf install -y zsh util-linux-user
        run_with_output "installing oh-my-zsh" \
            bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        run_with_output "setting zsh as default shell" chsh -s "$(which zsh)"
        success "shell configured"
    else
        skip "shell"
    fi
}

# ─────────────────────────────────────────────
module_dotfiles() {
    section "Dotfiles"
    if confirm "Apply dotfiles?"; then
        if [ -d "$DOTFILES_DIR" ]; then
            run_with_output "copying dotfiles" \
                cp -r "$DOTFILES_DIR/." "$HOME/"
            success "dotfiles applied"
        else
            fail "dotfiles directory not found at $DOTFILES_DIR"
        fi
    else
        skip "dotfiles"
    fi
}

# ─────────────────────────────────────────────
module_fonts() {
    section "Fonts"
    if confirm "Install fonts?"; then
        run_with_output "installing fonts" \
            sudo cp -r "$FONTS_DIR/." /usr/share/fonts/
        run_with_output "rebuilding font cache" fc-cache -fv
        success "fonts installed"
    else
        skip "fonts"
    fi
}

# ─────────────────────────────────────────────
module_extensions() {
    section "GNOME Extensions"
    if confirm "Install and enable GNOME extensions?"; then
        if ! command -v gext &>/dev/null; then
            # pipx is packaged in Fedora repos
            sudo dnf install -y pipx
            run_with_output "installing gnome-extensions-cli" \
                pipx install gnome-extensions-cli
            export PATH="$PATH:$HOME/.local/bin"
        fi

        for ext in "${EXTENSIONS[@]}"; do
            run_with_output "installing $ext" gext install "$ext"
        done

        for ext in "${EXTENSIONS[@]}"; do
            run_spin "enabling $ext" gext enable "$ext" 2>/dev/null
        done

        success "all extensions installed and enabled"
    else
        skip "gnome extensions"
    fi
}

# ─────────────────────────────────────────────
module_bootloader() {
    section "Bootloader Theme"
    if confirm "Install bootloader theme?"; then
        run_with_output "cloning bootloader themes" \
            git clone https://github.com/ChrisTitusTech/Top-5-Bootloader-Themes
        cd Top-5-Bootloader-Themes
        run_direct "running bootloader installer" sudo ./install.sh
        cd ..
        success "bootloader theme installed"
    else
        skip "bootloader"
    fi
}

# ─────────────────────────────────────────────
module_reboot() {
    section "All Done!"

    figlet -f standard "Fancy Desktop" | while IFS= read -r line; do
        echo -e "\033[38;5;183m${line}${RESET}"
    done
    echo ""

    gum style \
        --foreground="#00eeff" \
        --border=double \
        --border-foreground="#c060ff" \
        --padding="1 4" \
        --margin="1 0" \
        --align=center \
        "🎉 rice applied successfully" \
        "" \
        "log out or reboot for everything to take effect"

    if confirm "Reboot now?"; then
        gum style --foreground="#ff2d5a" "  rebooting... see you on the other side!"
        sleep 1
        sudo reboot
    else
        gum style --foreground="#888888" "  okay! log out and back in when ready."
    fi
}

# =============================================================================
#  MAIN
# =============================================================================

main() {
    clear
    install_gum

    figlet -f standard "Fancy Desktop" | while IFS= read -r line; do
        echo -e "\033[38;5;183m${line}${RESET}"
    done
    echo ""

    gum style \
        --foreground="#888888" \
        --margin="0 2" \
        "fedora · gnome · cyberpunk edition"   # ← updated
    echo ""

    prime_sudo

    module_system_update
    module_shell
    module_dotfiles
    module_fonts
    module_extensions
    module_bootloader
    module_reboot
}

main
