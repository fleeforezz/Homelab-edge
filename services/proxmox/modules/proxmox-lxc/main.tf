resource "proxmox_lxc" "container" {
  target_node  = var.target_node
  hostname     = var.container_name
  ostemplate   = "${var.storage_pool}:vztmpl/${var.template}"
  password     = var.root_password
  unprivileged = var.unprivileged
  onboot       = var.onboot
  start        = var.start_on_create
  description  = var.description

  # Resources
  cores  = var.cpu_cores
  memory = var.memory_mb

  # Root filesystem
  rootfs {
    storage = var.storage_pool
    size    = "${var.disk_size_gb}G"
  }

  # Network
  network {
    name   = "eth0"
    bridge = var.network_bridge
    ip     = var.ip_address
    gw     = var.gateway
  }

  # SSH Keys
  ssh_public_keys = var.ssh_public_key

  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}