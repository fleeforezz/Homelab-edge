#================
# Cockpit Server
#================
output "monitoring_server" {
  description = "Monitoring Server"
  value = {
    name       = module.monitoring_server.vm_name
    ip_address = module.monitoring_server.ip_address
    vm_id      = module.monitoring_server.vm_id
  }
}