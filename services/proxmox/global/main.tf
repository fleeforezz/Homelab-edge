locals {
  environment  = "sv"
  network_base = "10.0.1"
  common_tags = {
    Environment = local.environment
    Managed_by  = "terraform"
  }
}

terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = var.proxmox_tls_insecure
}

#================
# Global Server
#================
module "monitoring_server" {
  source = "../modules/proxmox-vm"

  vmid           = 300
  vm_name        = "Monitoring"
  target_node    = var.proxmox_node
  clone_template = var.vm_template
  display_type   = var.display_type

  cpu_cores    = 8
  memory_mb    = 8192
  disk_size_gb = 32
  storage_pool = var.storage_pool

  network_bridge = var.network_bridge
  ip_address     = "${local.network_base}.75/24"
  gateway        = "${local.network_base}.1"
  nameserver     = var.nameserver

  ciuser         = var.ciuser
  cipassword     = var.cipassword
  ssh_public_key = join("\n", var.ssh_public_key)
  tags           = var.environment

  description = "Monitoring Server - ${local.environment}"
}