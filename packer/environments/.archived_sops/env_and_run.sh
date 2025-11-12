#!/usr/bin/env bash
# env_and_run.sh - exports secrets from secrets.enc.yml (via sops/yq) then runs the provided command.
set -euo pipefail
ROOT_DIR=$(cd "$(dirname "$0")" && pwd)
SECRETS_FILE="$ROOT_DIR/secrets.enc.yml"

# Helper to extract a key path
get_secret() {
  local path="$1"
  (sops --decrypt "$SECRETS_FILE" 2>/dev/null || cat "$SECRETS_FILE") | yq -r "$path" | tr -d '\n'
}

export PROXMOX_API_URL="$(get_secret '.environments.dev.pve1.api_url')"
export PROXMOX_API_TOKEN_ID="$(get_secret '.environments.dev.pve1.api_token_id')"
export PROXMOX_API_TOKEN_SECRET="$(get_secret '.environments.dev.pve1.api_token_secret')"
export TRUENAS_ROOT_PASSWORD="$(get_secret '.passwords.truenas_root')"
export PROXMOX_HOST="pve1"

# Execute passed command in a subshell
exec bash -lc "$*"
