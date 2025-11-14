# Development environment makefile
ENVIRONMENT = dev

# Node-specific builds
build-pve1-truenas25:
cd pve1/truenas-25.04 && packer build -var-file=../../dev.auto.pkrvars.hcl -var-file=../../pve1.auto.pkrvars.hcl .

build-pve1-opnsense:
cd pve1/opnsense && packer build -var-file=../../dev.auto.pkrvars.hcl -var-file=../../pve1.auto.pkrvars.hcl .

build-pve1-ubuntu-noble:
cd pve1/ubuntu-server-noble && packer build -var-file=../../dev.auto.pkrvars.hcl -var-file=../../pve1.auto.pkrvars.hcl .

build-pve2-truenas25:
cd pve2/truenas-25.04 && packer build -var-file=../../dev.auto.pkrvars.hcl -var-file=../../pve2.auto.pkrvars.hcl .

build-pve2-opnsense:
cd pve2/opnsense && packer build -var-file=../../dev.auto.pkrvars.hcl -var-file=../../pve2.auto.pkrvars.hcl .

build-pve2-ubuntu-noble:
cd pve2/ubuntu-server-noble && packer build -var-file=../../dev.auto.pkrvars.hcl -var-file=../../pve2.auto.pkrvars.hcl .

# All builds for specific node
build-pve1-all: build-pve1-truenas25 build-pve1-opnsense build-pve1-ubuntu-noble

build-pve2-all: build-pve2-truenas25 build-pve2-opnsense build-pve2-ubuntu-noble

# Build all templates across all nodes
build-all: build-pve1-all build-pve2-all

# Validation
validate-pve1-truenas25:
cd pve1/truenas-25.04 && packer validate -var-file=../../dev.auto.pkrvars.hcl -var-file=../../pve1.auto.pkrvars.hcl .

validate-pve1-opnsense:
cd pve1/opnsense && packer validate -var-file=../../dev.auto.pkrvars.hcl -var-file=../../pve1.auto.pkrvars.hcl .

validate-pve1-ubuntu-noble:
cd pve1/ubuntu-server-noble && packer validate -var-file=../../dev.auto.pkrvars.hcl -var-file=../../pve1.auto.pkrvars.hcl .

validate-pve2-truenas25:
cd pve2/truenas-25.04 && packer validate -var-file=../../dev.auto.pkrvars.hcl -var-file=../../pve2.auto.pkrvars.hcl .

validate-pve2-opnsense:
cd pve2/opnsense && packer validate -var-file=../../dev.auto.pkrvars.hcl -var-file=../../pve2.auto.pkrvars.hcl .

validate-pve2-ubuntu-noble:
cd pve2/ubuntu-server-noble && packer validate -var-file=../../dev.auto.pkrvars.hcl -var-file=../../pve2.auto.pkrvars.hcl .

# Validate all
validate-all: validate-pve1-truenas25 validate-pve1-opnsense validate-pve1-ubuntu-noble validate-pve2-truenas25 validate-pve2-opnsense validate-pve2-ubuntu-noble

# Plugin initialization
init-plugins:
cd pve1/truenas-25.04 && packer init .
cd pve1/opnsense && packer init .
cd pve1/ubuntu-server-noble && packer init .
cd pve2/truenas-25.04 && packer init .
cd pve2/opnsense && packer init .
cd pve2/ubuntu-server-noble && packer init .

# Clean old templates
clean-templates:
@echo "Cleaning old dev templates..."
# Add cleanup commands here
