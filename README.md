# Homelab-edge

Welcome to **Homelab-edge**, a centralized automation project for managing a homelab environment. This project uses various tools such as Terraform and Bash scripts to streamline the deployment, configuration, and maintenance of a Proxmox and Kubernetes-based home edge infrastructure.

## 🚀 Getting Started

The core of this project is driven by an interactive Bash script, `main.sh`, which provides an interface to execute various operational tasks across your homelab. It comes with a neat CLI UI.

### Prerequisites
- Proxmox server
- Terraform installed
- Bash environment

### Usage
Run the main menu script from the root of the repository:

```bash
./main.sh
```

You will be greeted with a menu offering several options:
1. **Setup Proxmox cronjob**: Configures necessary cronjobs on the Proxmox host.
2. **Deploy proxmox VMs with terraform**: A Terraform wrapper to deploy VMs into different environments:
   - `k8s-clusters`
   - `standalone-docker-vms`
   - `standalone-vms`
3. **Update apt packages**: System package upgrader.
4. **Setup Proxmox networking**: Configures the network interfaces and bridges.
5. **Backup plan**: Automation for backups.
6. **Install kubernetes**: Provisions and sets up K8s clusters.

## 🗂️ Project Structure

- **`main.sh`**: The interactive entry point for all operations.
- **`funcs/`**: Contains shared bash scripts and helper functions used by `main.sh`:
  - UI helpers (`ui.sh`)
  - Execution scripts (`proxmox-deploy.sh`, `proxmox-cronjob.sh`, etc.)
- **`services/`**: The core configurations. 
  - `proxmox/`: Terraform configurations (global, environments, modules, and scripts) for VM provisioning. 
  - `kubernetes/`: Cluster configurations, global load balancer setups, Traefik middlewares, and K8s scripts.
- **`docs/`**: Documentation artifacts, network diagrams (`HomeLab-networking.drawio.png`).
- **`boilerplates/`**: Reusable templates and boilerplate definitions for:
  - Docker
  - Kubernetes
  - Nginx configuration
  - Traefik routing
  - Jenkins CI/CD (`Jenkinsfile`)

## 🛠️ Main Technologies
- **Hypervisor**: Proxmox VE
- **Infrastructure as Code (IaC)**: Terraform
- **Container Orchestration**: Kubernetes (K3s/K8s) & Docker
- **Automation / Scripting**: Bash
- **Proxy / Ingress**: Traefik, Nginx
