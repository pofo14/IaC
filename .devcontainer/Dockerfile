FROM mcr.microsoft.com/devcontainers/base:ubuntu


# Terraform + TFLint + Trivy + direnv + ansible + ansible-lint + pre-commit
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
   curl unzip jq gnupg lsb-release software-properties-common make git \
   python3-pip python3-venv python3-dev \
   && rm -rf /var/lib/apt/lists/*


# Terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
&& echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
   | tee /etc/apt/sources.list.d/hashicorp.list \
&& apt-get update && apt-get install -y terraform


# TFLint
RUN curl -L https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash


# Trivy (IaC scan)
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin


# direnv
RUN curl -sfL https://direnv.net/install.sh | bash


# pipx + ansible/ansible-lint + pre-commit
#RUN python3 -m pip install --user pipx && /root/.local/bin/pipx ensurepath
#ENV PATH="/root/.local/bin:/home/vscode/.local/bin:${PATH}"
#RUN pipx install ansible && pipx install ansible-lint && pipx install pre-commit
# pipx via apt (no PEP 668), plus venv provider
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
   pipx python3-venv && \
   rm -rf /var/lib/apt/lists/*


# Make pipx install binaries into a global path
ENV PIPX_HOME=/opt/pipx
ENV PIPX_BIN_DIR=/usr/local/bin
RUN pipx install ansible==9.7.0 && \
   pipx install ansible-lint==24.7.0 && \
   pipx install pre-commit==3.7.1




# Terraform MCP server (binary)
RUN curl -L https://github.com/hashicorp/terraform-mcp-server/releases/latest/download/terraform-mcp-server_linux_amd64 \
   -o /usr/local/bin/terraform-mcp-server && chmod +x /usr/local/bin/terraform-mcp-server





