#!/bin/bash

set -e # Exit on any error

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Go up to proxmox root
BASE_DIR="$SCRIPT_DIR/.."

# Default values
ENVIRONMENT="${ENVIRONMENT//-/_}"
AUTO_APPROVE=false
PLAN_ONLY=false
VERBOSE=false
WORKING_DIR="$BASE_DIR/environments/$ENVIRONMENT"

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
    k8s-clusters            Deploy to development service environment
    standalone-vms          Deploy to development environment (default)
    standalone-docker-vms   Deploy to production environment

OPTIONS:
    -a, --auto-approve    Auto approve the apply (skip confirmation)
    -p, --plan-only       Only run terraform plan
    -v, --verbose         Enable verbose output
    -w, --working-dir     Specify working directory (default: environments/ENVIRONMENT)
    -h, --help           Show this help message

Examples:
    $0 k8s-clusters                              # Deploy to production
    $0 standalone-vms --plan-only                # Only plan dev deployment
    $0 standalone-docker-vms --auto-approve      # Deploy to prod without confirmation
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        k8s-clusters|standalone-vms|standalone-docker-vms)
            ENVIRONMENT="$1"
            shift
            ;;
        -a|--auto-approve)
            AUTO_APPROVE=true
            shift
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
    WORKING_DIR="./environments/$ENVIRONMENT"
fi

# Check if working directory exists
if [[ ! -d "$WORKING_DIR" ]]; then
    print_error "Working directory '$WORKING_DIR' does not exist"
    exit 1
fi

# Function to create terraform.tfvars
create_tfvars() {
    local tfvars_file="$WORKING_DIR/terraform.tfvars"

    print_warning "terraform.tfvars not found. Creating new one..."

    # ─────────────────────────────────────────
    # Prompt user input
    # ─────────────────────────────────────────

    read -rp "Proxmox API URL: " proxmox_api_url
    if [[ -z "$proxmox_api_url" ]]; then
        print_error "API URL cannot be empty"
        exit 1
    fi
    read -rp "Proxmox API Token ID: " proxmox_api_token_id
    read -rp "Proxmox API Token Secret: " proxmox_api_token_secret
    echo ""
    read -rp "TLS Insecure (true/false): " proxmox_tls_insecure
    if [[ "$proxmox_tls_insecure" != "true" && "$proxmox_tls_insecure" != "false" ]]; then
        print_error "TLS must be true or false"
        exit 1
    fi
    read -rp "Proxmox Node: " proxmox_node

    echo ""

    read -rp "VM Template: " vm_template
    read -rp "Storage Pool: " storage_pool
    read -rp "Network Bridge: " network_bridge
    read -rp "Nameserver (comma separated): " nameserver
    read -rp "Display Type: " display_type

    echo ""

    read -rp "CI User: " ciuser
    read -rp "CI Password: " cipassword

    echo ""

    echo "Enter SSH Public Keys (empty line to finish):"
    ssh_keys=()
    while true; do
        read -rp "> " key
        [[ -z "$key" ]] && break
        ssh_keys+=("$key")
    done

    echo ""

    read -rp "Project Name: " project_name

    # ─────────────────────────────────────────
    # Write file
    # ─────────────────────────────────────────

    {
        echo "proxmox_api_url          = \"$proxmox_api_url\""
        echo "proxmox_api_token_id     = \"$proxmox_api_token_id\""
        echo "proxmox_api_token_secret = \"$proxmox_api_token_secret\""
        echo "proxmox_tls_insecure     = $proxmox_tls_insecure"
        echo "proxmox_node             = \"$proxmox_node\""
        echo ""
        echo "vm_template    = \"$vm_template\""
        echo "storage_pool   = \"$storage_pool\""
        echo "network_bridge = \"$network_bridge\""
        echo "nameserver     = \"$nameserver\""
        echo "display_type   = \"$display_type\""
        echo ""
        echo "ciuser     = \"$ciuser\""
        echo "cipassword = \"$cipassword\""
        echo ""
        echo "ssh_public_key = ["
        for key in "${ssh_keys[@]}"; do
            echo "  \"$key\","
        done
        echo "]"
        echo ""
        echo "project_name = \"$project_name\""
    } > "$tfvars_file"

    print_success "terraform.tfvars created at $tfvars_file"
}

# Check if terraform.tfvars exists
if [[ ! -f "$WORKING_DIR/terraform.tfvars" ]]; then
    create_tfvars
fi

# Function to run terraform command with proper error handling
run_terraform() {
    local cmd="$1"
    print_status "Running: terraform $cmd"

    if [[ "$VERBOSE" == "true" ]]; then
        terraform -chdir="$WORKING_DIR" $cmd
    else
        terraform -chdir="$WORKING_DIR" $cmd > /tmp/terraform_output.log 2>&1 || {
            print_error "Terraform command failed. Output:"
            cat /tmp/terraform_output.log
            exit 1
        }
    fi
}

# Function to validate environment for production
# validate_production() {
#     if [[ "$ENVIRONMENT" == "prod" ]]; then
#         print_warning "You are about to deploy to PRODUCTION environment!"
#         echo -n "Are you sure you want to continue? (type 'yes' to confirm): "
#         read -r confirmation
#         if [[ "$confirmation" != "yes" ]]; then
#             print_status "Deployment cancelled"
#             exit 0
#         fi
#     fi
# }

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."

    # Check if terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed or not in PATH"
        echo -n "Do you wish to install Terraform now? (y/n): "
        read -r install_choice
        if [[ "$install_choice" == "y" || "$install_choice" == "Y" ]]; then
            print_status "Installing Terraform..."
            sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
            wget -O- https://apt.releases.hashicorp.com/gpg | \
                gpg --dearmor | \
                sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
                https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
                sudo tee /etc/apt/sources.list.d/hashicorp.list
            sudo apt install -y jq
            sudo apt-get update && sudo apt-get install -y terraform
            print_success "Terraform installed successfully"
        else
            print_error "Terraform is required to proceed. Exiting."
            exit 1
        fi
    fi

    # Check terraform version
    TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version')
    print_status "Using Terraform version: $TERRAFORM_VERSION"

    # Check if required files exist
    local required_files=("main.tf" "variables.tf")
    local missing_files=()

    for file in "${required_files[@]}"; do
        if [[ ! -f "$WORKING_DIR/$file" ]]; then
            missing_files+=("$file")
            print_error "Required file not found: $PWD/$file"
        else 
            print_status "Found required file: $file"
        fi
    done

    # Exit if any required files are missing
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        print_error "Missing ${#missing_files[@]} required file(s). Cannot proceed."
        exit 1
    fi

    print_success "Prerequisites check passed"
}

# Function to backup current state
backup_state() {
    if [[ -f "$WORKING_DIR/terraform.tfstate" ]]; then
        local backup_dir="$WORKING_DIR/backups"
        local timestamp=$(date + "%Y%m%d_%H%M%S")
        local backup_file="$backup_dir/terraform.tfstate.backup.$timestamp"

        mkdir -p "$backup_dir"
        cp "$WORKING_DIR/terraform.tfstate" "$backup_file"
        print_status "State backed up to: $backup_file"
    fi
}

# Main deployment function
main() {
    print_status "Starting Terraform deployment for environment: $ENVIRONMENT"
    print_status "Working directory: $WORKING_DIR"

    # Change to working directory
    cd "$WORKING_DIR"

    # Run checks
    check_prerequisites
    # validate_production

    # Initialize Terraform
    print_status "Initializing Terraform..."
    run_terraform "init -upgrade"
    print_success "Terraform initialized"

    # Validate configuration
    print_status "Validating Terraform configuration..."
    run_terraform "validate"
    print_success "Configuration is valid"

    # Format check
    print_status "Checking Terraform formatting..."
    if ! terraform fmt -check=true -diff=true; then
        print_warning "Code formatting issues found. Run 'terraform fmt -recursive' to fix." 
    fi

    # Create and show plan
    print_status "Creating deployment plan..."
    if [[ "$VERBOSE" == "true" ]]; then
        terraform plan -out=tfplan || {
            print_error "Failed to create plan"
            exit 1
        }
    else
        terraform plan -out=tfplan > /tmp/terraform_plan.log 2>&1 || {
            print_error "Failed to create plan. Output:"
            cat /tmp/terraform_plan.log
            exit 1
        }
        echo "Plan created successfully. Use -v flag to see full output."
    fi

    # If plan-only mode, stop here
    if [[ "$PLAN_ONLY" == "true" ]]; then
        print_success "Plan-only mode completed"
        if [[ "$VERBOSE" != "true" ]]; then
            print_status "Plan details:"
            cat /tmp/terraform_plan.log
        fi
        exit 0
    fi

    # Backup state before applying
    backup_state

    # Apply the plan
    if [[ "$AUTO_APPROVE" == "true" ]]; then
        print_status "Auto applying deployment plan..."
        run_terraform "apply tfplan"
    else 
        print_status "Applying deployment plan..."
        terraform apply tfplan
    fi

    # Clean up plan file
    rm -f tfplan

    print_success "Deployment completed successfully!"

    # Show outputs
    print_status "Deployment outputs:"
    terraform output
}

# Trap to clean up on exit
trap 'rm -f tfplan /tmp/terraform_*.log' EXIT

# Run main function
main