#======================
# Proxmox Configuration
#======================
// Proxmox provider variables
variable "proxmox_api_url" {
  type        = string
  description = "Proxmox API URL"
}

// Proxmox API token variables
variable "proxmox_api_token_id" {
  type        = string
  default     = "terraform@pve"
  description = "Promox API token Id"
}

// Proxmox API token secret variable
variable "proxmox_api_token_secret" {
  type        = string
  sensitive   = true
  description = "Promox API token secret"
}

// Proxmox TLS insecure variable
variable "proxmox_tls_insecure" {
  type        = bool
  description = "Skip TLS verification"
  default     = true
}

#===========================
# Proxmox Node Configuration
#===========================
// Proxmox node name variable
variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
  default     = "pve1"
}

// Environment name variable
variable "environment" {
  type        = string
  default     = "k8s-cluster"
  description = "Environment name"
}

#=================
# VM Configuration
#=================

// VM template variable
variable "vm_template" {
  description = "VM template to clone from"
  type        = string
  default     = "ubuntu-cloud"
}

// Cloud init user variables
variable "ciuser" {
  type        = string
  default     = "jso"
  description = "Cloud init username"
}

// Cloud init user password variable
variable "cipassword" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Cloud init user password"
}

// Storage pool variable
variable "storage_pool" {
  description = "Storage pool name"
  type        = string
  default     = "SlowZ1"
}

// Network bridge variable
variable "network_bridge" {
  description = "Network bridge"
  type        = string
  default     = "vmbr1"
}

// DNS nameserver variable
variable "nameserver" {
  description = "DNS servers"
  type        = string
  default     = "1.1.1.1,1.0.0.1"
}

// Display type variable
variable "display_type" {
  type        = string
  default     = "virtio-gl"
  description = "Display type (serial, std, virtio-gl, etc.)"
}

// SSH public key variable
variable "ssh_public_key" {
  type        = list(string)
  sensitive   = true
  description = "SSH public key for VM access"
}

#======================
# Project Configuration
#======================
variable "project_name" {
  type        = string
  default     = "proxmox-infra"
  description = "Project name for resource naming"
}


