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

@test "touchid configuration script exists" {
    [[ -f "${ROOT_DIR}/home/.chezmoiscripts/darwin/run_onchange_after_configure-touchid.sh.tmpl" ]]
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

@test "windows package install script exists" {
    [[ -f "${ROOT_DIR}/home/.chezmoiscripts/windows/run_onchange_after_install-packages.ps1.tmpl" ]]
}

@test "windows configure script exists" {
    [[ -f "${ROOT_DIR}/home/.chezmoiscripts/windows/run_onchange_after_configure-windows.ps1.tmpl" ]]
}

@test "powershell profile template exists" {
    [[ -f "${ROOT_DIR}/home/Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl" ]]
}

@test "windows terminal settings exist" {
    [[ -f "${ROOT_DIR}/home/dot_config/windows-terminal/settings.json" ]]
}

@test "git config handles both macOS and Windows 1Password paths" {
    grep -q "darwin" "${ROOT_DIR}/home/dot_config/git/config.tmpl"
    grep -q "windows" "${ROOT_DIR}/home/dot_config/git/config.tmpl"
}

@test "ssh config handles both macOS and Windows" {
    grep -q "darwin" "${ROOT_DIR}/home/private_dot_ssh/config.tmpl"
    grep -q "windows" "${ROOT_DIR}/home/private_dot_ssh/config.tmpl"
}

@test "packages.toml has both darwin and windows sections" {
    grep -q "\[darwin\]" "${ROOT_DIR}/home/.chezmoidata/packages.toml"
    grep -q "\[windows\]" "${ROOT_DIR}/home/.chezmoidata/packages.toml"
}

@test "composite action for macOS exists" {
    [[ -f "${ROOT_DIR}/.github/actions/setup-chezmoi-macos/action.yml" ]]
}

@test "composite action for Windows exists" {
    [[ -f "${ROOT_DIR}/.github/actions/setup-chezmoi-windows/action.yml" ]]
}

@test "repository settings file exists" {
    [[ -f "${ROOT_DIR}/.github/settings.yml" ]]
}

@test "CODEOWNERS file exists" {
    [[ -f "${ROOT_DIR}/.github/CODEOWNERS" ]]
}

@test "CODEOWNERS protects settings.yml" {
    grep -q "settings.yml" "${ROOT_DIR}/.github/CODEOWNERS"
}
