#Requires -Version 5.1
<#
.SYNOPSIS
    Benchmark PowerShell startup time and write results in benchmark-action format.

.DESCRIPTION
    Uses hyperfine to measure pwsh interactive startup time, then writes
    results as JSON compatible with benchmark-action/github-action-benchmark.
    Mirrors the bash run_benchmark.sh used for zsh on macOS.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RootDir = (Resolve-Path "$PSScriptRoot\..").Path
$ResultsFile = Join-Path $RootDir "benchmark-results.json"

Write-Host "==> Benchmarking PowerShell startup..."

# Verify hyperfine is available
if (-not (Get-Command hyperfine -ErrorAction SilentlyContinue)) {
    Write-Error "hyperfine is required. Install with: winget install sharkdp.hyperfine"
    exit 1
}

# Run hyperfine and capture JSON output
$tempFile = [System.IO.Path]::GetTempFileName()
$hyperfineJson = "${tempFile}.json"

hyperfine `
    --warmup 3 `
    --runs 10 `
    --export-json $hyperfineJson `
    "pwsh -NoProfile -NonInteractive -Command exit"

# Parse results
$data = Get-Content $hyperfineJson -Raw | ConvertFrom-Json
$mean = $data.results[0].mean
$stddev = $data.results[0].stddev

# Write benchmark-action compatible JSON
@"
[
  {
    "name": "pwsh startup (NoProfile)",
    "unit": "seconds",
    "value": $mean,
    "range": "$stddev",
    "extra": "hyperfine --warmup 3 --runs 10"
  }
]
"@ | Set-Content -Path $ResultsFile -Encoding UTF8

Write-Host "==> Benchmark results:"
Write-Host "    Mean: ${mean}s"
Write-Host "    Stddev: ${stddev}s"
Write-Host "==> Results written to benchmark-results.json"

# Cleanup
Remove-Item $tempFile -ErrorAction SilentlyContinue
Remove-Item $hyperfineJson -ErrorAction SilentlyContinue
