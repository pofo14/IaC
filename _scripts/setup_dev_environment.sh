#!/bin/bash
echo "Setting up development environment for IaC project..."

# Update system
sudo apt update

# Install system packages
echo "Installing system packages..."
sudo apt install -y build-essential bzip2 unzip curl wget openssh-client openssh-server

# Install Terraform
echo "Installing Terraform..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update && sudo apt install -y terraform

# Install Packer
echo "Installing Packer..."
sudo apt install -y packer

# Install SOPS
echo "Installing SOPS..."
curl -L https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux -o /tmp/sops
chmod +x /tmp/sops
sudo mv /tmp/sops /usr/local/bin/sops

# Install GitHub CLI
echo "Installing GitHub CLI..."
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install -y gh

# Setup Python virtual environment
echo "Setting up Python virtual environment..."
mkdir -p ~/venvs
python3 -m venv ~/venvs/ansible
source ~/venvs/ansible/bin/activate

# Install Python packages
echo "Installing Python packages..."
pip install --upgrade pip
pip install ansible ansible-lint yamllint jmespath netaddr jinja2 pyyaml cryptography

echo "Development environment setup complete!"
echo ""
echo "To activate the Python environment:"
echo "source ~/venvs/ansible/bin/activate"
echo ""
echo "To verify installations:"
echo "terraform --version"
echo "packer --version"
echo "sops --version"
echo "gh --version"
echo "ansible --version"