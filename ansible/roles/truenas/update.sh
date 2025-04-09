#!/bin/bash
# Clone/update the arensb.truenas collection repository

REPO_URL="https://github.com/arensb/ansible-truenas.git"
COLLECTION_PATH="/home/pofo14/dev/IaC/ansible/collections/ansible_collections/arensb/truenas"
GALAXY_COLLECTION_PATH="/home/pofo14/dev/IaC/.venv/.ansible/collections/ansible_collections/arensb/truenas"

# Remove galaxy-installed collection if it exists
if [ -d "$GALAXY_COLLECTION_PATH" ]; then
    echo "Removing galaxy-installed collection..."
    rm -rf "$GALAXY_COLLECTION_PATH"
fi

# Ensure parent directories exist
mkdir -p "$(dirname "$COLLECTION_PATH")"

if [ -d "$COLLECTION_PATH/.git" ]; then
    echo "Updating existing repository..."
    cd "$COLLECTION_PATH"
    git pull
else
    echo "Cloning fresh repository..."
    # Backup any existing files
    if [ -d "$COLLECTION_PATH" ]; then
        mv "$COLLECTION_PATH" "${COLLECTION_PATH}.bak"
    fi
    git clone "$REPO_URL" "$COLLECTION_PATH"
fi
