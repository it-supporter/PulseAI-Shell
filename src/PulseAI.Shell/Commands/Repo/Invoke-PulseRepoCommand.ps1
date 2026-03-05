Set-StrictMode -Version Latest

<#
.SYNOPSIS
Handles PulseAI repository commands.

.DESCRIPTION
Provides workspace repository operations such as listing
repositories and inspecting workspace health.

Examples:

    pulse repo list
    pulse repo dirty
    pulse repo status
    pulse repo doctor
#>

function Invoke-PulseRepoCommand {

    [CmdletBinding()]
    param(
        [string[]]$CommandArgs
    )

    Write-Verbose "Probe: Invoke-PulseRepoCommand invoked"

    # ---------------------------------
    # StrictMode-safe normalization
    # ---------------------------------

    if (-not $CommandArgs) {
        $CommandArgs = @()
    }

    # ---------------------------------
    # No arguments → help
    # ---------------------------------

    if ($CommandArgs.Count -eq 0) {

        Show-PulseRepoHelp
        return

    }

    $subCommand = $CommandArgs[0].ToLowerInvariant()

    $remainingArgs =
        if ($CommandArgs.Count -gt 1) {
            $CommandArgs[1..($CommandArgs.Count - 1)]
        }
        else {
            @()
        }

    # ---------------------------------
    # Workspace snapshot
    # ---------------------------------

    $workspace = Get-PulseWorkspaceState

    if (-not $workspace -or -not $workspace.Repositories) {

        Write-Host ""
        Write-Host "Workspace state unavailable." -ForegroundColor Yellow
        Write-Host ""

        return

    }

    # ---------------------------------
    # Subcommand routing
    # ---------------------------------

    switch ($subCommand) {

        "list" {

            $workspace.Repositories |
                Sort-Object RepoName |
                Select-Object `
                    RepoName,
                    Branch,
                    LocalVersion,
                    RemoteVersion,
                    IsDirty,
                    Ahead,
                    Behind |
                Format-Table -AutoSize

            return
        }

        "dirty" {

            $workspace.Repositories |
                Where-Object IsDirty |
                Sort-Object RepoName |
                Select-Object `
                    RepoName,
                    Branch,
                    LocalVersion,
                    RemoteVersion |
                Format-Table -AutoSize

            return
        }

        "status" {

            $workspace.Repositories |
                Sort-Object RepoName |
                Select-Object `
                    RepoName,
                    Branch,
                    IsDirty,
                    Ahead,
                    Behind |
                Format-Table -AutoSize

            return
        }

        "doctor" {

            $issues = @()

            foreach ($repo in $workspace.Repositories) {

                if ($repo.IsDirty) {

                    $issues += [pscustomobject]@{
                        Repo    = $repo.RepoName
                        Issue   = "Dirty working tree"
                        Details = "Uncommitted changes detected"
                    }

                }

                if ($repo.Ahead -gt 0) {

                    $issues += [pscustomobject]@{
                        Repo    = $repo.RepoName
                        Issue   = "Local ahead of remote"
                        Details = "$($repo.Ahead) commits not pushed"
                    }

                }

                if ($repo.Behind -gt 0) {

                    $issues += [pscustomobject]@{
                        Repo    = $repo.RepoName
                        Issue   = "Behind remote"
                        Details = "$($repo.Behind) commits need pull"
                    }

                }

                if (-not $repo.RemoteVersion) {

                    $issues += [pscustomobject]@{
                        Repo    = $repo.RepoName
                        Issue   = "Missing remote version"
                        Details = "Origin metadata unavailable"
                    }

                }

            }

            Write-Host ""
            Write-Host "PulseAI Repository Doctor" -ForegroundColor Cyan
            Write-Host "──────────────────────────"
            Write-Host ""

            if ($issues.Count -eq 0) {

                Write-Host "Workspace health: OK" -ForegroundColor Green
                Write-Host ""

                return

            }

            $issues |
                Sort-Object Repo |
                Format-Table Repo, Issue, Details -AutoSize

            Write-Host ""
            Write-Host "Issues detected: $($issues.Count)" -ForegroundColor Yellow
            Write-Host ""

            return
        }

        default {

            Write-Host ""
            Write-Host "Unknown repo command: $subCommand" -ForegroundColor Red

            Show-PulseRepoHelp
            return
        }

    }

}

# ---------------------------------
# Help Panel
# ---------------------------------

function Show-PulseRepoHelp {

    Write-Host ""
    Write-Host "PulseAI Repo Commands" -ForegroundColor Cyan
    Write-Host "─────────────────────"
    Write-Host ""

    Write-Host "pulse repo list"   -ForegroundColor Yellow -NoNewline
    Write-Host "     List all repositories"

    Write-Host "pulse repo dirty"  -ForegroundColor Yellow -NoNewline
    Write-Host "    Show repositories with uncommitted changes"

    Write-Host "pulse repo status" -ForegroundColor Yellow -NoNewline
    Write-Host "   Show repository state summary"

    Write-Host "pulse repo doctor" -ForegroundColor Yellow -NoNewline
    Write-Host "   Diagnose repository health"

    Write-Host ""

}

# ---------------------------------
# Command Registration
# ---------------------------------

Register-PulseCommand `
    -Name "repo" `
    -Handler ${function:Invoke-PulseRepoCommand} `
    -Description "Workspace repository operations"