# Root makefile for cross-environment operations

# Build specific template across environments
build-truenas25-prod:
	cd environments/prod && make build-pve1-truenas25

build-truenas25-stage:
	cd environments/stage && make build-pve1-truenas25

# Validate across environments
validate-truenas25-all:
	cd environments/prod && make validate-pve1-truenas25
	cd environments/stage && make validate-pve1-truenas25

# Initialize plugins across all environments
init-all:
	cd environments/prod && make init-plugins
	cd environments/stage && make init-plugins

# List available environments
list-environments:
	@echo "Available environments:"
	@ls -d environments/*/

# Help
help:
	@echo "Available commands:"
	@echo "  build-truenas25-prod    - Build TrueNAS 25.04 on production PVE1"
	@echo "  build-truenas25-stage   - Build TrueNAS 25.04 on staging PVE1"
	@echo "  validate-truenas25-all  - Validate TrueNAS 25.04 across all environments"
	@echo "  init-all                - Initialize plugins across all environments"
	@echo "  list-environments       - List available environments" 