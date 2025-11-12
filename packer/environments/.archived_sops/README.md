# Archived SOPS Files

This directory contains SOPS-related files that were used for secrets management before migrating to GitHub Secrets / environment variables.

## Files Archived
- `env_and_run.sh` - Helper script that decrypted SOPS secrets and exported them as env vars
- `secrets.enc.yml` - SOPS-encrypted secrets files (dev and prod)
- `secrets-2.enc.yml` - Backup/test encrypted secrets file
- `.sops.yaml` - SOPS configuration files

## Why Archived
The project migrated from SOPS-encrypted secrets to environment variables sourced from GitHub Secrets for easier CI/CD integration and reduced local dependency on SOPS/age tooling.

## If You Need These Files
If you need to reference old secrets or revert to SOPS:
1. Check that you have the age key file at `/workspaces/IaC/terraform/key.txt`
2. Decrypt with: `sops --decrypt secrets.enc.yml`
3. Restore files to parent directories if needed

## Date Archived
November 9, 2025
