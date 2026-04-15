#================
# Cockpit Server
#================
output "pihole_server" {
  description = "Pi-hole Server"
  value = {
    name       = module.pihole_server.vm_name
    ip_address = module.pihole_server.ip_address
    vm_id      = module.pihole_server.vm_id
  }
}