Set-StrictMode -Version Latest

<#
.SYNOPSIS
Returns PulseAI CLI command capability registry.

.DESCRIPTION
Exposes the registered PulseAI CLI commands collected through
Register-PulseCommand. This enables dynamic command discovery
and plugin-style command extension.
#>

function Get-PulseCommandCapabilities {

    [CmdletBinding()]
    param()

    Write-Verbose "[PulseAI.Shell] Get-PulseCommandCapabilities invoked"

    # ------------------------------------------------
    # Ensure registry variable exists
    # ------------------------------------------------

    $registryVar = Get-Variable `
        -Name PulseCommandRegistry `
        -Scope Script `
        -ErrorAction SilentlyContinue

    if ($null -eq $registryVar) {
        return @{}
    }

    $registry = $registryVar.Value

    if ($null -eq $registry -or $registry.Count -eq 0) {
        return @{}
    }

    # ------------------------------------------------
    # Return a copy (protect registry)
    # ------------------------------------------------

    $capabilities = @{}

    foreach ($entry in ($registry.GetEnumerator() | Sort-Object Key)) {

        $name = $entry.Key
        $value = $entry.Value

        if ($null -eq $value) {
            continue
        }

        $capabilities[$name] = $value
    }

    return $capabilities
}