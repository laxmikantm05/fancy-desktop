#!/bin/bash
# ─────────────────────────────────────────
#  Package Manager Detector & Script Runner
# ─────────────────────────────────────────

# ── Colors ────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RESET='\033[0m'

# ── Logging ───────────────────────────────
LOG_FILE="./setup_$(date +%Y%m%d_%H%M%S).log"
log()   { echo -e "${GREEN}[INFO]${RESET}  $*" | tee -a "$LOG_FILE"; }
warn()  { echo -e "${YELLOW}[WARN]${RESET}  $*" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}[ERROR]${RESET} $*" | tee -a "$LOG_FILE"; exit 1; }

# ── Detection ─────────────────────────────
detect_package_manager() {
    if command -v apt &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    else
        echo "unknown"
    fi
}

# ── Your Scripts ──────────────────────────
run_apt_script() {
    log "Running apt-based script..."
    # ┌─────────────────────────────────────┐
    # │       YOUR APT SCRIPT GOES HERE     │
    # └─────────────────────────────────────┘

    sudo apt update && sudo apt upgrade -y
    sudo apt install -y curl git fish fastfetch gnome-extensions-app pipx 

}

run_dnf_script() {
    log "Running dnf-based script..."
    # ┌─────────────────────────────────────┐
    # │       YOUR DNF SCRIPT GOES HERE     │
    # └─────────────────────────────────────┘

    sudo dnf update
    sudo dnf install -y curl git fish fastfetch gnome-extensions-app pipx 

}

# ── Main ──────────────────────────────────
PKG_MANAGER=$(detect_package_manager)
log "Detected package manager: $PKG_MANAGER"
log "Logging to: $LOG_FILE"

case "$PKG_MANAGER" in
    apt) run_apt_script ;;
    dnf) run_dnf_script ;;
    *)   error "No supported package manager found (apt/dnf)." ;;
esac

log "Done."
