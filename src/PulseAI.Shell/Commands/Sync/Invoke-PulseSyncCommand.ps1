Set-StrictMode -Version Latest

<#
.SYNOPSIS
Handles the PulseAI sync command.

.DESCRIPTION
Parses CLI arguments for the sync command and dispatches
to repository synchronization operations.

Supports:
    pulse sync repos
#>

function Invoke-PulseSyncCommand {

    [CmdletBinding()]
    param(
        [string[]]$CommandArgs
    )

    Write-Verbose "Probe: Invoke-PulseSyncCommand invoked"

    # -------------------------------
    # No arguments → show help
    # -------------------------------

    if (-not $CommandArgs -or $CommandArgs.Count -eq 0) {

        Show-PulseSyncHelp
        return

    }

    # -------------------------------
    # Parse subcommand
    # -------------------------------

    $subCommand = $CommandArgs[0].ToLower()

    $remainingArgs =
        if ($CommandArgs.Count -gt 1) {
            $CommandArgs[1..($CommandArgs.Count - 1)]
        }
        else {
            @()
        }

    # -------------------------------
    # Subcommand routing
    # -------------------------------

    switch ($subCommand) {

        "repos" {

            Update-PulseWorkspaceRepos @remainingArgs
            return

        }

        default {

            Write-Host ""
            Write-Host "Unknown sync target: $subCommand" -ForegroundColor Red

            Show-PulseSyncHelp
            return

        }

    }

}

# ------------------------------------------------
# Command registration (auto CLI discovery)
# ------------------------------------------------

Register-PulseCommand `
    -Name "sync" `
    -Handler "Invoke-PulseSyncCommand" `
    -Description "Synchronize PulseAI workspace repositories"