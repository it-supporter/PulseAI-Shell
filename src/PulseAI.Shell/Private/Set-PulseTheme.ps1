function Set-PulseTheme {

    param([string]$ThemePath)

    if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        return
    }

    if (-not (Test-Path $ThemePath)) {
        return
    }

    $ompInit = oh-my-posh init pwsh --config $ThemePath
    Invoke-Expression $ompInit

    $script:PulseActiveTheme = $ThemePath
}
