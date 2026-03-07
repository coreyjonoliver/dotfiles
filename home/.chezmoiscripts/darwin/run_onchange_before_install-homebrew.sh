#!/bin/bash
set -euo pipefail

if command -v brew &>/dev/null; then
    echo "==> Homebrew already installed"
    exit 0
fi

echo "==> Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Set up Homebrew in current shell
if [[ -d /opt/homebrew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
