output "vm_name" {
  description = "Name of the VM"
  value       = proxmox_vm_qemu.vm.name
}

output "vm_id" {
  description = "ID of the VM"
  value       = proxmox_vm_qemu.vm.vmid
}

output "ip_address" {
  description = "IP address of the VM"
  value       = var.ip_address
}

output "target_node" {
  description = "Proxmox node where the VM is deployed"
  value       = proxmox_vm_qemu.vm.target_node
}

output "ssh_host" {
  description = "SSH connection string"
  value       = "root@${var.ip_address}"
}

output "vm_status" {
  description = "Status of the VM"
  value       = proxmox_vm_qemu.vm.vm_state
}
