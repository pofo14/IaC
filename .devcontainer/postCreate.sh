#!/usr/bin/env bash
set -euo pipefail


# Make sure pipx path available for vscode user too
if ! command -v pipx >/dev/null 2>&1; then
 python3 -m pip install --user pipx
fi
pipx ensurepath || true


# Basic sanity
terraform -version
tflint --version
trivy --version
ansible --version
ansible-lint --version
pre-commit --version


# Optional: initialize tflint plugins
if [ -f ".tflint.hcl" ]; then
 tflint --init || true
fi


echo "postCreate complete"



