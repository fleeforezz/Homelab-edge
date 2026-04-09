locals {
  environment  = "standalone-docker-vms"
  network_base = "10.0.10"
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

#=========================
# Personal Service Server
#=========================
module "per_server" {
  source = "../../modules/proxmox-vm"

  vmid           = 301
  vm_name        = "Personal-services"
  target_node    = var.proxmox_node
  clone_template = var.vm_template
  display_type   = var.display_type

  cpu_cores    = 8
  memory_mb    = 16384
  disk_size_gb = 32
  storage_pool = var.storage_pool

  network_bridge = var.network_bridge
  vlan-tag       = var.vlan_id
  ip_address     = "${local.network_base}.70/24"
  gateway        = "${local.network_base}.1"
  nameserver     = var.nameserver

  ciuser         = var.ciuser
  cipassword     = var.cipassword
  ssh_public_key = join("\n", var.ssh_public_key)
  tags           = var.environment

  description = "Personal Service Server - ${local.environment}"
}

#=================
# Databases Server
#=================
module "database_server" {
  source = "../../modules/proxmox-vm"

  vmid           = 302
  vm_name        = "Databases"
  target_node    = var.proxmox_node
  clone_template = var.vm_template
  display_type   = var.display_type

  cpu_cores    = 4
  memory_mb    = 8192
  disk_size_gb = 15
  storage_pool = var.storage_pool

  network_bridge = var.network_bridge
  vlan-tag       = var.vlan_id
  ip_address     = "${local.network_base}.71/24"
  gateway        = "${local.network_base}.1"
  nameserver     = var.nameserver

  ciuser         = var.ciuser
  cipassword     = var.cipassword
  ssh_public_key = join("\n", var.ssh_public_key)
  tags           = var.environment

  description = "Databases Server - ${local.environment}"
}

#==================
# S3 Storage Server
#==================
module "s3_storage_server" {
  source = "../../modules/proxmox-vm"

  vmid           = 304
  vm_name        = "S3-storage"
  target_node    = var.proxmox_node
  clone_template = var.vm_template
  display_type   = var.display_type

  cpu_cores    = 4
  memory_mb    = 8192
  disk_size_gb = 15
  storage_pool = var.storage_pool

  network_bridge = var.network_bridge
  vlan-tag       = var.vlan_id
  ip_address     = "${local.network_base}.72/24"
  gateway        = "${local.network_base}.1"
  nameserver     = var.nameserver

  ciuser         = var.ciuser
  cipassword     = var.cipassword
  ssh_public_key = join("\n", var.ssh_public_key)
  tags           = var.environment

  description = "S3 Storage Server - ${local.environment}"
}

#===================
# Development Server
#===================
module "development_server" {
  source = "../../modules/proxmox-vm"

  vmid           = 304
  vm_name        = "Development"
  target_node    = var.proxmox_node
  clone_template = var.vm_template
  display_type   = var.display_type

  cpu_cores    = 8
  memory_mb    = 8192
  disk_size_gb = 50
  storage_pool = var.storage_pool

  network_bridge = var.network_bridge
  vlan-tag       = var.vlan_id
  ip_address     = "${local.network_base}.73/24"
  gateway        = "${local.network_base}.1"
  nameserver     = var.nameserver

  ciuser         = var.ciuser
  cipassword     = var.cipassword
  ssh_public_key = join("\n", var.ssh_public_key)
  tags           = var.environment

  description = "Development Server - ${local.environment}"
}

#===================
# Reverse Proxy Server
#===================
module "reverse_proxy_server" {
  source = "../../modules/proxmox-vm"

  vmid           = 305
  vm_name        = "Reverse-proxy"
  target_node    = var.proxmox_node
  clone_template = var.vm_template
  display_type   = var.display_type

  cpu_cores    = 4
  memory_mb    = 4096
  disk_size_gb = 32
  storage_pool = var.storage_pool

  network_bridge = var.network_bridge
  vlan-tag       = var.vlan_id
  ip_address     = "${local.network_base}.74/24"
  gateway        = "${local.network_base}.1"
  nameserver     = var.nameserver

  ciuser         = var.ciuser
  cipassword     = var.cipassword
  ssh_public_key = join("\n", var.ssh_public_key)
  tags           = var.environment

  description = "Reverse Proxy Server - ${local.environment}"
}