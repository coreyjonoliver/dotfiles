# dotfiles

[![CI](https://github.com/coreyjonoliver/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/coreyjonoliver/dotfiles/actions/workflows/ci.yml)
[![Benchmark](https://github.com/coreyjonoliver/dotfiles/actions/workflows/benchmark.yml/badge.svg)](https://github.com/coreyjonoliver/dotfiles/actions/workflows/benchmark.yml)

Personal dotfiles managed with [chezmoi](https://chezmoi.io). Organized by functional components with automated CI/CD, shell startup benchmarking, and cross-platform support.

## Quick Start

**One-liner (fresh machine):**

```bash
curl -fsSL https://raw.githubusercontent.com/coreyjonoliver/dotfiles/main/install.sh | bash
```

**Or clone and install locally:**

```bash
git clone https://github.com/coreyjonoliver/dotfiles.git ~/Projects/dotfiles
cd ~/Projects/dotfiles
./install.sh
```

Configuration values (name, email, 1Password preference) are defined in `home/.chezmoi.toml.tmpl`. Edit that file before running `chezmoi init` to customize for your setup.

## Prerequisites

- [chezmoi](https://chezmoi.io/install/) (installed automatically by `install.sh`)
- [Task](https://taskfile.dev/installation/) (optional, for task runner)

## Structure

```
dotfiles/
├── .github/workflows/        # CI and benchmark workflows
├── docs/                     # Component and secrets documentation
├── scripts/                  # Lint and benchmark scripts
├── tests/                    # Bats test suite
├── Taskfile.yml              # Task runner for common operations
├── install.sh                # Bootstrap script
└── home/                     # chezmoi source directory
    ├── .chezmoi.toml.tmpl    # Configuration data (name, email, 1Password)
    ├── .chezmoiexternal.toml # External dependencies (zsh plugins)
    ├── .chezmoiignore        # OS-conditional file ignoring
    ├── .chezmoidata/         # Declarative data (packages, git settings)
    ├── .chezmoiscripts/      # Setup scripts per OS
    │   └── darwin/           # macOS: Homebrew, packages, defaults, 1Password
    ├── .chezmoitemplates/    # Reusable template fragments
    ├── dot_zshrc.tmpl        # Zsh interactive shell config
    ├── dot_zprofile.tmpl     # Zsh login shell config
    ├── private_dot_ssh/      # SSH configuration
    └── dot_config/
        ├── Code/User/        # VS Code settings and keybindings
        ├── ghostty/          # Ghostty terminal config
        ├── git/              # Git configuration
        ├── homebrew/         # Brewfile (macOS)
        ├── mise/             # Version manager config
        ├── nvim/             # Neovim configuration
        ├── private_1Password/# 1Password SSH agent config
        └── starship.toml     # Starship prompt (Tokyo Night)
```

## Components

| Component | Files | Description |
|-----------|-------|-------------|
| **Shell** | `dot_zshrc.tmpl`, `dot_zprofile.tmpl` | Zsh history, aliases (with eza support), zoxide, mise, tool completions, plugin loading |
| **Git** | `dot_config/git/` | Identity, aliases, global gitignore, 1Password SSH signing, sensible defaults |
| **Editor** | `dot_config/nvim/init.lua`, `dot_config/Code/User/` | Neovim and VS Code settings |
| **Packages** | `.chezmoidata/packages.toml` | Declarative Homebrew formulae, casks, taps, and Mac App Store apps |
| **macOS** | `.chezmoiscripts/darwin/` | Homebrew install, package install, system defaults, 1Password setup |
| **Prompt** | `dot_config/starship.toml` | Starship prompt with Tokyo Night theme and language modules |
| **Plugins** | `.chezmoiexternal.toml` | zsh-syntax-highlighting, zsh-autosuggestions |
| **Terminals** | `dot_config/ghostty/config` | Ghostty with MesloLGS Nerd Font and Tokyo Night theme |
| **Versions** | `dot_config/mise/config.toml` | mise-managed Python, Node.js, Java, Go, and Terraform |
| **SSH** | `private_dot_ssh/config.tmpl`, `dot_config/private_1Password/` | 1Password SSH agent and key management |
| **Brave** | `.chezmoiscripts/darwin/configure-brave`, `dot_config/brave-private/` | Hardened "Private" profile with PIA desktop VPN (kill switch), custom allowlist extension (Proton-only by default), strict shields, DNS-over-HTTPS, WebRTC lockdown, 1Password |

### Windows Roles

Windows machines support role-based configuration. Roles are selected interactively during `chezmoi init`.

| Role | Component | Description |
|------|-----------|-------------|
| **ai** | Ollama | Privacy-hardened local LLM: firewall-blocked outbound, localhost-only binding, `ollama-pull` helper for gated model downloads |

## Daily Usage

```bash
task apply     # Apply changes after editing source files
task diff      # Preview pending changes
task status    # Show what would change
task edit      # Edit a managed file
task doctor    # Validate chezmoi setup
task brew      # Install Homebrew packages (macOS)
task defaults  # Apply macOS system defaults
task update    # Pull latest and apply
```

## Adding Packages

Edit `home/.chezmoidata/packages.toml`:

```toml
[darwin.brews]
  formulae = [
    "chezmoi",
    "starship",
    "neovim",
    "git",
    "go-task",
    "your-new-package",  # add here
  ]
```

Then run `task apply` to install.

## Secrets

1Password integration is available for managing SSH keys, API tokens, and other secrets. See [docs/SECRETS.md](docs/SECRETS.md) for setup instructions.

## Testing

```bash
task lint-shell       # Lint shell scripts with ShellCheck
task lint-powershell  # Lint PowerShell scripts with PSScriptAnalyzer (Windows)
task test             # Run Bats test suite
task test-windows     # Run Pester test suite (Windows)
task benchmark        # Measure zsh startup time (requires hyperfine)
task ci               # Run full CI pipeline locally
```

CI runs automatically on push/PR via GitHub Actions on both macOS and Windows. Shell startup benchmarks run on merges to `main` and track performance over time for both platforms.

## Acknowledgements

This repository's architecture was informed by several excellent dotfiles repos:

- [twpayne/dotfiles](https://github.com/twpayne/dotfiles) — Source root pattern, script organization (by the creator of chezmoi)
- [shunk031/dotfiles](https://github.com/shunk031/dotfiles) — CI/CD patterns, Bats testing, benchmark integration
- [natelandau/dotfiles](https://github.com/natelandau/dotfiles) — Data-driven package management with `.chezmoidata/`
- [halostatue/dotfiles](https://github.com/halostatue/dotfiles) — ShellCheck and EditorConfig patterns
- [chezmoi](https://chezmoi.io) — The dotfile management tool

## License

MIT