#!/bin/bash

# Load shared functions
source "$(dirname "$0")/ui.sh"

update_apt() {
    local deploy_script="$1"
    local success_fn="$2"
    local error_fn="$3"

    # Code here
}

update_apt "$1" success error