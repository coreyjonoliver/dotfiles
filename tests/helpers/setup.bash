#!/bin/bash

# Shared setup for Bats tests

export CHEZMOI_TEST_HOME
CHEZMOI_TEST_HOME="$(mktemp -d)"

export ROOT_DIR
ROOT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../.." && pwd)"

setup() {
    # Create chezmoi config with test data
    mkdir -p "${CHEZMOI_TEST_HOME}/.config/chezmoi"
    cat > "${CHEZMOI_TEST_HOME}/.config/chezmoi/chezmoi.toml" << 'EOF'
[data]
    name = "Test User"
    email = "test@example.com"
    github_username = "testuser"
    personal = true
    use_1password = false
EOF

    # Apply dotfiles to test home
    HOME="${CHEZMOI_TEST_HOME}" chezmoi apply \
        --source "${ROOT_DIR}" \
        --destination "${CHEZMOI_TEST_HOME}" \
        2>/dev/null
}

teardown() {
    rm -rf "${CHEZMOI_TEST_HOME}"
}
