locals {
  environment  = "sv"
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
# Gitlab Server
#==============
module "gitlab_server" {
  source = "../../modules/proxmox_vm"

  vmid           = 400
  vm_name        = "gitlab"
  target_node    = var.proxmox_node
  clone_template = var.vm_template
  display_type   = var.display_type

  cpu_cores    = 8
  memory_mb    = 16144
  disk_size_gb = 32
  storage_pool = var.storage_pool

  network_bridge = var.network_bridge
  vlan-tag       = var.vlan_id
  ip_address     = "${local.network_base}.77/24"
  gateway        = "${local.network_base}.1"
  nameserver     = var.nameserver

  ciuser         = var.ciuser
  cipassword     = var.cipassword
  ssh_public_key = join("\n", var.ssh_public_key)
  tags           = var.environment

  description = "Gitlab Server - ${local.environment}"
}

#===============
# Jenkins Server
#===============
module "jenkins_server" {
  source = "../../modules/proxmox_vm"

  vmid           = 401
  vm_name        = "jenkins"
  target_node    = var.proxmox_node
  clone_template = var.vm_template
  display_type   = var.display_type

  cpu_cores    = 4
  memory_mb    = 8192
  disk_size_gb = 32
  storage_pool = var.storage_pool

  network_bridge = var.network_bridge
  vlan-tag       = var.vlan_id
  ip_address     = "${local.network_base}.78/24"
  gateway        = "${local.network_base}.1"
  nameserver     = var.nameserver

  ciuser         = var.ciuser
  cipassword     = var.cipassword
  ssh_public_key = join("\n", var.ssh_public_key)
  tags           = var.environment

  description = "Jenkins Server - ${local.environment}"
}

#================
# Cockpit Server
#================
module "cockpit_server" {
  source = "../../modules/proxmox-vm"

  vmid           = 402
  vm_name        = "cockpit"
  target_node    = var.proxmox_node
  clone_template = var.vm_template
  display_type   = var.display_type

  cpu_cores    = 2
  memory_mb    = 4096
  disk_size_gb = 15
  storage_pool = var.storage_pool

  network_bridge = var.network_bridge
  vlan-tag       = var.vlan_id
  ip_address     = "${local.network_base}.80/24"
  gateway        = "${local.network_base}.1"
  nameserver     = var.nameserver

  ciuser         = var.ciuser
  cipassword     = var.cipassword
  ssh_public_key = join("\n", var.ssh_public_key)
  tags           = var.environment

  description = "Cockpit Server - ${local.environment}"
}

#===========================
# K8s clusters Load Balancer
#===========================
module "k8s_lb_server" {
  source = "../../modules/proxmox-vm"

  vmid           = 403
  vm_name        = "k8s-load-balancer"
  target_node    = var.proxmox_node
  clone_template = var.vm_template
  display_type   = var.display_type

  cpu_cores    = 4
  memory_mb    = 4096
  disk_size_gb = 15
  storage_pool = var.storage_pool

  network_bridge = var.network_bridge
  vlan-tag       = var.vlan_id
  ip_address     = "${local.network_base}.76/24"
  gateway        = "${local.network_base}.1"
  nameserver     = var.nameserver

  ciuser         = var.ciuser
  cipassword     = var.cipassword
  ssh_public_key = join("\n", var.ssh_public_key)
  tags           = var.environment

  description = "K8s Clusters Load Balancer - ${local.environment}"
}