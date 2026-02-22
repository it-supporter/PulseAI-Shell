function Initialize-PulseAIShell {
<#
.SYNOPSIS
Initializes the PulseAI shell environment.
#>

    [CmdletBinding()]
    param()

    # Apply default theme quietly
    Set-PulseDevTheme -Silent

    # NOTE:
    # Interactive aliases are owned by PulseAI-Environment.
    # Shell must not redefine them.
}