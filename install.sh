#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITHUB_USER="coreyjonoliver"

echo "==> Dotfiles bootstrap"

# Install chezmoi if not present
if ! command -v chezmoi &>/dev/null; then
    echo "==> Installing chezmoi..."
    sh -c "$(curl -fsSL https://get.chezmoi.io)" -- -b "${HOME}/.local/bin"
    export PATH="${HOME}/.local/bin:${PATH}"
fi

# Determine if running from a local clone or remote
if [[ -f "${SCRIPT_DIR}/.chezmoiroot" ]]; then
    echo "==> Initializing from local source..."
    chezmoi init --apply --source "${SCRIPT_DIR}"
else
    echo "==> Initializing from GitHub..."
    chezmoi init --apply "${GITHUB_USER}"
fi

echo "==> Done! Open a new terminal to see changes."
