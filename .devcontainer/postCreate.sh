#!/usr/bin/env bash
set -euo pipefail

# Ensure vscode user owns their cache directory
sudo chown -R vscode:vscode /home/vscode/.cache 2>/dev/null || true

# Make sure pipx path available for vscode user too
if ! command -v pipx >/dev/null 2>&1; then
 python3 -m pip install --user pipx
fi
pipx ensurepath || true


# Basic sanity
terraform -version
tflint --version
# trivy --version
ansible --version
ansible-lint --version
pre-commit --version
detect-secrets --version

# Optional: initialize tflint plugins
if [ -f ".tflint.hcl" ]; then
 tflint --init || true
fi

# Install collections from requirements file
if [ -f "ansible/requirements.yml" ]; then
    cd /workspaces/IaC/ansible && make reqs
fi

echo "postCreate complete"
