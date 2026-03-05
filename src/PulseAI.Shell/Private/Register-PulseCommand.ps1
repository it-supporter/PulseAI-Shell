Set-StrictMode -Version Latest

<#
.SYNOPSIS
Registers a PulseAI CLI command.

.DESCRIPTION
Adds a command to the PulseAI command registry.
Handlers are normalized to scriptblocks so they can
be safely invoked by the command router.
#>

function Register-PulseCommand {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Handler,

        [string]$Description = ""
    )

    # ------------------------------------------------
    # Ensure registry exists (deterministic)
    # ------------------------------------------------

    if (-not $script:PulseCommandRegistry) {
        $script:PulseCommandRegistry = @{}
    }

    # ------------------------------------------------
    # Normalize command name
    # ------------------------------------------------

    $Name = $Name.Trim().ToLowerInvariant()

    if ($Name -notmatch '^[a-z0-9\-]+$') {
        throw "[PulseAI.Shell] Invalid command name: '$Name'"
    }

    Write-Verbose "[PulseAI.Shell] Registering command: $Name"

    # ------------------------------------------------
    # Prevent duplicate registrations
    # ------------------------------------------------

    if ($script:PulseCommandRegistry.ContainsKey($Name)) {
        throw "[PulseAI.Shell] Command already registered: $Name"
    }

    # ------------------------------------------------
    # Normalize handler
    # ------------------------------------------------

    $resolvedHandler = $null

    if ($Handler -is [ScriptBlock]) {

        $resolvedHandler = $Handler

    }
    elseif ($Handler -is [string]) {

        $cmdInfo = Get-Command -Name $Handler -ErrorAction Stop
        $cmdName = $cmdInfo.Name

        $resolvedHandler = {
            param([string[]]$CommandArgs)
            & $cmdName -CommandArgs $CommandArgs
        }

    }
    elseif ($Handler -is [System.Management.Automation.CommandInfo]) {

        $cmdName = $Handler.Name

        $resolvedHandler = {
            param([string[]]$CommandArgs)
            & $cmdName -CommandArgs $CommandArgs
        }

    }
    else {

        throw "[PulseAI.Shell] Invalid command handler type: $($Handler.GetType().Name)"

    }

    # ------------------------------------------------
    # Register command
    # ------------------------------------------------

    $script:PulseCommandRegistry[$Name] = [PSCustomObject]@{
        Name        = $Name
        Handler     = $resolvedHandler
        Description = $Description
    }

    # ------------------------------------------------
    # Reset prefix cache
    # ------------------------------------------------

    if ($script:PulseCommandPrefixCache) {
        $script:PulseCommandPrefixCache = @{}
    }

}