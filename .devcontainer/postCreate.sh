#!/usr/bin/env bash
set -euo pipefail

echo "===== Devcontainer Post-Create Starting ====="

#---------------------------------------------------------
# Fix ownership for vscode user cache directory
#---------------------------------------------------------
sudo chown -R vscode:vscode /home/vscode/.cache 2>/dev/null || true

#---------------------------------------------------------
# Ensure pipx is available
#---------------------------------------------------------
if ! command -v pipx >/dev/null 2>&1; then
  python3 -m pip install --user pipx
fi
pipx ensurepath || true

#---------------------------------------------------------
# Install latest Packer cleanly (1.14.2)
#---------------------------------------------------------
echo "Installing latest Packer (1.14.2)..."
PACKER_VERSION="1.14.2"

# Remove ALL legacy packer dirs to prevent plugin mismatch
rm -rf ~/.packer.d ~/.config/packer .pkr/plugins || true

curl -fsSL "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" -o /tmp/packer.zip
sudo unzip -o /tmp/packer.zip -d /usr/local/bin/
sudo chmod +x /usr/local/bin/packer
rm /tmp/packer.zip

echo "Packer ${PACKER_VERSION} installed."

#---------------------------------------------------------
# Install SOPS
#---------------------------------------------------------
echo "Installing SOPS..."
curl -LO https://github.com/getsops/sops/releases/download/v3.11.0/sops-v3.11.0.linux.amd64
sudo mv sops-v3.11.0.linux.amd64 /usr/local/bin/sops
sudo chmod +x /usr/local/bin/sops

#---------------------------------------------------------
# Verify tools
#---------------------------------------------------------
terraform -version
tflint --version
ansible --version
ansible-lint --version
pre-commit --version
detect-secrets --version
sops --version
packer version

#---------------------------------------------------------
# Optionally initialize tflint plugins
#---------------------------------------------------------
if [ -f ".tflint.hcl" ]; then
  tflint --init || true
fi

#---------------------------------------------------------
# Install Ansible role dependencies
#---------------------------------------------------------
if [ -f "ansible/requirements.yml" ]; then
  cd /workspaces/IaC/ansible && make reqs
fi

#---------------------------------------------------------
# Run packer init automatically for all Packer projects
#---------------------------------------------------------
echo "Initializing Packer plugins..."
# Initialize root packer.hcl if present
if [ -f "/workspaces/IaC/packer/packer.pkr.hcl" ]; then
  cd /workspaces/IaC/packer
  packer init .
fi

echo "===== Post-Create Complete ====="
