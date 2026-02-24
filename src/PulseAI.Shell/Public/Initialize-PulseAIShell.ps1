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
    # CRITICAL: Warm OMP runtime ONCE
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
    # Force console width stabilization
    # (fixes first-render rprompt overflow)
    # ---------------------------------

    try {
        $raw = $Host.UI.RawUI
        $buf = $raw.BufferSize
        $raw.BufferSize = $buf
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
    # Cache prompt helpers (HOT PATH)
    # ---------------------------------

    $script:PulseUpdateSignalCmd =
        Get-Command Update-PulseSignalEnvironment `
            -Module PulseAI.Shell `
            -ErrorAction SilentlyContinue

    $script:PulseIndicatorCmd =
        Get-Command Get-PulsePromptIndicator `
            -Module PulseAI.Shell `
            -ErrorAction SilentlyContinue

    # ---------------------------------
    # Install Pulse prompt wrapper
    # ---------------------------------

    Write-Verbose "[PulseAI.Shell] Installing Pulse prompt wrapper."

    function global:prompt {

        # --- Refresh signal environment ---
        if ($script:PulseUpdateSignalCmd) {
            try { & $script:PulseUpdateSignalCmd } catch {}
        }

        # --- Resolve indicator (pure string) ---
        $indicator = ''

        if ($script:PulseIndicatorCmd) {
            try { $indicator = & $script:PulseIndicatorCmd } catch {}
        }

        # --- Deterministic OMP render ---
        if ($env:POSH_THEME -and (Test-Path $env:POSH_THEME)) {
            try {
                $posh = oh-my-posh print primary --config $env:POSH_THEME
                return "$indicator$posh"
            }
            catch {
                Write-Verbose "[PulseAI.Shell] OMP render failed: $_"
            }
        }

        # --- Hard fallback ---
        return "$indicator" + "PS $($executionContext.SessionState.Path.CurrentLocation)> "
    }

    # ---------------------------------
    # Mark initialized
    # ---------------------------------

    $script:PulseShellInitialized = $true
}