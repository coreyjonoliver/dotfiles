#!/usr/bin/env bats

load helpers/setup

@test "chezmoi apply succeeds" {
    # setup() already ran apply; if we got here, it succeeded
    [[ -d "${CHEZMOI_TEST_HOME}" ]]
}

@test ".zshrc is created" {
    [[ -f "${CHEZMOI_TEST_HOME}/.zshrc" ]]
}

@test ".zprofile is created" {
    [[ -f "${CHEZMOI_TEST_HOME}/.zprofile" ]]
}

@test "git config is created" {
    [[ -f "${CHEZMOI_TEST_HOME}/.config/git/config" ]]
}

@test "git ignore is created" {
    [[ -f "${CHEZMOI_TEST_HOME}/.config/git/ignore" ]]
}

@test "starship config is created" {
    [[ -f "${CHEZMOI_TEST_HOME}/.config/starship.toml" ]]
}

@test "nvim config is created" {
    [[ -f "${CHEZMOI_TEST_HOME}/.config/nvim/init.lua" ]]
}

@test "git config contains test user name" {
    grep -q "Test User" "${CHEZMOI_TEST_HOME}/.config/git/config"
}

@test "git config contains test email" {
    grep -q "test@example.com" "${CHEZMOI_TEST_HOME}/.config/git/config"
}
