#Requires -Version 5.1
<#
.SYNOPSIS
    Lint PowerShell scripts with PSScriptAnalyzer.
    Mirrors scripts/lint.sh for shell scripts.

.DESCRIPTION
    Finds all .ps1 and .ps1.tmpl files in the repo, strips chezmoi template
    directives from .tmpl files, then runs PSScriptAnalyzer at Warning level.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RootDir = (Resolve-Path "$PSScriptRoot\..").Path

Write-Host "==> Linting PowerShell scripts..."

# Ensure PSScriptAnalyzer is available
if (-not (Get-Module -ListAvailable PSScriptAnalyzer)) {
    Write-Host "    → Installing PSScriptAnalyzer..."
    Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser
}

$files = Get-ChildItem -Path $RootDir -Recurse -Include "*.ps1", "*.ps1.tmpl" |
    Where-Object { $_.FullName -notlike "*\.git\*" }

$errors = 0

foreach ($file in $files) {
    $relativePath = $file.FullName.Substring($RootDir.Length + 1)
    Write-Host "  Checking $relativePath..."

    $content = Get-Content $file.FullName -Raw

    # Strip chezmoi template directives from .tmpl files
    if ($file.Name -match "\.tmpl$") {
        $content = $content -replace '\{\{.*?\}\}', ''
    }

    $tempFile = [System.IO.Path]::GetTempFileName() + ".ps1"
    $content | Set-Content $tempFile -Encoding UTF8

    $results = Invoke-ScriptAnalyzer -Path $tempFile -Severity Warning, Error -ExcludeRule PSAvoidUsingWriteHost, PSUseBOMForUnicodeEncodedFile, PSAvoidUsingInvokeExpression
    Remove-Item $tempFile

    if ($results) {
        $results | Format-Table -AutoSize
        $errors++
    }
}

if ($errors -gt 0) {
    Write-Host "==> Found issues in $errors file(s)"
    exit 1
}

Write-Host "==> All PowerShell scripts passed"
