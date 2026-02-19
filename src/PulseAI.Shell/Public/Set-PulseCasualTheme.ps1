function Set-PulseCasualTheme {

    $resolved = Resolve-Path $script:CasualThemePath -ErrorAction SilentlyContinue
    if ($resolved) {
        Set-PulseTheme -ThemePath $resolved
    }
}
