#!/usr/bin/env python3
import os
import sys
import shutil
import subprocess
from pathlib import Path

try:
    from rich.console import Console
    from rich.panel import Panel
    from rich.text import Text
    from rich.theme import Theme
    import questionary
except ImportError:
    print("Missing dependencies. Python on this system prevents system-wide pip installs.")
    print("Please install the requirements inside a virtual environment by running the following commands:")
    print("\n  python3 -m venv venv")
    print("  source venv/bin/activate")
    print("  pip install -r requirements.txt")
    print("\nThen run the script again (make sure venv is activated):")
    print("  ./main.py")
    sys.exit(1)

# ─────────────────────────────────────────────────────────────────────────────
#  Theme Palette (Vibrant Neon Theme)
# ─────────────────────────────────────────────────────────────────────────────
custom_theme = Theme({
    "main": "#00d2ff bold",      # Cyan
    "accent": "#f700ff bold",    # Magenta
    "dim": "#666666 dim",        # Grey
    "success": "#39ff14 bold",   # Neon Green
    "warning": "#fffb00 bold",   # Neon Yellow
    "error": "#ff003c bold",     # Neon Red
})
console = Console(theme=custom_theme)

SCRIPT_DIR = Path(__file__).parent.resolve()
SERVICES_DIR = SCRIPT_DIR / "services"
PROXMOX_DEPLOY_SCRIPT = SERVICES_DIR / "proxmox/scripts/deploy.sh"

# ─────────────────────────────────────────────────────────────────────────────
#  UI Functions
# ─────────────────────────────────────────────────────────────────────────────
def header():
    os.system("clear" if os.name == "posix" else "cls")
    title = Text("🚀 HOME EDGE SETUP 🚀", justify="center", style="main")
    panel = Panel(
        title,
        border_style="accent",
        expand=False,
        padding=(1, 10)
    )
    console.print(panel)
    console.print()

def info(msg: str):
    console.print(f"[main] ╭─ ⚡ {msg}[/main]")

def substep(msg: str):
    console.print(f"[main] │  [/main][accent]❯ [/accent]{msg}")

def success(msg: str):
    console.print(f"[main] ╰─ [/main][success]✔ {msg}[/success]\n")

def error(msg: str):
    console.print(f"[main] ╰─ [/main][error]✘ {msg}[/error]\n")

# ─────────────────────────────────────────────────────────────────────────────
#  Core Logic
# ─────────────────────────────────────────────────────────────────────────────
def check_dependencies():
    info("Checking dependencies...")
    required_cmds = ["ansible", "terraform"]
    missing_cmds = []

    for cmd in required_cmds:
        cmd_path = shutil.which(cmd)
        if cmd_path:
            substep(f"{cmd} found: {cmd_path}")
        else:
            missing_cmds.append(cmd)

    if missing_cmds:
        error(f"Missing dependencies: {', '.join(missing_cmds)}")
        console.print("[warning]Install them before continuing:[/warning]")
        for cmd in missing_cmds:
            if cmd == "ansible":
                console.print("  sudo apt update && sudo apt install -y ansible")
            elif cmd == "terraform":
                console.print("  https://developer.hashicorp.com/terraform/downloads")
        sys.exit(1)
    
    success("Dependencies verified")

def run_ansible(playbook_path: Path, inventory_path: Path):
    if not playbook_path.is_file():
        error(f"Playbook not found: {playbook_path}")
        return False
    if not inventory_path.is_file():
        error(f"Inventory not found: {inventory_path}")
        return False
    
    substep("Running ansible-playbook...")
    try:
        result = subprocess.run(["ansible-playbook", "-i", str(inventory_path), str(playbook_path)])
        return result.returncode == 0
    except Exception as e:
        error(f"Failed to run ansible-playbook: {e}")
        return False

# ─────────────────────────────────────────────────────────────────────────────
#  Services
# ─────────────────────────────────────────────────────────────────────────────
def setup_proxmox_cronjob():
    info("Setting up Proxmox cronjob...")
    # Add implementation here
    success("Proxmox cronjob setup completed")

def deploy_proxmox_vms():
    info("Deploying Proxmox VMs with Terraform...")
    env_options = ["k8s", "sdv", "sv", "Cancel"]
    
    env_choice = questionary.select(
        "Select environment:",
        choices=env_options,
        style=questionary.Style([
            ('qmark', 'fg:#00d2ff bold'),
            ('question', 'fg:#f700ff bold'),
            ('answer', 'fg:#39ff14 bold'),
            ('pointer', 'fg:#00d2ff bold'),
            ('highlighted', 'fg:#00d2ff bold bg:#333333'),
            ('selected', 'fg:#39ff14'),
            ('separator', 'fg:#666666'),
            ('instruction', 'fg:#666666'),
        ])
    ).ask()

    if not env_choice or env_choice == "Cancel":
        error("Deployment cancelled")
        return

    if PROXMOX_DEPLOY_SCRIPT.is_file():
        # Ensure it's executable
        PROXMOX_DEPLOY_SCRIPT.chmod(0o755)
        try:
            result = subprocess.run([str(PROXMOX_DEPLOY_SCRIPT), env_choice])
            if result.returncode == 0:
                success(f"Terraform deployment completed for env: {env_choice}")
            else:
                error(f"Deploy script failed with exit code {result.returncode}")
        except Exception as e:
            error(f"Failed to execute deploy script: {e}")
    else:
        error(f"Deploy script not found at {PROXMOX_DEPLOY_SCRIPT}")

def update_apt_packages():
    info("Updating apt packages...")
    playbook = SERVICES_DIR / "ansible" / "update-apt" / "playbooks.yml"
    inventory = SERVICES_DIR / "ansible" / "update-apt" / "host.ini"
    
    if run_ansible(playbook, inventory):
        success("Apt packages updated successfully")
    else:
        error("Update apt failed")

def switch_ubuntu_mirror():
    info("Switching Ubuntu mirror to Vietnam...")
    playbook = SERVICES_DIR / "ansible" / "switch-mirror" / "playbooks.yml"
    inventory = SERVICES_DIR / "ansible" / "switch-mirror" / "host.ini"
    
    if run_ansible(playbook, inventory):
        success("Mirror switched successfully")
    else:
        error("Ansible playbook failed")

def not_implemented(name: str):
    def _run():
        info(name)
        success(f"{name} completed (stub)")
    return _run

def main():
    header()
    check_dependencies()
    
    options = {
        "🗓️  Setup Proxmox cronjob": setup_proxmox_cronjob,
        "🌐 Setup Proxmox networking": not_implemented("Setting up Proxmox networking"),
        "🚀 Deploy proxmox VMs": deploy_proxmox_vms,
        "🩺 VMs health check": not_implemented("VMs health check"),
        "📡 VMs network check": not_implemented("VMs network check"),
        "📦 Update apt packages": update_apt_packages,
        "🇻🇳 Switch Ubuntu mirror to Vietnam": switch_ubuntu_mirror,
        "☸️  Install kubernetes": not_implemented("Install kubernetes"),
        "🐳 Install Docker & Docker Compose": not_implemented("Install Docker & Docker Compose"),
        "💾 Backup plan": not_implemented("Backup plan"),
        "🔄 Restore plan": not_implemented("Restore plan"),
        "❌ Exit": lambda: sys.exit(0)
    }

    info("Selecting a service...")

    choice = questionary.select(
        "Choice:",
        choices=list(options.keys()),
        style=questionary.Style([
            ('qmark', 'fg:#f700ff bold'),
            ('question', 'fg:#f700ff bold'),
            ('answer', 'fg:#39ff14 bold'),
            ('pointer', 'fg:#00d2ff bold'),
            ('highlighted', 'fg:#00d2ff bold bg:#2b2b2b'),
            ('selected', 'fg:#39ff14'),
            ('separator', 'fg:#666666'),
            ('instruction', 'fg:#666666'),
            ('text', ''),
        ])
    ).ask()

    if choice:
        options[choice]()
    else:
        error("No selection made, exiting.")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print()
        error("Operation cancelled by user")
        sys.exit(1)
