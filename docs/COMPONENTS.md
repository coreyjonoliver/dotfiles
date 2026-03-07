# Components

This document describes the functional components of the dotfiles repository.

## Shell

**Files:** `home/dot_zshrc.tmpl`, `home/dot_zprofile.tmpl`

Configures the zsh shell with:
- History (50k entries, shared between sessions, deduplication)
- Tab completion with case-insensitive matching
- Directory navigation (`AUTO_CD`, `AUTO_PUSHD`)
- Aliases for common commands (`ll`, `la`, `gs`, `gd`, `ga`, `gc`, `gp`, `gl`)
- Utility functions (`mkcd`)
- Starship prompt (falls back to simple prompt if unavailable)

`dot_zprofile.tmpl` handles login shell setup: Homebrew PATH (macOS), `~/.local/bin`, and environment variables (`EDITOR`, `LANG`).

## Git

**Files:** `home/dot_config/git/config.tmpl`, `home/dot_config/git/ignore`, `home/dot_config/git/attributes`, `home/dot_config/git/message`

**Data-driven:** Settings defined in `home/.chezmoidata/git.toml`, GitHub username prompted during `chezmoi init`.

- User identity and GitHub username from chezmoi data
- 1Password SSH commit signing (when `use_1password = true`)
- Default branch, editor from `git.toml`
- Pull with rebase, push auto-setup remote, fetch with prune
- `rerere` enabled (remembers merge conflict resolutions)
- `rebase.autoStash`, `histogram` diff algorithm
- Aliases defined in `git.toml`: `st`, `co`, `br`, `ci`, `sw`, `cp`, `lg`, `lga`, `last`, `amend`, `undo`, `dfs`, `dfw`, `gone`, `merged`, `sl`, `sp`, `ss`, `contributors`
- Global gitignore, gitattributes (diff drivers per language), commit message template

## Editor

**Files:** `home/dot_config/nvim/init.lua`, `home/dot_config/Code/User/settings.json`

**Neovim:** Line numbers, smart indentation, search highlighting, clipboard integration, split behavior, undo persistence, leader key (`Space`), and window navigation keymaps.

**VS Code:** Font settings, auto-save, format on save, bracket pair colorization.

## Packages

**Files:** `home/.chezmoidata/packages.toml`, `home/dot_config/homebrew/Brewfile.tmpl`

Declarative package management. Edit `packages.toml` to add/remove packages, then run `chezmoi apply`.

Currently manages:
- **Homebrew formulae:** chezmoi, gh, git, go-task, mise, neovim, rustup, sidero-tools, starship
- **Homebrew casks:** 1password-cli, ghostty, private-internet-access, visual-studio-code, warp

The `Brewfile.tmpl` is auto-generated from `packages.toml` data.

## macOS

**Files:** `home/.chezmoiscripts/darwin/`

Three scripts run during `chezmoi apply`:

1. **install-homebrew** — Installs Homebrew if missing
2. **install-packages** — Runs `brew bundle` (re-runs when packages.toml changes)
3. **configure-defaults** — Sets macOS system preferences (Finder, Dock, keyboard, trackpad, screenshots)

## Prompt

**Files:** `home/dot_config/starship.toml`

[Starship](https://starship.rs) cross-platform prompt. Configured for speed with language-specific modules disabled. Shows directory, git branch/status, and command duration.

## Zsh Plugins

**Files:** `home/.chezmoiexternal.toml`

Managed declaratively via chezmoi external dependencies:
- **zsh-syntax-highlighting** — Syntax highlighting for commands
- **zsh-autosuggestions** — Fish-like autosuggestions

Plugins are downloaded and updated automatically during `chezmoi apply`.

## Terminals

**Files:** `home/dot_config/ghostty/config`

**Ghostty:** Font (JetBrains Mono 14pt), Gruvbox theme with automatic light/dark switching, shell integration, copy-on-select, block cursor, 50k scrollback. Reload config with `Cmd+Shift+,`.

**Warp:** Installed via Homebrew cask. Custom themes can be added to `home/dot_warp/themes/`. Launch configurations go in `home/dot_warp/launch_configurations/`.

## Version Management

**Files:** `home/dot_config/mise/config.toml`

[mise](https://mise.jdx.dev) manages Python, Node.js, Java, Go, and Terraform versions. Global defaults in `config.toml`, per-project overrides via `.mise.toml`. Auto-installs missing tools when entering a project directory.

Rust is managed separately via `rustup` (canonical Rust toolchain manager).
