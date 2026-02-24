function Set-PulseTheme {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ThemePath
    )

    # ---------------------------------
    # Preconditions
    # ---------------------------------
    if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        Write-Verbose "[PulseAI] oh-my-posh not available; theme switch skipped."
        return
    }

    if (-not (Test-Path $ThemePath)) {
        Write-Warning "[PulseAI] Theme file not found: $ThemePath"
        return
    }

    # ---------------------------------
    # Normalize paths
    # ---------------------------------

    $resolvedTarget = (Resolve-Path $ThemePath -ErrorAction SilentlyContinue)?.Path
    $resolvedActive = if ($script:PulseActiveTheme) {
        (Resolve-Path $script:PulseActiveTheme -ErrorAction SilentlyContinue)?.Path
    }

    # ---------------------------------
    # Detect no-op
    # ---------------------------------

    if ($resolvedActive -and $resolvedTarget -and $resolvedActive -eq $resolvedTarget) {
        Write-Verbose "[PulseAI] Theme already active."
        return
    }

    # ---------------------------------
    # AUTHORITATIVE STATE UPDATE
    # ---------------------------------

    # 🔴 CRITICAL: do NOT run oh-my-posh init here
    # Your wrapper renders statelessly.

    $env:POSH_THEME = $resolvedTarget
    $script:PulseActiveTheme = $resolvedTarget

    Write-Verbose "[PulseAI] Theme environment updated."
}