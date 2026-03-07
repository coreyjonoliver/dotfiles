#!/usr/bin/env bats

load helpers/setup

@test "zshrc has valid syntax" {
    zsh -n "${CHEZMOI_TEST_HOME}/.zshrc"
}

@test "zshrc contains history configuration" {
    grep -q "HISTSIZE" "${CHEZMOI_TEST_HOME}/.zshrc"
    grep -q "SAVEHIST" "${CHEZMOI_TEST_HOME}/.zshrc"
}

@test "zshrc contains aliases" {
    grep -q "alias ll=" "${CHEZMOI_TEST_HOME}/.zshrc"
    grep -q "alias gs=" "${CHEZMOI_TEST_HOME}/.zshrc"
}

@test "zprofile sets EDITOR" {
    grep -q "EDITOR" "${CHEZMOI_TEST_HOME}/.zprofile"
}

@test "zprofile sets LANG" {
    grep -q "LANG" "${CHEZMOI_TEST_HOME}/.zprofile"
}

@test "git config sets default branch to main" {
    grep -q "defaultBranch = main" "${CHEZMOI_TEST_HOME}/.config/git/config"
}

@test "git ignore includes .DS_Store" {
    grep -q ".DS_Store" "${CHEZMOI_TEST_HOME}/.config/git/ignore"
}
