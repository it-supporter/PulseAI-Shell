function Set-PulseCasualTheme {

    [CmdletBinding()]
    param(
        [switch]$Silent
    )

    Set-StrictMode -Version Latest

    if ($script:PulseActiveTheme -eq 'casual') {
        return
    }

    if (-not $script:CasualThemePath) { return }

    $resolved = Resolve-Path $script:CasualThemePath -ErrorAction SilentlyContinue
    if (-not $resolved) { return }

    $themePath = $resolved.Path

    $omp = Get-Command oh-my-posh -ErrorAction SilentlyContinue
    if (-not $omp) { return }

    Set-PulseTheme -ThemePath $themePath
    $env:POSH_THEME = $themePath

    try {

        $ompInit = & oh-my-posh init pwsh `
            --config $themePath `
            --print |
            Out-String

        if (-not $ompInit) {
            throw "OMP init returned empty"
        }

        Invoke-Expression $ompInit
    }
    catch {
        Write-Warning "[PulseAI.Shell] Failed to initialize oh-my-posh."
        return
    }

    if (-not ($Global:PulseTheme -is [hashtable])) {
        $Global:PulseTheme = @{}
    }

    $Global:PulseTheme.Name    = 'Casual'
    $Global:PulseTheme.Accent  = 'Magenta'
    $Global:PulseTheme.Success = 'Green'
    $Global:PulseTheme.Warning = 'Yellow'
    $Global:PulseTheme.Error   = 'Red'

    $script:PulseActiveTheme = 'casual'

    if (-not $Silent) {
        Write-Host "Theme switched → casual" -ForegroundColor $Global:PulseTheme.Accent
    }
}