Set-StrictMode -Version Latest

<#
.SYNOPSIS
PulseAI Doctor command entry point.

.DESCRIPTION
Provides diagnostics for PulseAI runtime, architecture,
workspace state, repositories, and module health.

Supports git-style prefix resolution for subcommands.
#>

function Invoke-PulseDoctor {

    [CmdletBinding()]
    param(
        [string[]]$CommandArgs
    )

    Write-Verbose "[PulseAI.Shell] Doctor command invoked"

    # ------------------------------------------------
    # StrictMode-safe normalization
    # ------------------------------------------------

    if ($null -eq $CommandArgs) {
        $CommandArgs = @()
    }

    # ------------------------------------------------
    # Doctor command registry
    # ------------------------------------------------

    $doctorCommands = [ordered]@{
        architecture = "Invoke-PulseDoctorArchitecture"
        workspace    = "Invoke-PulseDoctorWorkspace"
        repos        = "Invoke-PulseDoctorRepos"
        modules      = "Invoke-PulseDoctorModules"
    }

    # ------------------------------------------------
    # No args → help
    # ------------------------------------------------

    if ($CommandArgs.Count -eq 0) {
        Show-PulseDoctorHelp
        return
    }

    $input = $CommandArgs[0].ToLowerInvariant()

    $remainingArgs = @()

    if ($CommandArgs.Count -gt 1) {
        $remainingArgs = $CommandArgs[1..($CommandArgs.Count - 1)]
    }

    # ------------------------------------------------
    # Exact match
    # ------------------------------------------------

    if ($doctorCommands.ContainsKey($input)) {

        $handler = $doctorCommands[$input]

        if (-not (Get-Command $handler -ErrorAction Ignore)) {
            throw "[PulseAI.Shell] Doctor handler '$handler' not found."
        }

        & $handler -CommandArgs $remainingArgs
        return
    }

    # ------------------------------------------------
    # Prefix resolution
    # ------------------------------------------------

    $matches = @()

    foreach ($key in $doctorCommands.Keys) {

        if ($key.StartsWith($input)) {
            $matches += $key
        }

    }

    if ($matches.Count -eq 1) {

        $resolved = $matches[0]
        $handler  = $doctorCommands[$resolved]

        if (-not (Get-Command $handler -ErrorAction Ignore)) {
            throw "[PulseAI.Shell] Doctor handler '$handler' not found."
        }

        & $handler -CommandArgs $remainingArgs
        return
    }

    # ------------------------------------------------
    # Ambiguous prefix
    # ------------------------------------------------

    if ($matches.Count -gt 1) {

        Write-Host ""
        Write-Host "Ambiguous doctor command '$input'" -ForegroundColor Yellow
        Write-Host ""

        foreach ($m in ($matches | Sort-Object)) {
            Write-Host "  $m"
        }

        Write-Host ""
        return
    }

    # ------------------------------------------------
    # Unknown command
    # ------------------------------------------------

    Write-Host ""
    Write-Host "Unknown doctor command: $input" -ForegroundColor Red
    Write-Host ""

    Show-PulseDoctorHelp
}

# ------------------------------------------------
# Register command with Pulse CLI
# ------------------------------------------------

Register-PulseCommand `
    -Name "doctor" `
    -Handler "Invoke-PulseDoctor" `
    -Description "PulseAI system diagnostics"