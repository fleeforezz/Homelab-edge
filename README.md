# Homelab-edge

Welcome to **Homelab-edge**, a centralized automation project for managing a homelab environment. This project uses various tools such as Terraform, Ansible, and Python to streamline the deployment, configuration, and maintenance of a Proxmox and Kubernetes-based home edge infrastructure.

## 🚀 Getting Started

The core of this project is driven by an interactive Python CLI, `main.py`, which provides a beautiful, neon-themed terminal interface to execute various operational tasks across your homelab.

### Prerequisites
- Python 3.12+ (or a compatible version with virtual environment support)
- Proxmox server
- Ansible installed
- Terraform installed

### Usage

First, create a virtual environment and install the required dependencies (you only need to do this once):

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Run the main menu script from the root of the repository (make sure your virtual environment is active!):

```bash
./main.py
```

You will be greeted with a vibrant menu offering several options:
1. 🗓️ **Setup Proxmox cronjob**: Configures necessary cronjobs on the Proxmox host.
2. 🌐 **Setup Proxmox networking**: Configures the network interfaces and bridges.
3. 🚀 **Deploy proxmox VMs**: A Terraform wrapper to deploy VMs into different environments:
   - `k8s`
   - `sdv`
   - `sv`
4. 🩺 **VMs health check**: Monitor the status of deployed VMs.
5. 📡 **VMs network check**: Verify connectivity and IPs.
6. 📦 **Update apt packages**: System package upgrader using Ansible.
7. 🇻🇳 **Switch Ubuntu mirror to Vietnam**: Ansible playbook to optimize apt sources.
8. ☸️ **Install kubernetes**: Provisions and sets up K8s clusters.
9. 🐳 **Install Docker & Docker Compose**: Bootstraps docker environments.
10. 💾 **Backup plan**: Automation for backups.
11. 🔄 **Restore plan**: Automation for restoring from backups.

## 🗂️ Project Structure

- **`main.py`**: The interactive Python CLI entry point for all operations.
- **`requirements.txt`**: The Python UI dependencies (`rich` and `questionary`).
- **`services/`**: The core configurations. 
  - `proxmox/`: Terraform configurations (global, environments, modules, and scripts) for VM provisioning. 
  - `ansible/`: Ansible playbooks for system administration tasks (like updating packages and switching mirrors).
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
- **Infrastructure as Code (IaC)**: Terraform, Ansible
- **Container Orchestration**: Kubernetes (K3s/K8s) & Docker
- **Automation / Scripting**: Python, Bash
- **Proxy / Ingress**: Traefik, Nginx
