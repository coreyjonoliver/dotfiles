#!/usr/bin/env bats

# Source tree integrity tests — verify all expected files exist in the repo.
# These run on any platform (Linux CI) without needing chezmoi.

setup() {
    ROOT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"
}

@test "darwin scripts directory exists" {
    [[ -d "${ROOT_DIR}/home/.chezmoiscripts/darwin" ]]
}

@test "windows scripts directory exists" {
    [[ -d "${ROOT_DIR}/home/.chezmoiscripts/windows" ]]
}

@test "brave configuration script exists" {
    [[ -f "${ROOT_DIR}/home/.chezmoiscripts/darwin/run_onchange_after_configure-brave.sh.tmpl" ]]
}

@test "ollama configuration script exists" {
    [[ -f "${ROOT_DIR}/home/.chezmoiscripts/windows/run_onchange_after_configure-ollama.ps1.tmpl" ]]
}

@test "brave-private allowlist exists" {
    [[ -f "${ROOT_DIR}/home/dot_config/brave-private/allowlist.conf" ]]
}

@test "brave-private extension manifest exists" {
    [[ -f "${ROOT_DIR}/home/dot_config/brave-private/extension/manifest.json" ]]
}

@test "chezmoi config template contains roles section" {
    grep -q "roles" "${ROOT_DIR}/home/.chezmoi.toml.tmpl"
}

@test "chezmoiignore covers both darwin and windows" {
    grep -q "darwin" "${ROOT_DIR}/home/.chezmoiignore"
    grep -q "windows" "${ROOT_DIR}/home/.chezmoiignore"
}
