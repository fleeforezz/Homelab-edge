# Proxmox Infrastructure Management

This repository contains Terraform configurations for managing Proxmox VE infrastructure across multiple environments.

## Structure
- `global/` - Global configuration and providers
- `environments/` - Environment-specific configurations
- `modules/` - Reusable Terraform modules
- `scripts/` - Deployment and management scripts

## Quick Start
1. Copy terraform.tfvars.example to terraform.tfvars in desired environment
2. Configure your Proxmox credentials and SSH keys
3. Deploy: ` bash ./scripts/deploy.sh k8s-clusters`

## Environments
- **k8s-clusters** - Kubernetes Cluster environment (10.0.1.x)
- **standalone-docker-vms** - Standalone docker Vms environment (10.0.1.x)
- **standalone-vms** - Standalone Vms environment (10.0.3.x)

See `docs/` for detailed documentation.

Install jq if system not already installed
```sh
sudo apt update
sudo apt install jq
```