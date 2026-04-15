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
# Pi-Hole Server
#================
module "pihole_server" {
  source = "../modules/proxmox-vm"

  vmid           = 405
  vm_name        = "Pi-hole"
  target_node    = var.proxmox_node
  clone_template = var.vm_template
  display_type   = var.display_type

  cpu_cores    = 2
  memory_mb    = 4096
  disk_size_gb = 15
  storage_pool = var.storage_pool

  network_bridge = var.network_bridge
  ip_address     = "${local.network_base}.91/24"
  gateway        = "${local.network_base}.1"
  nameserver     = var.nameserver

  ciuser         = var.ciuser
  cipassword     = var.cipassword
  ssh_public_key = join("\n", var.ssh_public_key)
  tags           = var.environment

  description = "Pi-hole Server - ${local.environment}"
}