# ============================================================
# Makefile for building TrueNAS templates via Packer
# Supports: VERSION=xx.xx NODE=pve1 ENV=prod
# ============================================================

# Default values (can be overridden at runtime)
VERSION ?= 25.04
NODE    ?= pve1
ENV     ?= prod

# make truenas VERSION=25.04 NODE=pve1 ENV=prod VMID=9012
.PHONY: truenas
truenas:
	@echo "Building TrueNAS $(VERSION) on $(NODE) for $(ENV)..."
	@bash -c ' \
		set -a; \
		source ../.env; \
		set +a; \
		cd ../truenas && \
		PACKER_LOG=1 PACKER_LOG_PATH=packer.log \
		packer build \
  		-var "vm_id=$(VMID)" \
  		-var "truenas_version=$(VERSION)" \
			-var-file=../environments/$(ENV).pkrvars.hcl \
			-var-file=../nodes/$(NODE).auto.pkrvars.hcl \
			-var-file=./versions/truenas-$(VERSION).pkrvars.hcl \
			. \
	'
# ============================================================
