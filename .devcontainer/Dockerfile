FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Set environment to non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies and Python
RUN apt-get update && apt-get install -y \
   curl unzip jq make \
   python3 python3-pip python3-venv \
   && rm -rf /var/lib/apt/lists/*

# TFLint (not available as feature)
RUN curl -L https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Trivy (security scanning - not available as feature)
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# direnv (not available as feature)
RUN curl -sfL https://direnv.net/install.sh | bash

# Install Python tools
RUN pip3 install --break-system-packages \
   ansible==9.7.0 \
   ansible-lint==24.7.0 \
   pre-commit==3.7.1 \
   detect-secrets

# Terraform MCP server (specialized tool)
RUN curl -L https://github.com/hashicorp/terraform-mcp-server/releases/latest/download/terraform-mcp-server_linux_amd64 \
   -o /usr/local/bin/terraform-mcp-server && chmod +x /usr/local/bin/terraform-mcp-server

USER vscode
