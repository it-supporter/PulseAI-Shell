function Set-PulseDevTheme {

    $resolved = Resolve-Path $script:DevThemePath -ErrorAction SilentlyContinue
    if ($resolved) {
        Set-PulseTheme -ThemePath $resolved
    }
}
