#=====================
# GitLab Server
#=====================
output "gitlab_server" {
  description = "GitLab Server"
  value = {
    name       = module.gitlab_server.vm_name
    ip_address = module.gitlab_server.ip_address
    vm_id      = module.gitlab_server.vm_id
  }
}

#===============
# Jenkins Server
#===============
output "jenkins_server" {
  description = "Jenkins Server"
  value = {
    name       = module.jenkins_server.vm_name
    ip_address = module.jenkins_server.ip_address
    vm_id      = module.jenkins_server.vm_id
  }
}

#================
# Cockpit Server
#================
output "cockpit_server" {
  description = "Cockpit Server"
  value = {
    name       = module.cockpit_server.vm_name
    ip_address = module.cockpit_server.ip_address
    vm_id      = module.cockpit_server.vm_id
  }
}

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

#===========================
# K8s Clusters Load Balancer
#===========================
output "k8s_load_balancer" {
  description = "K8s Clusters Load Balancer"
  value = {
    name       = module.k8s_lb_server.vm_name
    ip_address = module.k8s_lb_server.ip_address
    vm_id      = module.k8s_lb_server.vm_id
  }
}