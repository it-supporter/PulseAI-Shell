function Set-PulseCasualTheme {
    <#
.SYNOPSIS
Activates the PulseAI casual theme.
#>

    [CmdletBinding()]
    param(
        [switch]$Silent
    )

    # ---------------------------------
    # Resolve theme path
    # ---------------------------------
    $resolved = Resolve-Path -Path $script:CasualThemePath -ErrorAction SilentlyContinue

    if (-not $resolved) {
        Write-Verbose "[PulseAI.Shell] Casual theme path not found."
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

    $Global:PulseTheme.Name = 'Casual'
    $Global:PulseTheme.Accent = 'DarkCyan'
    $Global:PulseTheme.Success = 'Green'
    $Global:PulseTheme.Warning = 'Yellow'
    $Global:PulseTheme.Error = 'Red'

    # ---------------------------------
    # UX confirmation (ONLY HERE)
    # ---------------------------------
    if (-not $Silent) {
        Write-Host "Theme switched → casual" -ForegroundColor $Global:PulseTheme.Accent
    }
}