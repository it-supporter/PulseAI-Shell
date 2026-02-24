# ---------------------------------
# Module initialization guard
# ---------------------------------

if (-not (Get-Variable -Name PulseShellInitialized -Scope Script -ErrorAction SilentlyContinue)) {
    $script:PulseShellInitialized = $false
}
function Initialize-PulseAIShell {
<#
.SYNOPSIS
Initialize PulseAI Shell UX components for the current session.
.PULSE Tier Common
#>

    [CmdletBinding()]
    param()

    Set-StrictMode -Version Latest

    # --------------------------------------------------
    # Idempotency guard
    # --------------------------------------------------

    if ($script:PulseShellInitialized) {
        return
    }

    # --------------------------------------------------
    # Ensure oh-my-posh is available
    # --------------------------------------------------

    $omp = Get-Command oh-my-posh -ErrorAction SilentlyContinue

    if ($omp) {

        # --------------------------------------------------
        # Auto-load Dev theme if none active
        # --------------------------------------------------

        if (-not $script:PulseActiveTheme) {

            if (Get-Command Set-PulseDevTheme -ErrorAction SilentlyContinue) {
                Set-PulseDevTheme | Out-Null
            }
        }
    }

    # --------------------------------------------------
    # Prompt indicator bootstrap (future hook point)
    # --------------------------------------------------

    if (Get-Command Initialize-PulsePromptIndicator -ErrorAction SilentlyContinue) {
        Initialize-PulsePromptIndicator
    }

    # ---------------------------------
    # Initial Pulse signal projection
    # ---------------------------------

    if (Get-Command Update-PulseSignalEnvironment -ErrorAction SilentlyContinue) {
        Update-PulseSignalEnvironment
    }

    $script:PulseShellInitialized = $true
}