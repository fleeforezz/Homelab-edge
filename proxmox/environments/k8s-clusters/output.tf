#==============
# K8s manager 1
#==============
output "k8s_manager_1" {
  description = "K8s manager 1"
  value = {
    name       = module.k8s_manager_1.vm_name
    ip_address = module.k8s_manager_1.ip_address
    vm_id      = module.k8s_manager_1.vm_id
  }
}

#==============
# K8s manager 2
#==============
output "k8s_manager_2" {
  description = "K8s manager 2"
  value = {
    name       = module.k8s_manager_2.vm_name
    ip_address = module.k8s_manager_2.ip_address
    vm_id      = module.k8s_manager_2.vm_id
  }
}

#==============
# K8s manager 3
#==============
output "k8s_manager_3" {
  description = "K8s manager 3"
  value = {
    name       = module.k8s_manager_3.vm_name
    ip_address = module.k8s_manager_3.ip_address
    vm_id      = module.k8s_manager_3.vm_id
  }
}

#=============
# K8s worker 1
#=============
output "k8s_worker_1" {
  description = "K8s worker 1"
  value = {
    name       = module.k8s_worker_1.vm_name
    ip_address = module.k8s_worker_1.ip_address
    vm_id      = module.k8s_worker_1.vm_id
  }
}

#=============
# K8s worker 2
#=============
output "k8s_worker_2" {
  description = "K8s worker 2"
  value = {
    name       = module.k8s_worker_2.vm_name
    ip_address = module.k8s_worker_2.ip_address
    vm_id      = module.k8s_worker_2.vm_id
  }
}

#=============
# K8s worker 3
#=============
output "k8s_worker_3" {
  description = "K8s worker 3"
  value = {
    name       = module.k8s_worker_3.vm_name
    ip_address = module.k8s_worker_3.ip_address
    vm_id      = module.k8s_worker_3.vm_id
  }
}
