#Requires -Modules Pester

<#
.SYNOPSIS
    Pester tests for Windows dotfiles configuration.
    Mirrors the Bats test structure used for macOS/Linux.

.DESCRIPTION
    Applies chezmoi to a temp directory with Windows roles enabled,
    then verifies the rendered output. Does NOT run the actual setup
    scripts (no Ollama install, no firewall changes).
#>

BeforeAll {
    $Script:RootDir = (Resolve-Path "$PSScriptRoot\..\..").Path
    $Script:TestHome = Join-Path $env:TEMP "chezmoi-test-$(Get-Random)"

    # Create test home and chezmoi config
    $configDir = Join-Path $Script:TestHome ".config\chezmoi"
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null

    @"
[data]
    name = "Test User"
    email = "test@example.com"
    github_username = "testuser"
    personal = true
    use_1password = false

[data.roles]
    ai = true
    developer = false
    gaming = false
"@ | Set-Content -Path (Join-Path $configDir "chezmoi.toml") -Encoding UTF8

    # Apply chezmoi to test home (exclude scripts so nothing actually runs)
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

Describe "Chezmoi Apply" {
    It "should create the test home directory" {
        $Script:TestHome | Should -Exist
    }
}

Describe "Ollama Script Template" {
    It "should exist in source tree" {
        $scriptPath = Join-Path $Script:RootDir "home\.chezmoiscripts\windows\run_onchange_after_configure-ollama.ps1.tmpl"
        $scriptPath | Should -Exist
    }

    It "should contain winget install command" {
        $scriptPath = Join-Path $Script:RootDir "home\.chezmoiscripts\windows\run_onchange_after_configure-ollama.ps1.tmpl"
        $content = Get-Content $scriptPath -Raw
        $content | Should -Match "winget install.*Ollama\.Ollama"
    }

    It "should set OLLAMA_HOST to localhost" {
        $scriptPath = Join-Path $Script:RootDir "home\.chezmoiscripts\windows\run_onchange_after_configure-ollama.ps1.tmpl"
        $content = Get-Content $scriptPath -Raw
        $content | Should -Match "OLLAMA_HOST.*127\.0\.0\.1"
    }

    It "should set OLLAMA_NOHISTORY" {
        $scriptPath = Join-Path $Script:RootDir "home\.chezmoiscripts\windows\run_onchange_after_configure-ollama.ps1.tmpl"
        $content = Get-Content $scriptPath -Raw
        $content | Should -Match "OLLAMA_NOHISTORY.*true"
    }

    It "should create a firewall rule" {
        $scriptPath = Join-Path $Script:RootDir "home\.chezmoiscripts\windows\run_onchange_after_configure-ollama.ps1.tmpl"
        $content = Get-Content $scriptPath -Raw
        $content | Should -Match "New-NetFirewallRule"
        $content | Should -Match "Block Ollama Outbound"
    }

    It "should block outbound direction" {
        $scriptPath = Join-Path $Script:RootDir "home\.chezmoiscripts\windows\run_onchange_after_configure-ollama.ps1.tmpl"
        $content = Get-Content $scriptPath -Raw
        $content | Should -Match "-Direction Outbound"
        $content | Should -Match "-Action Block"
    }
}

Describe "Ollama-Pull Helper" {
    It "should be embedded in the configure script" {
        $scriptPath = Join-Path $Script:RootDir "home\.chezmoiscripts\windows\run_onchange_after_configure-ollama.ps1.tmpl"
        $content = Get-Content $scriptPath -Raw
        $content | Should -Match "ollama-pull"
    }

    It "should disable firewall before pull" {
        $scriptPath = Join-Path $Script:RootDir "home\.chezmoiscripts\windows\run_onchange_after_configure-ollama.ps1.tmpl"
        $content = Get-Content $scriptPath -Raw
        $content | Should -Match "Disable-NetFirewallRule"
    }

    It "should re-enable firewall in finally block" {
        $scriptPath = Join-Path $Script:RootDir "home\.chezmoiscripts\windows\run_onchange_after_configure-ollama.ps1.tmpl"
        $content = Get-Content $scriptPath -Raw
        $content | Should -Match "finally"
        $content | Should -Match "Enable-NetFirewallRule"
    }

    It "should require the Model parameter" {
        $scriptPath = Join-Path $Script:RootDir "home\.chezmoiscripts\windows\run_onchange_after_configure-ollama.ps1.tmpl"
        $content = Get-Content $scriptPath -Raw
        $content | Should -Match "Mandatory.*=.*\`$true"
    }
}

Describe "Chezmoi Config Template" {
    It "should contain Windows roles section" {
        $configPath = Join-Path $Script:RootDir "home\.chezmoi.toml.tmpl"
        $content = Get-Content $configPath -Raw
        $content | Should -Match "roles\.ai"
        $content | Should -Match "roles\.developer"
        $content | Should -Match "roles\.gaming"
    }

    It "should gate roles behind Windows OS check" {
        $configPath = Join-Path $Script:RootDir "home\.chezmoi.toml.tmpl"
        $content = Get-Content $configPath -Raw
        $content | Should -Match 'eq .chezmoi.os "windows"'
    }
}