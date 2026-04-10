#!/bin/bash

proxmox_deploy() {
    local deploy_script="$1"
    local success_fn="$2"
    local error_fn="$3"

    if [ -f "$deploy_script" ]; then
        chmod +x "$deploy_script"
        "$deploy_script"
        "$success_fn" "Terraform deployment completed"
    else
        "$error_fn" "Deploy script not found at "$deploy_script""
    fi
}

proxmox_deploy "$PROXMOX_DEPLOY_SCRIPT" success error