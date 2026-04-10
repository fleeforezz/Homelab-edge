locals {
  environment  = "k8s-clusters"
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

#==============
# K8s manager 1
#==============
module "k8s_manager_1" {
  source = "../../modules/proxmox-vm"

  vmid           = 150
  vm_name        = "k8s-manager-1"
  target_node    = var.proxmox_node
  clone_template = var.vm_template
  display_type   = var.display_type

  cpu_cores    = 4
  memory_mb    = 8192
  disk_size_gb = 32
  storage_pool = var.storage_pool

  network_bridge = var.network_bridge
  vlan-tag       = var.vlan_id
  ip_address     = "${local.network_base}.51/24"
  gateway        = "${local.network_base}.1"
  nameserver     = var.nameserver

  ciuser         = var.ciuser
  cipassword     = var.cipassword
  ssh_public_key = join("\n", var.ssh_public_key)
  tags           = var.environment

  description = "K8s manager 1 - ${local.environment}"
}

#==============
# K8s manager 2
#==============
# module "k8s_manager_2" {
#   source = "../../modules/proxmox-vm"

#   vmid           = 151
#   vm_name        = "k8s-manager-2"
#   target_node    = var.proxmox_node
#   clone_template = var.vm_template
#   display_type   = var.display_type

#   cpu_cores    = 4
#   memory_mb    = 8192
#   disk_size_gb = 32
#   storage_pool = var.storage_pool

#   network_bridge = var.network_bridge
#   ip_address     = "${local.network_base}.52/24"
#   gateway        = "${local.network_base}.1"
#   nameserver     = var.nameserver

#   ciuser         = var.ciuser
#   cipassword     = var.cipassword
#   ssh_public_key = join("\n", var.ssh_public_key)
#   tags           = var.environment

#   description = "K8s manager 2 - ${local.environment}"
# }

#==============
# K8s manager 3
#==============
# module "k8s_manager_3" {
#   source = "../../modules/proxmox-vm"

#   vmid           = 152
#   vm_name        = "k8s-manager-3"
#   target_node    = var.proxmox_node
#   clone_template = var.vm_template
#   display_type   = var.display_type

#   cpu_cores    = 4
#   memory_mb    = 8192
#   disk_size_gb = 32
#   storage_pool = var.storage_pool

#   network_bridge = var.network_bridge
#   ip_address     = "${local.network_base}.53/24"
#   gateway        = "${local.network_base}.1"
#   nameserver     = var.nameserver

#   ciuser         = var.ciuser
#   cipassword     = var.cipassword
#   ssh_public_key = join("\n", var.ssh_public_key)
#   tags           = var.environment

#   description = "K8s manager 3 - ${local.environment}"
# }

#==============
# K8s worker 1
#==============
module "k8s_worker_1" {
  source = "../../modules/proxmox-vm"

  vmid           = 153
  vm_name        = "k8s-worker-1"
  target_node    = var.proxmox_node
  clone_template = var.vm_template
  display_type   = var.display_type

  cpu_cores    = 2
  memory_mb    = 4096
  disk_size_gb = 32
  storage_pool = var.storage_pool

  network_bridge = var.network_bridge
  vlan-tag       = var.vlan_id
  ip_address     = "${local.network_base}.61/24"
  gateway        = "${local.network_base}.1"
  nameserver     = var.nameserver

  ciuser         = var.ciuser
  cipassword     = var.cipassword
  ssh_public_key = join("\n", var.ssh_public_key)
  tags           = var.environment

  description = "K8s worker 1 - ${local.environment}"
}

#==============
# K8s worker 2
#==============
module "k8s_worker_2" {
  source = "../../modules/proxmox-vm"

  vmid           = 154
  vm_name        = "k8s-worker-2"
  target_node    = var.proxmox_node
  clone_template = var.vm_template
  display_type   = var.display_type

  cpu_cores    = 2
  memory_mb    = 4096
  disk_size_gb = 32
  storage_pool = var.storage_pool

  network_bridge = var.network_bridge
  vlan-tag       = var.vlan_id
  ip_address     = "${local.network_base}.62/24"
  gateway        = "${local.network_base}.1"
  nameserver     = var.nameserver

  ciuser         = var.ciuser
  cipassword     = var.cipassword
  ssh_public_key = join("\n", var.ssh_public_key)
  tags           = var.environment

  description = "K8s worker 2 - ${local.environment}"
}

#==============
# K8s worker 3
#==============
module "k8s_worker_3" {
  source = "../../modules/proxmox-vm"

  vmid           = 155
  vm_name        = "k8s-worker-3"
  target_node    = var.proxmox_node
  clone_template = var.vm_template
  display_type   = var.display_type

  cpu_cores    = 2
  memory_mb    = 4096
  disk_size_gb = 32
  storage_pool = var.storage_pool

  network_bridge = var.network_bridge
  vlan-tag       = var.vlan_id
  ip_address     = "${local.network_base}.63/24"
  gateway        = "${local.network_base}.1"
  nameserver     = var.nameserver

  ciuser         = var.ciuser
  cipassword     = var.cipassword
  ssh_public_key = join("\n", var.ssh_public_key)
  tags           = var.environment

  description = "K8s worker 3 - ${local.environment}"
}