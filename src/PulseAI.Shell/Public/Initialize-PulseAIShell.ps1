# ---------------------------------
# Module initialization guard
# ---------------------------------

if (-not (Test-Path variable:script:PulseShellInitialized)) {
    $script:PulseShellInitialized = $false
}

function Initialize-PulseAIShell {

    [CmdletBinding()]
    param(
        [switch]$Force
    )

    Set-StrictMode -Version Latest

    if ($script:PulseShellInitialized -and -not $Force) {
        return
    }

    $omp = Get-Command oh-my-posh -ErrorAction SilentlyContinue
    if (-not $omp) { return }

    # ---------------------------------
    # THEME RESOLUTION (single source of truth)
    # ---------------------------------

    if (Get-Command Set-PulseDevTheme -ErrorAction SilentlyContinue) {
        # Silent during shell bootstrap
        Set-PulseDevTheme -Silent
    }

    if (-not $env:POSH_THEME -or -not (Test-Path $env:POSH_THEME)) {
        Write-Verbose "[PulseAI.Shell] No valid theme."
        return
    }

    # ---------------------------------
    # INIT OMP WITH THEME (locked)
    # ---------------------------------

    try {
        Invoke-Expression (
            & oh-my-posh init pwsh `
                --config $env:POSH_THEME `
                --print |
            Out-String
        )
    }
    catch {
        Write-Verbose "[PulseAI.Shell] OMP init failed: $_"
        return
    }

    # ---------------------------------
    # Pulse data bridge (no prompt ownership)
    # ---------------------------------

    if (Get-Command Initialize-PulsePromptIndicator -ErrorAction SilentlyContinue) {
        Initialize-PulsePromptIndicator
    }

    if (Get-Command Update-PulseSignalEnvironment -ErrorAction SilentlyContinue) {
        Update-PulseSignalEnvironment
    }

    $script:PulseShellInitialized = $true
}