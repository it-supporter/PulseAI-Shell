function Initialize-PulseAIShell {

    # Apply default theme
    Set-PulseDevTheme

    # UX Aliases
    Set-Alias devmode Set-PulseDevTheme -Scope Global
    Set-Alias chill   Set-PulseCasualTheme -Scope Global
    Set-Alias repo Set-PulseRepo -Scope Global
}
