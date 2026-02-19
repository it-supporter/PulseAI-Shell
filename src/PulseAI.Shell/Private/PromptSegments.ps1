function Get-PulseIdentitySegment {

    if (-not $Global:PulseConfig) {
        return ""
    }

    return "$($Global:PulseMachineIcon) $env:COMPUTERNAME"
}

function Get-PulsePromptSegment {

    $RepoState = Get-RepoState -Path (Get-Location).Path -ErrorAction SilentlyContinue

    if (-not $RepoState) {
        return ""
    }

    $StateIcons = @()

    if ($RepoState.Dirty)        { $StateIcons += "✏" }
    if ($RepoState.Ahead -gt 0)  { $StateIcons += "↑$($RepoState.Ahead)" }
    if ($RepoState.Behind -gt 0) { $StateIcons += "↓$($RepoState.Behind)" }

    if (-not $StateIcons) {
        $StateIcons = "✔"
    }
    else {
        $StateIcons = $StateIcons -join " "
    }

    return "$($RepoState.ShortName) $($RepoState.Branch) $StateIcons"
}
