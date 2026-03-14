<p align="center">
  <img src=".github/header.svg" alt="dotfiles" width="700">
</p>

<p align="center">
  <a href="https://github.com/coreyjonoliver/dotfiles/actions/workflows/snippet-install.yml"><img src="https://github.com/coreyjonoliver/dotfiles/actions/workflows/snippet-install.yml/badge.svg" alt="Snippet install"></a>
  <a href="https://github.com/coreyjonoliver/dotfiles/actions/workflows/ci.yml"><img src="https://github.com/coreyjonoliver/dotfiles/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="https://github.com/coreyjonoliver/dotfiles/actions/workflows/benchmark.yml"><img src="https://github.com/coreyjonoliver/dotfiles/actions/workflows/benchmark.yml/badge.svg" alt="Benchmark"></a>
  <a href="https://github.com/coreyjonoliver/dotfiles/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-565f89" alt="License"></a>
</p>

<p align="center">
  <a href="https://github.com/twpayne/chezmoi"><img src="https://img.shields.io/github/v/tag/twpayne/chezmoi?color=7aa2f7&display_name=release&label=chezmoi&logo=gnometerminal&logoColor=7aa2f7&sort=semver" alt="chezmoi"></a>
  <a href="https://github.com/starship/starship"><img src="https://img.shields.io/github/v/tag/starship/starship?color=DD0B78&display_name=release&label=starship&logo=starship&logoColor=DD0B78&sort=semver" alt="starship"></a>
  <a href="https://github.com/jdx/mise"><img src="https://img.shields.io/github/v/tag/jdx/mise?color=00acc1&display_name=release&label=mise&logo=gnometerminal&logoColor=00acc1&sort=semver" alt="mise"></a>
  <a href="https://github.com/Neovim/neovim"><img src="https://img.shields.io/github/v/tag/neovim/neovim?color=57A143&display_name=release&label=neovim&logo=neovim&logoColor=57A143&sort=semver" alt="neovim"></a>
</p>

<p align="center">
  <a href="https://github.com/zsh-users/zsh"><img src="https://img.shields.io/github/v/tag/zsh-users/zsh?color=2885F1&display_name=release&label=zsh&logo=zsh&logoColor=2885F1&sort=semver" alt="zsh"></a>
  <a href="https://github.com/PowerShell/PowerShell"><img src="https://img.shields.io/github/v/tag/PowerShell/PowerShell?color=2671BE&display_name=release&label=pwsh&logo=powershell&logoColor=2671BE&sort=semver" alt="PowerShell"></a>
  <a href="https://github.com/ghostty-org/ghostty"><img src="https://img.shields.io/github/v/tag/ghostty-org/ghostty?color=c0caf5&display_name=release&label=ghostty&sort=semver" alt="ghostty"></a>
  <a href="https://1password.com/downloads/command-line"><img src="https://img.shields.io/badge/1password--cli-v2-0572ec?logo=1password&logoColor=0572ec" alt="1password-cli"></a>
</p>

Personal dotfiles managed with [chezmoi](https://chezmoi.io). Cross-platform (macOS + Windows) with automated CI/CD, shell startup benchmarking, and role-based configuration.

## Quick Start

### 🍎 macOS

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

### 🪟 Windows

**Snippet install (PowerShell):**

```powershell
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply coreyjonoliver
```

**Or with chezmoi already installed:**

```powershell
chezmoi init --apply coreyjonoliver
```

On Windows, `chezmoi init` will prompt for roles (AI, Developer, Gaming).

Configuration values (name, email, 1Password preference, Windows roles) are defined in `home/.chezmoi.toml.tmpl`. Edit that file before running `chezmoi init` to customize for your setup.

## Prerequisites

- [chezmoi](https://chezmoi.io/install/) (installed automatically by `install.sh`)
- [Task](https://taskfile.dev/installation/) (optional, for task runner)

## Structure

```
dotfiles/
├── .github/workflows/        # CI and benchmark workflows (macOS + Windows)
├── docs/                     # Component and secrets documentation
├── scripts/                  # Lint and benchmark scripts (sh + ps1)
├── tests/                    # Bats + Pester test suites
│   └── windows/              # Pester tests for Windows config
├── Taskfile.yml              # Task runner for common operations
├── install.sh                # Bootstrap script
└── home/                     # chezmoi source directory
    ├── .chezmoi.toml.tmpl    # Config data (name, email, 1Password, Windows roles)
    ├── .chezmoiexternal.toml # External dependencies (zsh plugins)
    ├── .chezmoiignore        # OS-conditional file ignoring
    ├── .chezmoidata/         # Declarative data (packages, git settings)
    ├── .chezmoiscripts/      # Setup scripts per OS
    │   ├── darwin/           # macOS: Homebrew, packages, defaults, 1Password, Brave
    │   └── windows/          # Windows: winget packages, terminal, Ollama
    ├── .chezmoitemplates/    # Reusable template fragments
    ├── dot_zshrc.tmpl        # Zsh interactive shell config (macOS)
    ├── dot_zprofile.tmpl     # Zsh login shell config (macOS)
    ├── Documents/PowerShell/ # PowerShell profile (Windows)
    ├── private_dot_ssh/      # SSH configuration (macOS + Windows)
    └── dot_config/
        ├── brave-private/    # Brave allowlist extension (macOS)
        ├── Code/User/        # VS Code settings and keybindings
        ├── ghostty/          # Ghostty terminal config (macOS)
        ├── git/              # Git configuration
        ├── homebrew/         # Brewfile (macOS)
        ├── mise/             # Version manager config
        ├── nvim/             # Neovim configuration
        ├── private_1Password/# 1Password SSH agent config (macOS)
        ├── starship.toml     # Starship prompt (Tokyo Night)
        └── windows-terminal/ # Windows Terminal settings
```

## Components

### Cross-Platform

| Component | Files | Description |
|-----------|-------|-------------|
| **Git** | `dot_config/git/` | Identity, aliases, global gitignore, 1Password SSH signing (macOS + Windows paths), sensible defaults |
| **Editor** | `dot_config/nvim/init.lua`, `dot_config/Code/User/` | Neovim and VS Code settings |
| **Prompt** | `dot_config/starship.toml` | Starship prompt with Tokyo Night theme and language modules |
| **SSH** | `private_dot_ssh/config.tmpl`, `dot_config/private_1Password/` | 1Password SSH agent (macOS socket / Windows named pipe) |
| **Packages** | `.chezmoidata/packages.toml` | Declarative package lists for Homebrew (macOS) and winget (Windows) |

### macOS &nbsp; [![macOS CI](https://img.shields.io/github/actions/workflow/status/coreyjonoliver/dotfiles/ci.yml?label=CI&logo=apple&logoColor=white)](https://github.com/coreyjonoliver/dotfiles/actions/workflows/ci.yml) [![macOS Benchmark](https://img.shields.io/github/actions/workflow/status/coreyjonoliver/dotfiles/benchmark.yml?label=Benchmark&logo=apple&logoColor=white)](https://github.com/coreyjonoliver/dotfiles/actions/workflows/benchmark.yml)

| Component | Files | Description |
|-----------|-------|-------------|
| **Shell** | `dot_zshrc.tmpl`, `dot_zprofile.tmpl` | Zsh history, aliases (with eza support), zoxide, mise, direnv, tool completions, plugin loading |
| **macOS Setup** | `.chezmoiscripts/darwin/` | Homebrew install, package install, system defaults, 1Password setup |
| **Plugins** | `.chezmoiexternal.toml` | zsh-syntax-highlighting, zsh-autosuggestions |
| **Terminal** | `dot_config/ghostty/config` | Ghostty with MesloLGS Nerd Font and Tokyo Night theme |
| **Versions** | `dot_config/mise/config.toml` | mise-managed Python, Node.js, Java, Go, and Terraform |
| **Brave** | `.chezmoiscripts/darwin/configure-brave`, `dot_config/brave-private/` | Hardened "Private" profile with PIA desktop VPN (kill switch), custom allowlist extension (Proton-only by default), strict shields, DNS-over-HTTPS, WebRTC lockdown, 1Password |

### Windows &nbsp; [![Windows CI](https://img.shields.io/github/actions/workflow/status/coreyjonoliver/dotfiles/ci.yml?label=CI&logo=windows&logoColor=white)](https://github.com/coreyjonoliver/dotfiles/actions/workflows/ci.yml) [![Windows Benchmark](https://img.shields.io/github/actions/workflow/status/coreyjonoliver/dotfiles/benchmark.yml?label=Benchmark&logo=windows&logoColor=white)](https://github.com/coreyjonoliver/dotfiles/actions/workflows/benchmark.yml)

Windows machines support role-based configuration. Roles are selected interactively during `chezmoi init`.

| Component | Files | Description |
|-----------|-------|-------------|
| **Shell** | `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` | PowerShell profile with starship, git aliases, eza support, direnv, PSReadLine, kubectl completions |
| **Windows Setup** | `.chezmoiscripts/windows/` | winget package install, Windows Terminal deployment, Git credential manager, 1Password manual steps |
| **Terminal** | `dot_config/windows-terminal/settings.json` | Windows Terminal with Tokyo Night theme, MesloLGS Nerd Font, PowerShell Core default |

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

## 📊 Startup Benchmarks

Shell startup speed is continuously measured using [hyperfine](https://github.com/sharkdp/hyperfine) and tracked with [benchmark-action/github-action-benchmark](https://github.com/benchmark-action/github-action-benchmark).

| Platform | Metric | Dashboard |
|----------|--------|-----------|
| macOS | `zsh -i -c exit` | [benchmarks/macos](https://coreyjonoliver.github.io/dotfiles/benchmarks/macos/) |
| Windows | `pwsh -NoProfile -NonInteractive -Command exit` | [benchmarks/windows](https://coreyjonoliver.github.io/dotfiles/benchmarks/windows/) |

Benchmarks run on every merge to `main`. Performance regressions over 150% trigger alerts.

## 🔄 Snippet Install

The [Snippet install](https://github.com/coreyjonoliver/dotfiles/actions/workflows/snippet-install.yml) workflow runs weekly (every Friday) and on manual trigger. It simulates a fresh machine by running `chezmoi init --apply` from the remote repo on both macOS and Windows runners, verifying that the dotfiles can be bootstrapped from scratch without errors.

## Acknowledgements

This repository's architecture was informed by several excellent dotfiles repos:

- [twpayne/dotfiles](https://github.com/twpayne/dotfiles) — Source root pattern, script organization (by the creator of chezmoi)
- [shunk031/dotfiles](https://github.com/shunk031/dotfiles) — CI/CD patterns, Bats testing, benchmark integration
- [natelandau/dotfiles](https://github.com/natelandau/dotfiles) — Data-driven package management with `.chezmoidata/`
- [halostatue/dotfiles](https://github.com/halostatue/dotfiles) — ShellCheck and EditorConfig patterns
- [chezmoi](https://chezmoi.io) — The dotfile management tool

## License

MIT