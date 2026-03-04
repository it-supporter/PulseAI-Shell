function Set-PulseDevTheme {

    [CmdletBinding()]
    param(
        [switch]$Silent
    )

    Set-StrictMode -Version Latest

    # --------------------------------------------------
    # Idempotency: do nothing if already active
    # --------------------------------------------------

    if ($script:PulseActiveTheme -eq 'dev') {
        return
    }

    if (-not $script:DevThemePath) { return }

    $resolved = Resolve-Path $script:DevThemePath -ErrorAction SilentlyContinue
    if (-not $resolved) { return }

    $themePath = $resolved.Path

    $omp = Get-Command oh-my-posh -ErrorAction SilentlyContinue
    if (-not $omp) { return }

    # --------------------------------------------------
    # Apply theme contract
    # --------------------------------------------------

    Set-PulseTheme -ThemePath $themePath
    $env:POSH_THEME = $themePath

    # --------------------------------------------------
    # Reinitialize OMP with explicit config
    # --------------------------------------------------

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

    # --------------------------------------------------
    # Visual Contract
    # --------------------------------------------------

    if (-not ($Global:PulseTheme -is [hashtable])) {
        $Global:PulseTheme = @{}
    }

    $Global:PulseTheme.Name    = 'Dev'
    $Global:PulseTheme.Accent  = 'Cyan'
    $Global:PulseTheme.Success = 'Green'
    $Global:PulseTheme.Warning = 'Yellow'
    $Global:PulseTheme.Error   = 'Red'

    $script:PulseActiveTheme = 'dev'

    if (-not $Silent) {
        Write-Host "Theme switched → dev" -ForegroundColor Cyan
    }
}