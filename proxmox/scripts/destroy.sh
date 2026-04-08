#!/bin/bash

# Terraform Proxmox Destroy Script
# Usage: ./scripts/destroy.sh [environment] [options]

set -e  # Exit on any error

# Default values
ENVIRONMENT="dev"
AUTO_APPROVE=false
TARGET=""
PLAN_ONLY=false
VERBOSE=false
WORKING_DIR=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [ENVIRONMENT] [OPTIONS]

ENVIRONMENT:
    dev         Destroy development environment (default)
    staging     Destroy staging environment
    prod        Destroy production environment

OPTIONS:
    -a, --auto-approve      Auto approve the destroy (skip confirmation)
    -t, --target RESOURCE   Destroy only specific resource (e.g., module.web_servers[0])
    -p, --plan-only         Only run terraform plan -destroy
    -v, --verbose           Enable verbose output
    -w, --working-dir       Specify working directory (default: environments/ENVIRONMENT)
    -h, --help             Show this help message

Examples:
    $0                                    # Destroy dev environment
    $0 staging                           # Destroy staging environment
    $0 prod --plan-only                  # Only plan prod destruction
    $0 dev --target module.web_servers   # Destroy only web servers
    $0 prod --auto-approve               # Destroy prod without confirmation

WARNING: This script will DESTROY infrastructure. Use with caution!
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        dev|dev_services|prod)
            ENVIRONMENT="$1"
            shift
            ;;
        -a|--auto-approve)
            AUTO_APPROVE=true
            shift
            ;;
        -t|--target)
            TARGET="$2"
            shift 2
            ;;
        -p|--plan-only)
            PLAN_ONLY=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -w|--working-dir)
            WORKING_DIR="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Set working directory if not specified
if [[ -z "$WORKING_DIR" ]]; then
    WORKING_DIR="environments/$ENVIRONMENT"
fi

# Check if working directory exists
if [[ ! -d "$WORKING_DIR" ]]; then
    print_error "Working directory '$WORKING_DIR' does not exist"
    exit 1
fi

# Function to run terraform command with proper error handling
run_terraform() {
    local cmd="$1"
    print_status "Running: terraform $cmd"
    
    if [[ "$VERBOSE" == "true" ]]; then
        terraform $cmd
    else
        terraform $cmd > /tmp/terraform_destroy_output.log 2>&1 || {
            print_error "Terraform command failed. Output:"
            cat /tmp/terraform_destroy_output.log
            exit 1
        }
    fi
}

# Function to validate environment for production
validate_production() {
    if [[ "$ENVIRONMENT" == "prod" ]]; then
        print_error "⚠️  DANGER: You are about to DESTROY PRODUCTION infrastructure! ⚠️"
        echo ""
        print_warning "This action will permanently delete all resources in the production environment."
        print_warning "This includes VMs, networks, and all data stored on them."
        echo ""
        echo -n "Type 'DESTROY PRODUCTION' (exactly) to confirm: "
        read -r confirmation
        if [[ "$confirmation" != "DESTROY PRODUCTION" ]]; then
            print_status "Destruction cancelled"
            exit 0
        fi
        
        echo ""
        echo -n "Are you absolutely sure? Type 'yes' one more time: "
        read -r final_confirmation
        if [[ "$final_confirmation" != "yes" ]]; then
            print_status "Destruction cancelled"
            exit 0
        fi
    else
        print_warning "You are about to DESTROY the $ENVIRONMENT environment!"
        if [[ -n "$TARGET" ]]; then
            print_warning "Target resource: $TARGET"
        else
            print_warning "This will destroy ALL resources in this environment."
        fi
        echo -n "Are you sure you want to continue? (type 'yes' to confirm): "
        read -r confirmation
        if [[ "$confirmation" != "yes" ]]; then
            print_status "Destruction cancelled"
            exit 0
        fi
    fi
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed or not in PATH"
        exit 1
    fi
    
    # Check if terraform state exists
    if [[ ! -f "$WORKING_DIR/terraform.tfstate" ]] && [[ ! -f "$WORKING_DIR/.terraform/terraform.tfstate" ]]; then
        print_warning "No terraform state found. Nothing to destroy."
        exit 0
    fi
    
    print_success "Prerequisites check passed"
}

# Function to backup current state
backup_state() {
    if [[ -f "$WORKING_DIR/terraform.tfstate" ]]; then
        local backup_dir="$WORKING_DIR/backups"
        local timestamp=$(date +"%Y%m%d_%H%M%S")
        local backup_file="$backup_dir/terraform.tfstate.backup.destroy.$timestamp"
        
        mkdir -p "$backup_dir"
        cp "$WORKING_DIR/terraform.tfstate" "$backup_file"
        print_status "State backed up to: $backup_file"
    fi
}

# Function to show current resources
show_current_resources() {
    print_status "Current resources in $ENVIRONMENT environment:"
    if terraform state list > /tmp/terraform_resources.log 2>/dev/null; then
        if [[ -s /tmp/terraform_resources.log ]]; then
            cat /tmp/terraform_resources.log | sed 's/^/  - /'
            echo ""
            print_status "Total resources: $(wc -l < /tmp/terraform_resources.log)"
        else
            print_status "No resources found in state"
            exit 0
        fi
    else
        print_warning "Could not list resources"
    fi
}

# Function to create destroy plan
create_destroy_plan() {
    print_status "Creating destruction plan..."
    
    local plan_cmd="plan -destroy"
    if [[ -n "$TARGET" ]]; then
        plan_cmd="$plan_cmd -target=$TARGET"
    fi
    plan_cmd="$plan_cmd -out=destroy.tfplan"
    
    if [[ "$VERBOSE" == "true" ]]; then
        terraform $plan_cmd
    else
        terraform $plan_cmd > /tmp/terraform_destroy_plan.log 2>&1
        print_status "Destroy plan created. Use -v flag to see full output."
    fi
}

# Function to apply destroy plan
apply_destroy_plan() {
    if [[ "$AUTO_APPROVE" == "true" ]]; then
        print_status "Auto-applying destruction plan..."
        run_terraform "apply destroy.tfplan"
    else
        print_status "Applying destruction plan..."
        terraform apply destroy.tfplan
    fi
}

# Function to cleanup after destroy
cleanup_after_destroy() {
    # Remove plan file
    rm -f destroy.tfplan
    
    # Check if any resources remain
    if terraform state list > /tmp/remaining_resources.log 2>/dev/null; then
        if [[ -s /tmp/remaining_resources.log ]]; then
            print_warning "Some resources may still exist:"
            cat /tmp/remaining_resources.log | sed 's/^/  - /'
        else
            print_success "All resources have been destroyed"
        fi
    fi
}

# Main destroy function
main() {
    if [[ -n "$TARGET" ]]; then
        print_status "Starting targeted destruction of '$TARGET' in environment: $ENVIRONMENT"
    else
        print_status "Starting complete destruction of environment: $ENVIRONMENT"
    fi
    print_status "Working directory: $WORKING_DIR"
    
    # Change to working directory
    cd "$WORKING_DIR"
    
    # Run checks
    check_prerequisites
    
    # Initialize Terraform (in case modules have changed)
    print_status "Initializing Terraform..."
    run_terraform "init"
    
    # Show current resources
    show_current_resources
    
    # Validate and confirm destruction
    validate_production
    
    # Backup state before destroying
    backup_state
    
    # Create destroy plan
    create_destroy_plan
    
    # If plan-only mode, stop here
    if [[ "$PLAN_ONLY" == "true" ]]; then
        print_success "Plan-only mode completed"
        if [[ "$VERBOSE" != "true" ]]; then
            print_status "Destroy plan details:"
            cat /tmp/terraform_destroy_plan.log
        fi
        rm -f destroy.tfplan
        exit 0
    fi
    
    # Apply the destroy plan
    apply_destroy_plan
    
    # Cleanup and final status
    cleanup_after_destroy
    
    if [[ -n "$TARGET" ]]; then
        print_success "Target resource '$TARGET' destroyed successfully!"
    else
        print_success "Environment '$ENVIRONMENT' destroyed successfully!"
    fi
}

# Trap to clean up on exit
trap 'rm -f destroy.tfplan /tmp/terraform_*.log' EXIT

# Run main function
main