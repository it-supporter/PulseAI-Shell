Set-StrictMode -Version Latest

function Show-PulseCommandDiscovery {

    [CmdletBinding()]
    param()

    Write-Verbose "Probe: Show-PulseCommandDiscovery invoked"

    $caps = Get-PulseCommandCapabilities

    Write-Host ""
    Write-Host "PulseAI Commands" -ForegroundColor Cyan
    Write-Host "────────────────" -ForegroundColor DarkGray

    foreach ($cmd in $caps.Keys | Sort-Object) {

        $desc = $caps[$cmd].Description

        "{0,-10} {1}" -f $cmd,$desc | Write-Host

    }

    Write-Host ""

}