function Initialize-PulseAIShell {
<#
.SYNOPSIS
Initialize the PulseAI shell runtime and prompt integration.
.PULSE Tier Common
#>

    [CmdletBinding()]
    param(
        [switch]$Force
    )

    Set-StrictMode -Version Latest

    # ---------------------------------
    # Idempotent guard
    # ---------------------------------

    if (-not (Get-Variable PulseShellInitialized -Scope Script -ErrorAction SilentlyContinue)) {
        $script:PulseShellInitialized = $false
    }

    if ($script:PulseShellInitialized -and -not $Force) {
        return
    }

    # ---------------------------------
    # Verify oh-my-posh availability
    # ---------------------------------

    $omp = Get-Command oh-my-posh -ErrorAction SilentlyContinue
    if (-not $omp) {
        Write-Verbose "[PulseAI.Shell] oh-my-posh not found."
        return
    }

    # ---------------------------------
    # Ensure default theme exists
    # ---------------------------------

    $themePath = $script:DevThemePath
    if (-not (Test-Path $themePath)) {
        Write-Verbose "[PulseAI.Shell] Theme not found: $themePath"
        return
    }

    # ---------------------------------
    # Enforce UTF-8 console encoding (hard lock)
    # ---------------------------------

    try {
        $utf8 = [System.Text.UTF8Encoding]::new($false)

        [Console]::InputEncoding  = $utf8
        [Console]::OutputEncoding = $utf8
        $global:OutputEncoding    = $utf8

        if ($IsWindows) {
            cmd /c chcp 65001 > $null 2>&1
        }
    }
    catch {
        Write-Verbose "[PulseAI.Shell] UTF-8 enforcement failed: $_"
    }

    # ---------------------------------
    # Warm OMP runtime ONCE
    # ---------------------------------

    Write-Verbose "[PulseAI.Shell] Warming oh-my-posh runtime."

    try {
        $ompInit = oh-my-posh init pwsh --print
        Invoke-Expression $ompInit
    }
    catch {
        Write-Verbose "[PulseAI.Shell] OMP init failed: $_"
    }

    # ---------------------------------
    # Console geometry stabilization
    # ---------------------------------

    try {
        $raw = $Host.UI.RawUI

        $win = $raw.WindowSize
        $buf = $raw.BufferSize

        $raw.BufferSize = $buf
        $raw.WindowSize = $win
    }
    catch {
        Write-Verbose "[PulseAI.Shell] Console stabilization skipped: $_"
    }

    # ---------------------------------
    # Ensure theme env is set
    # ---------------------------------

    if (-not $env:POSH_THEME) {
        $env:POSH_THEME = $themePath
    }

    # ---------------------------------
    # Cache signal bridge helper
    # ---------------------------------

    $script:PulseUpdateSignalCmd =
        Get-Command Update-PulseSignalEnvironment `
            -Module PulseAI.Shell `
            -ErrorAction SilentlyContinue

    # ---------------------------------
    # Install minimal Pulse prompt shim
    # ---------------------------------

    Write-Verbose "[PulseAI.Shell] Installing Pulse prompt shim."

    function global:prompt {

        # Refresh Pulse → ENV bridge
        if ($script:PulseUpdateSignalCmd) {
            try { & $script:PulseUpdateSignalCmd } catch {}
        }

        # Let OMP render the prompt
        try {
            return (oh-my-posh print primary --config $env:POSH_THEME)
        }
        catch {
            return "PS $($executionContext.SessionState.Path.CurrentLocation)> "
        }
    }

    # ---------------------------------
    # Mark initialized
    # ---------------------------------

    $script:PulseShellInitialized = $true
}

