# Production environment makefile
ENVIRONMENT = prod

# Ensure ISOs are available before building
ensure-isos-pve1:
	cd ../../ansible && ansible-playbook -i ./inventories/production ./playbooks/manage_proxmox_isos.yml -e "target_hosts=pve1" --ask-become-pass

# PVE1 builds
build-pve1-truenas25: ensure-isos-pve1
	cd pve1/truenas-25.04 && packer build .

build-pve1-opnsense:
	cd pve1/opnsense && packer build .

build-pve1-ubuntu-noble:
	cd pve1/ubuntu-server-noble && packer build .

# PVE2 builds (when you add more hosts)
build-pve2-truenas25:
	cd pve2/truenas-25.04 && packer build .

# Validation
validate-pve1-truenas25:
	cd pve1/truenas-25.04 && packer validate .

# Plugin initialization
init-plugins:
	cd pve1/truenas-25.04 && packer init .
	cd pve1/opnsense && packer init .
	cd pve1/ubuntu-server-noble && packer init .

# All builds for PVE1
build-pve1-all: build-pve1-truenas25 build-pve1-opnsense build-pve1-ubuntu-noble 