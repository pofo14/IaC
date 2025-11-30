# ============================================
# helpers.mk
# Shared helper utilities for the Packer Makefile
# ============================================

# ------------------------------
# Required argument validator
# ------------------------------
validate-build-args = \
	@if [ -z "$(VERSION)" ]; then echo "ERROR: VERSION is required"; exit 1; fi; \
	if [ -z "$(ENV)" ]; then echo "ERROR: ENV is required"; exit 1; fi; \
	if [ -z "$(NODE)" ]; then echo "ERROR: NODE is required"; exit 1; fi; \
	if [ -z "$(VMID)" ]; then echo "ERROR: VMID is required"; exit 1; fi


# ------------------------------
# Packer format + validate
# ------------------------------
packer-validate:
	@echo ""
	@echo "➡️  Running packer fmt..."
	@packer fmt -recursive .
	@echo "➡️  Running packer validate..."
	@if [ -n "$(VALIDATE_FILE)" ]; then \
		packer validate -var-file=variables/global.auto.pkrvars.hcl $(VALIDATE_FILE); \
	else \
		echo "⚠️  VALIDATE_FILE not set — skipping file-level validation"; \
	fi
	@echo "✔ Validation complete"
	@echo ""


# ------------------------------
# Pretty logging helpers
# ------------------------------
define INFO
	@echo "[INFO] $(1)"
endef

define ERROR
	@echo "[ERROR] $(1)"
endef

define HEADER
	@echo ""
	@echo "=========================================="
	@echo "$(1)"
	@echo "=========================================="
	@echo ""
endef
