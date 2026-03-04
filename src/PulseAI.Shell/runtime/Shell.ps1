# ---------------------------------
# Module initialization guard
# ---------------------------------

if (-not (Get-Variable PulseShellInitialized -Scope Script -ErrorAction SilentlyContinue)) {
    $script:PulseShellInitialized = $false
}

function Initialize-PulseAIShell {

    [CmdletBinding()]
    param(
        [switch]$Force
    )

    Set-StrictMode -Version Latest

    if ($script:PulseShellInitialized -and -not $Force) {
        return
    }

    $omp = Get-Command oh-my-posh -ErrorAction SilentlyContinue
    if (-not $omp) {
        Write-Verbose "[PulseAI.Shell] oh-my-posh not found."
        return
    }

    # ---------------------------------
    # Ensure theme
    # ---------------------------------

    if (-not $script:PulseActiveTheme) {
        if (Get-Command Set-PulseDevTheme -ErrorAction SilentlyContinue) {
            Set-PulseDevTheme | Out-Null
        }
    }

    if (-not $env:POSH_THEME -or -not (Test-Path $env:POSH_THEME)) {
        Write-Verbose "[PulseAI.Shell] POSH_THEME missing or invalid."
        return
    }

    # ---------------------------------
    # UTF-8 hard lock
    # ---------------------------------

    try {
        $utf8 = [System.Text.UTF8Encoding]::new($false)
        [Console]::InputEncoding  = $utf8
        [Console]::OutputEncoding = $utf8
        $global:OutputEncoding    = $utf8

        if ($IsWindows) {
            cmd /c chcp 65001 > $null 2>&1
        }
    }
    catch {}

    # ---------------------------------
    # 🔥 REAL OMP INIT
    # ---------------------------------

    try {
        $ompInit = & oh-my-posh init pwsh --print
        Invoke-Expression $ompInit
    }
    catch {
        Write-Verbose "[PulseAI.Shell] OMP init failed: $_"
        return
    }

    # ---------------------------------
    # Pulse signal bridge
    # ---------------------------------

    if (Get-Command Update-PulseSignalEnvironment -ErrorAction SilentlyContinue) {
        Update-PulseSignalEnvironment
    }

    $script:PulseShellInitialized = $true
}