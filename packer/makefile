SHELL := /bin/bash
.DEFAULT_GOAL := help

# ---------------------------
# Environment
# ---------------------------
PACKER := packer
BUILD_DIR := modules

export PACKER_LOG ?= 1
export PACKER_LOG_PATH ?= .packer.log

# ---------------------------
# Include external helpers
# ---------------------------
include helpers.mk

# ---------------------------
# Utility: Required CLI vars
# ---------------------------
define require_var
	@if [ -z "$($(1))" ]; then \
		echo "ERROR: Missing required variable: $(1)"; \
		exit 1; \
	fi
endef

# # ---------------------------
# # Shared Packer Build Macro
# # ---------------------------
# define PACKER_RUN
# 	$(PACKER) build \
# 		-var-file=variables/global.auto.pkrvars.hcl \
# 		-var-file=variables/$(NODE)_$(ENV).pkrvars.hcl \
# 		-var-file=$(1) \
# 		-var="proxmox_node=$(NODE)" \
# 		-var="vm_id=$(VMID)" \
# 		-var="environment=$(ENV)" \
# 		$(2)
# endef

# ---------------------------
# Shared Packer Build Macro
# ---------------------------
# $(1) => version-specific var-file (modules/…/versions/X.pkrvars.hcl)
# $(2) => build selector passed to -only (e.g., truenas, opnsense, ubuntu)
define PACKER_RUN
    $(PACKER) build \
				-var-file=variables/global.auto.pkrvars.hcl \
        -var-file=variables/$(NODE)_$(ENV).pkrvars.hcl \
 				-var="vm_id=$(VMID)" \
        $(1)
endef

# ---------------------------
# PHONY TARGETS
# ---------------------------
.PHONY: help truenas opnsense ubuntu debug-vars init

help:
	@echo ""
	@echo "Packer Build System"
	@echo ""
	@echo "Usage:"
	@echo "  make truenas   VERSION=X ENV=prod NODE=pve1 VMID=9001"
	@echo "  make opnsense  VERSION=X ENV=prod NODE=pve1 VMID=9002"
	@echo "  make ubuntu    VERSION=X ENV=prod NODE=pve1 VMID=9003"
	@echo ""
	@echo "Initialization:"
	@echo "  make init"
	@echo ""
	@echo "Debugging:"
	@echo "  make debug-vars"
	@echo ""

# ---------------------------
# Debug Vars
# ---------------------------
debug-vars:
	@echo "VERSION = $(VERSION)"
	@echo "ENV     = $(ENV)"
	@echo "NODE    = $(NODE)"
	@echo "VMID    = $(VMID)"
	@echo ""
	@echo "Global Vars:"
	@cat variables/global.auto.pkrvars.hcl || true
	@echo ""
	@echo "Environment Vars:"
	@cat variables/pve_$(ENV).pkrvars.hcl || true

# ---------------------------
# Build: TrueNAS
# ---------------------------
truenas:
	$(call require_var,VERSION)
	$(call require_var,ENV)
	$(call require_var,NODE)
	$(call require_var,VMID)
	@echo "Building TrueNAS $(VERSION) on $(NODE) for $(ENV)..."
	@if [ ! -d $(BUILD_DIR)/truenas/$(VERSION) ]; then \
			echo "ERROR: Version $(VERSION) not found"; \
			exit 1; \
	fi
	$(call PACKER_RUN,$(BUILD_DIR)/truenas/$(VERSION))

# ---------------------------
# Build: OPNsense
# ---------------------------
opnsense:
	$(call require_var,VERSION)
	$(call require_var,ENV)
	$(call require_var,NODE)
	$(call require_var,VMID)
	@echo "Building OPNsense $(VERSION) on $(NODE) for $(ENV)..."
		@if [ ! -d $(BUILD_DIR)/opnsense/$(VERSION) ]; then \
			echo "ERROR: Version $(VERSION) not found"; \
			exit 1; \
	fi
	$(call PACKER_RUN,$(BUILD_DIR)/opnsense/$(VERSION))

# ---------------------------
# Build: Ubuntu
# ---------------------------
ubuntu:
	$(call require_var,VERSION)
	$(call require_var,ENV)
	$(call require_var,NODE)
	$(call require_var,VMID)
	@echo "Building Ubuntu $(VERSION) on $(NODE) for $(ENV)..."
	$(call PACKER_RUN,$(BUILD_DIR)/ubuntu/$(VERSION))

# ---------------------------
# Plugin Download
# ---------------------------
init: $(PLUGIN_BIN)
	@echo "Packer environment initialized."

$(PLUGIN_BIN):
	@echo "Installing Proxmox plugin $(PLUGIN_VERSION)..."
	@mkdir -p $(PLUGIN_BASE)
	curl -fsSL -o $(PLUGIN_BASE)/$(PLUGIN_ZIP) $(PLUGIN_URL)/$(PLUGIN_ZIP)
	curl -fsSL -o $(PLUGIN_BASE)/$(PLUGIN_SHA256) $(PLUGIN_URL)/$(PLUGIN_SHA256)
	unzip -o $(PLUGIN_BASE)/$(PLUGIN_ZIP) -d $(PLUGIN_BASE)
	rm -f $(PLUGIN_BASE)/$(PLUGIN_ZIP)
	mv $(PLUGIN_BASE)/packer-plugin-proxmox_* $(PLUGIN_BIN) || true
	chmod +x $(PLUGIN_BIN)
	@echo "Plugin installed at $(PLUGIN_BIN)"
