terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

resource "proxmox_vm_qemu" "vm" {
  vmid   = var.vmid
  name   = var.vm_name
  agent  = 1
  start_at_node_boot = true
  desc   = var.description
  tags   = var.tags

  # OS
  clone       = var.clone_template
  full_clone  = true
  target_node = var.target_node
  os_type     = "cloud-init"
  bios        = "seabios"
  scsihw      = "virtio-scsi-single"
  ciuser      = var.ciuser
  cipassword  = var.cipassword
  # ciupgrade   = true

  # Disk
  disks {
    ide {
      ide2 {
        cloudinit { 
          storage = var.storage_pool
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          storage = var.storage_pool
          size    = var.disk_size_gb
        }
      }
    }
  }
  boot     = "order=scsi0;net0"
  bootdisk = "scsi0"

  # CPU
  cpu {
    sockets = 1
    cores   = var.cpu_cores
    limit   = 0
    type    = "x86-64-v2-AES"
  }

  # Memory
  memory = var.memory_mb

  # Network
  network {
    id       = 0
    bridge   = var.network_bridge
    firewall = true
    model    = "virtio"
    tag      = var.vlan_tag
  }
  ipconfig0  = "ip=${var.ip_address},gw=${var.gateway}"
  nameserver = var.nameserver

  # Display 
  vga {
    type = var.display_type
  }

  sshkeys = var.ssh_public_key
}
