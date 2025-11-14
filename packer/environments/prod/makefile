# Production environment makefile
ENVIRONMENT = prod

# PVE1 builds
.PHONY: validate-pve1-truenas25
validate-pve1-truenas25:
	@echo "Validating TrueNAS 25.04 for pve1 in prod environment..."
	cd pve1/truenas-25.04 && packer validate -var-file=../../prod.auto.pkrvars.hcl -var-file=../../pve1.auto.pkrvars.hcl .

.PHONY: build-pve1-truenas25
build-pve1-truenas25:
	@echo "Building TrueNAS 25.04 for pve1 in prod environment..."
	cd pve1/truenas-25.04 && packer build -var-file=../../prod.auto.pkrvars.hcl -var-file=../../pve1.auto.pkrvars.hcl .

.PHONY: validate-pve1-opnsense
validate-pve1-opnsense:
	@echo "Validating OPNsense for pve1 in prod environment..."
	cd pve1/opnsense && packer validate -var-file=../../prod.auto.pkrvars.hcl -var-file=../../pve1.auto.pkrvars.hcl .

.PHONY: build-pve1-opnsense
build-pve1-opnsense:
	@echo "Building OPNsense for pve1 in prod environment..."
	cd pve1/opnsense && packer build -var-file=../../prod.auto.pkrvars.hcl -var-file=../../pve1.auto.pkrvars.hcl .

.PHONY: validate-pve1-ubuntu-noble
validate-pve1-ubuntu-noble:
	@echo "Validating Ubuntu Noble for pve1 in prod environment..."
	cd pve1/ubuntu-server-noble && packer validate -var-file=../../prod.auto.pkrvars.hcl -var-file=../../pve1.auto.pkrvars.hcl .

.PHONY: build-pve1-ubuntu-noble
build-pve1-ubuntu-noble:
	@echo "Building Ubuntu Noble for pve1 in prod environment..."
	cd pve1/ubuntu-server-noble && packer build -var-file=../../prod.auto.pkrvars.hcl -var-file=../../pve1.auto.pkrvars.hcl .

# PVE2 builds
.PHONY: validate-pve2-truenas25
validate-pve2-truenas25:
	@echo "Validating TrueNAS 25.04 for pve2 in prod environment..."
	cd pve2/truenas-25.04 && packer validate -var-file=../../prod.auto.pkrvars.hcl -var-file=../../pve2.auto.pkrvars.hcl .

.PHONY: build-pve2-truenas25
build-pve2-truenas25:
	@echo "Building TrueNAS 25.04 for pve2 in prod environment..."
	cd pve2/truenas-25.04 && packer build -var-file=../../prod.auto.pkrvars.hcl -var-file=../../pve2.auto.pkrvars.hcl .

.PHONY: validate-pve2-opnsense
validate-pve2-opnsense:
	@echo "Validating OPNsense for pve2 in prod environment..."
	cd pve2/opnsense && packer validate -var-file=../../prod.auto.pkrvars.hcl -var-file=../../pve2.auto.pkrvars.hcl .

.PHONY: build-pve2-opnsense
build-pve2-opnsense:
	@echo "Building OPNsense for pve2 in prod environment..."
	cd pve2/opnsense && packer build -var-file=../../prod.auto.pkrvars.hcl -var-file=../../pve2.auto.pkrvars.hcl .

.PHONY: validate-pve2-ubuntu-noble
validate-pve2-ubuntu-noble:
	@echo "Validating Ubuntu Noble for pve2 in prod environment..."
	cd pve2/ubuntu-server-noble && packer validate -var-file=../../prod.auto.pkrvars.hcl -var-file=../../pve2.auto.pkrvars.hcl .

.PHONY: build-pve2-ubuntu-noble
build-pve2-ubuntu-noble:
	@echo "Building Ubuntu Noble for pve2 in prod environment..."
	cd pve2/ubuntu-server-noble && packer build -var-file=../../prod.auto.pkrvars.hcl -var-file=../../pve2.auto.pkrvars.hcl .

# Convenience targets
.PHONY: build-pve1-all
build-pve1-all: build-pve1-truenas25 build-pve1-opnsense build-pve1-ubuntu-noble

.PHONY: build-pve2-all
build-pve2-all: build-pve2-truenas25 build-pve2-opnsense build-pve2-ubuntu-noble

.PHONY: validate-all
validate-all: validate-pve1-truenas25 validate-pve1-opnsense validate-pve1-ubuntu-noble validate-pve2-truenas25 validate-pve2-opnsense validate-pve2-ubuntu-noble
