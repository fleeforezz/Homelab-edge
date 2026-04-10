#!/bin/bash

# Load shared functions
source "$(dirname "$0")/ui.sh"

proxmox_deploy() {
    local deploy_script="$1"
    local success_fn="$2"
    local error_fn="$3"
    local env="$4"

    if [ -f "$deploy_script" ]; then
        chmod +x "$deploy_script"
        "$deploy_script" "$env"
        "$success_fn" "Terraform deployment completed for env: $env"
    else
        "$error_fn" "Deploy script not found at $deploy_script"
    fi
}

proxmox_deploy "$1" "$2" "$3" "$4"