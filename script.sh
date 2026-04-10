#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
SERVICES_DIR="$SCRIPT_DIR/services"
PROXMOX_DEPLOY_SCRIPT="$SERVICES_DIR/proxmox/scripts/deploy.sh"

# Reset terminal colors on exit or crash
trap 'echo -ne "\033[0m"' EXIT

# Options
OPTIONS=(
    "Setup Proxmox cronjob"
    "Deploy proxmox VMs with terraform"
    "Update apt packages"
    "Setup Proxmox networking"
    "Backup plan"
    "Install kubenetes"
)

# ─────────────────────────────────────────────────────────────────────────────
#  Theme Palette
# ─────────────────────────────────────────────────────────────────────────────

C_MAIN='\033[38;2;202;169;224m'
C_ACCENT='\033[38;2;145;177;240m'
C_DIM='\033[38;2;129;122;150m'
C_GREEN='\033[38;2;166;209;137m'
C_YELLOW='\033[38;2;229;200;144m'
C_RED='\033[38;2;231;130;132m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

header() {
    clear
    echo -e "${C_MAIN}${C_BOLD}"
    echo " ╭──────────────────────────────────────────╮"
    echo " │           󱓞 HOME EDGE SETUP 󱓞            │"
    echo " ╰──────────────────────────────────────────╯"
    echo -e "${C_RESET}"
}

info() {
    echo -e "${C_MAIN}${C_BOLD} ╭─ 󰓅 $1${C_RESET}"
}

substep() {
    echo -e "${C_MAIN}${C_BOLD} │  ${C_DIM}❯ ${C_RESET}$1"
}

success() {
    echo -e "${C_MAIN}${C_BOLD} ╰─ ${C_GREEN}✔ ${C_RESET}$1\n"
}

error() {
    echo -e "${C_MAIN}${C_BOLD} ╰─ ${C_RED}✘ ${C_RESET}$1\n"
}

# ─────────────────────────────────────────────────────────────────────────────
#  Core Logic
# ─────────────────────────────────────────────────────────────────────────────

header

# Dependency check
info "Checking dependecies..."
success "Dependencies verified"

# Selection Logic
info "Selecting a service..."

for i in "${!OPTIONS[@]}"; do
    echo -e "${C_MAIN}${C_BOLD} │  ${C_ACCENT}$((i+1)) ${C_DIM}❯ ${C_RESET}${OPTIONS[$i]}"
done
echo -ne "${C_MAIN}${C_BOLD} ╰─ ${C_YELLOW}Choice: ${C_RESET}"
read -rp "" SELECTION

case $SELECTION in 
    1)
        info "Setting up Proxmox cronjob..."
        # Call cronjob
        ;;
    2)
        info "Deploying Proxmox VMs with Terraform..."

        if [ -f "$PROXMOX_DEPLOY_SCRIPT" ]; then
            chmod +x "$PROXMOX_DEPLOY_SCRIPT"
            $PROXMOX_DEPLOY_SCRIPT
            success "Terraform deployment completed"
        else
            error "Deploy script not found at $PROXMOX_DEPLOY_SCRIPT"
        fi
        ;;
    3)
        info "Updating apt packages"
        ;;
    4)
        info "Setting up Proxmox networking"
        ;;
    5)
        info "Backing up plan"
        ;;
    6)
        info "Installing kubenetes"
        ;;
    *)
        error "Invalid selection"
        ;;
esac
