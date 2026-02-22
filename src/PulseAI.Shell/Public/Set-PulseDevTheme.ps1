function Set-PulseDevTheme {
<#
.SYNOPSIS
Activates the PulseAI developer theme.
#>

    [CmdletBinding()]
    param(
        [switch]$Silent
    )

    # ---------------------------------
    # Resolve theme path
    # ---------------------------------
    $resolved = Resolve-Path -Path $script:DevThemePath -ErrorAction SilentlyContinue

    if (-not $resolved) {
        Write-Verbose "[PulseAI.Shell] Dev theme path not found."
        return
    }

    # ---------------------------------
    # Apply prompt theme (engine — silent)
    # ---------------------------------
    Set-PulseTheme -ThemePath $resolved.Path

    # ---------------------------------
    # Update visual contract (mutate)
    # ---------------------------------
    if (-not ($Global:PulseTheme -is [hashtable])) {
        $Global:PulseTheme = @{}
    }

    $Global:PulseTheme.Name    = 'Dev'
    $Global:PulseTheme.Accent  = 'Cyan'
    $Global:PulseTheme.Success = 'Green'
    $Global:PulseTheme.Warning = 'Yellow'
    $Global:PulseTheme.Error   = 'Red'

    # ---------------------------------
    # UX confirmation (ONLY HERE)
    # ---------------------------------
    if (-not $Silent) {
        Write-Host "Theme switched → dev" -ForegroundColor $Global:PulseTheme.Accent
    }
}