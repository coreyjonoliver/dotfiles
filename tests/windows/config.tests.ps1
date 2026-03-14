#Requires -Modules Pester

<#
.SYNOPSIS
    Pester tests for Windows platform configuration.
    Tests package definitions, PowerShell profile, Windows Terminal,
    git config, and SSH config for cross-platform correctness.
#>

BeforeAll {
    $Script:RootDir = (Resolve-Path "$PSScriptRoot\..\..").Path
    $Script:TestHome = Join-Path $env:TEMP "chezmoi-test-general-$(Get-Random)"

    $configDir = Join-Path $Script:TestHome ".config\chezmoi"
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null

    @"
[data]
    name = "Test User"
    email = "test@example.com"
    github_username = "testuser"
    personal = true
    use_1password = true

[data.roles]
    ai = false
    developer = false
    gaming = false
"@ | Set-Content -Path (Join-Path $configDir "chezmoi.toml") -Encoding UTF8

    $env:HOME = $Script:TestHome
    & chezmoi apply `
        --source $Script:RootDir `
        --destination $Script:TestHome `
        --exclude=scripts `
        2>$null
}

AfterAll {
    if (Test-Path $Script:TestHome) {
        Remove-Item -Recurse -Force $Script:TestHome
    }
}

Describe "Windows Packages" {
    It "should define winget packages in packages.toml" {
        $content = Get-Content (Join-Path $Script:RootDir "home\.chezmoidata\packages.toml") -Raw
        $content | Should -Match "\[windows\.winget\]"
    }

    It "should include essential packages" {
        $content = Get-Content (Join-Path $Script:RootDir "home\.chezmoidata\packages.toml") -Raw
        $content | Should -Match "Git\.Git"
        $content | Should -Match "Microsoft\.WindowsTerminal"
        $content | Should -Match "Microsoft\.PowerShell"
        $content | Should -Match "Starship\.Starship"
        $content | Should -Match "Neovim\.Neovim"
        $content | Should -Match "Microsoft\.VisualStudioCode"
    }

    It "should include 1Password packages" {
        $content = Get-Content (Join-Path $Script:RootDir "home\.chezmoidata\packages.toml") -Raw
        $content | Should -Match "AgileBits\.1Password\b"
        $content | Should -Match "AgileBits\.1Password\.CLI"
    }

    It "should have a package install script" {
        $scriptPath = Join-Path $Script:RootDir "home\.chezmoiscripts\windows\run_onchange_after_install-packages.ps1.tmpl"
        $scriptPath | Should -Exist
    }
}

Describe "PowerShell Profile" {
    It "should be deployed to Documents\PowerShell" {
        $profilePath = Join-Path $Script:TestHome "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
        $profilePath | Should -Exist
    }

    It "should configure starship prompt" {
        $profilePath = Join-Path $Script:TestHome "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
        $content = Get-Content $profilePath -Raw
        $content | Should -Match "starship init powershell"
    }

    It "should configure direnv hook" {
        $profilePath = Join-Path $Script:TestHome "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
        $content = Get-Content $profilePath -Raw
        $content | Should -Match "direnv hook pwsh"
    }

    It "should define git aliases" {
        $profilePath = Join-Path $Script:TestHome "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
        $content = Get-Content $profilePath -Raw
        $content | Should -Match "function gs"
        $content | Should -Match "function gd"
    }

    It "should configure PSReadLine" {
        $profilePath = Join-Path $Script:TestHome "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
        $content = Get-Content $profilePath -Raw
        $content | Should -Match "PSReadLine"
        $content | Should -Match "PredictionSource"
    }
}

Describe "Windows Terminal Settings" {
    It "should include settings in dotfiles" {
        $settingsPath = Join-Path $Script:RootDir "home\dot_config\windows-terminal\settings.json"
        $settingsPath | Should -Exist
    }

    It "should be valid JSON" {
        $settingsPath = Join-Path $Script:RootDir "home\dot_config\windows-terminal\settings.json"
        { Get-Content $settingsPath -Raw | ConvertFrom-Json } | Should -Not -Throw
    }

    It "should use Tokyo Night color scheme" {
        $settingsPath = Join-Path $Script:RootDir "home\dot_config\windows-terminal\settings.json"
        $content = Get-Content $settingsPath -Raw
        $content | Should -Match "Tokyo Night"
    }

    It "should use MesloLGS Nerd Font" {
        $settingsPath = Join-Path $Script:RootDir "home\dot_config\windows-terminal\settings.json"
        $content = Get-Content $settingsPath -Raw
        $content | Should -Match "MesloLGS Nerd Font"
    }

    It "should default to PowerShell Core profile" {
        $settingsPath = Join-Path $Script:RootDir "home\dot_config\windows-terminal\settings.json"
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
        $settings.defaultProfile | Should -Be "{574e775e-4f2a-5b96-ac1e-a2962a402336}"
    }
}

Describe "Git Config (Cross-Platform)" {
    It "should be deployed" {
        $gitConfig = Join-Path $Script:TestHome ".config\git\config"
        $gitConfig | Should -Exist
    }

    It "should contain test user name" {
        $gitConfig = Join-Path $Script:TestHome ".config\git\config"
        $content = Get-Content $gitConfig -Raw
        $content | Should -Match "Test User"
    }

    It "should have Windows 1Password signing path in template" {
        $templatePath = Join-Path $Script:RootDir "home\dot_config\git\config.tmpl"
        $content = Get-Content $templatePath -Raw
        $content | Should -Match "op-ssh-sign-no-security\.exe"
    }

    It "should deploy gitignore" {
        Join-Path $Script:TestHome ".config\git\ignore" | Should -Exist
    }

    It "should deploy git attributes" {
        Join-Path $Script:TestHome ".config\git\attributes" | Should -Exist
    }

    It "should deploy commit template" {
        Join-Path $Script:TestHome ".config\git\message" | Should -Exist
    }
}

Describe "SSH Config (Cross-Platform)" {
    It "should be deployed on Windows" {
        $sshConfig = Join-Path $Script:TestHome ".ssh\config"
        $sshConfig | Should -Exist
    }

    It "should reference Windows named pipe for 1Password" {
        $sshConfig = Join-Path $Script:TestHome ".ssh\config"
        $content = Get-Content $sshConfig -Raw
        $content | Should -Match "openssh-ssh-agent"
    }
}

Describe "Starship Config (Cross-Platform)" {
    It "should be deployed" {
        Join-Path $Script:TestHome ".config\starship.toml" | Should -Exist
    }
}

Describe "Neovim Config (Cross-Platform)" {
    It "should be deployed" {
        Join-Path $Script:TestHome ".config\nvim\init.lua" | Should -Exist
    }
}

Describe "VS Code Settings (Cross-Platform)" {
    It "should deploy settings" {
        Join-Path $Script:TestHome ".config\Code\User\settings.json" | Should -Exist
    }

    It "should deploy keybindings" {
        Join-Path $Script:TestHome ".config\Code\User\keybindings.json" | Should -Exist
    }
}
