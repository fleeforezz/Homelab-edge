#!/bin/bash

# Load shared functions
source "$(dirname "$0")/ui.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

switch_mirror() {

    PLAYBOOK_PATH="$BASE_DIR/services/ansible/switch-mirror/playbooks.yml"
    INVENTORY_PATH="$BASE_DIR/services/ansible/switch-mirror/host.ini"

    if [ ! -f "$PLAYBOOK_PATH" ]; then
        error "Playbook not found: $PLAYBOOK_PATH"
        return 1
    fi

    if [ ! -f "$INVENTORY_PATH" ]; then
        error "Inventory not found: $INVENTORY_PATH"
        return 1
    fi

    substep "Running ansible-playbook..."
    ansible-playbook -i "$INVENTORY_PATH" "$PLAYBOOK_PATH"

    if [ $? -eq 0 ]; then
        success "Mirror switched successfully"
    else
        error "Ansible playbook failed"
        return 1
    fi
}