#===================
# Media Stack Server
#===================
output "media_stack_server" {
  description = "Media Stack Server"
  value = {
    name       = module.media_stack_server.vm_name
    ip_address = module.media_stack_server.ip_address
    vm_id      = module.media_stack_server.vm_id
  }
}

#========================
# Personal Service Server
#========================
output "per_server" {
  description = "Personal Service Server"
  value = {
    name       = module.per_server.vm_name
    ip_address = module.per_server.ip_address
    vm_id      = module.per_server.vm_id
  }
}

#=================
# Databases Server
#=================
output "database_server" {
  description = "Databases Server"
  value = {
    name       = module.database_server.vm_name
    ip_address = module.database_server.ip_address
    vm_id      = module.database_server.vm_id
  }
}

#==================
# S3 Storage Server
#==================
output "s3_storage_server" {
  description = "S3 Storage Server"
  value = {
    name       = module.s3_storage_server.vm_name
    ip_address = module.s3_storage_server.ip_address
    vm_id      = module.s3_storage_server.vm_id
  }
}

#===================
# Development Server
#===================
output "development_server" {
  description = "Development Server"
  value = {
    name       = module.development_server.vm_name
    ip_address = module.development_server.ip_address
    vm_id      = module.development_server.vm_id
  }
}

#=====================
# Reverse Proxy Server
#=====================
output "reverse_proxy_server" {
  description = "Reverse Proxy Server"
  value = {
    name       = module.reverse_proxy_server.vm_name
    ip_address = module.reverse_proxy_server.ip_address
    vm_id      = module.reverse_proxy_server.vm_id
  }
}