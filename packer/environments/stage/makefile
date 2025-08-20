# Staging environment makefile
ENVIRONMENT = stage

build-pve1-truenas25:
	cd pve1/truenas-25.04 && packer build .

validate-pve1-truenas25:
	cd pve1/truenas-25.04 && packer validate .

init-plugins:
	cd pve1/truenas-25.04 && packer init . 