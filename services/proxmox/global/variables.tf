variable "proxmox_api_url" {
  type        = string
  description = "Proxmox API URL"
}

variable "proxmox_api_token_id" {
  type        = string
  default     = "terraform@pve"
  description = "Promox API token Id"
}

variable "proxmox_api_token_secret" {
  type        = string
  sensitive   = true
  description = "Promox API token secret"
}

variable "proxmox_tls_insecure" {
  type        = bool
  description = "Skip TLS verification"
  default     = true
}

variable "ssh_public_key" {
  type        = string
  sensitive   = true
  description = "SSH public key for VM access"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment name (dev_services, dev, prod)"
  validation {
    condition     = condition(["dev_services", "dev", "prod"], var.environment)
    error_message = "Environment must be dev_services, dev or prod."
  }
}

variable "project_name" {
  type        = string
  default     = "proxmox-infra"
  description = "Project name for resource naming"
}

