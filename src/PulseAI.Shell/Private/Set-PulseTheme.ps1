function Set-PulseTheme {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ThemePath
    )

    # ---------------------------------
    # Preconditions
    # ---------------------------------
    if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        Write-Verbose "[PulseAI] oh-my-posh not available; theme switch skipped."
        return
    }

    if (-not (Test-Path $ThemePath)) {
        Write-Warning "[PulseAI] Theme file not found: $ThemePath"
        return
    }

    # ---------------------------------
    # Detect no-op switch
    # ---------------------------------
    if ($script:PulseActiveTheme -and
        (Resolve-Path $script:PulseActiveTheme).Path -eq (Resolve-Path $ThemePath).Path) {

        Write-Verbose "[PulseAI] Theme already active."
        return
    }

    # ---------------------------------
    # Apply theme
    # ---------------------------------
    $ompInit = oh-my-posh init pwsh --config $ThemePath
    Invoke-Expression $ompInit

    $script:PulseActiveTheme = $ThemePath

    # ---------------------------------
    # Operator feedback
    # ---------------------------------
    $themeName = [System.IO.Path]::GetFileNameWithoutExtension($ThemePath) `
        -replace '^pulseai-', '' `
        -replace '\.omp$', ''
}