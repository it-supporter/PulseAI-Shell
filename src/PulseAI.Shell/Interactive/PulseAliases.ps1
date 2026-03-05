# =================================
# PulseAI Public Aliases
# =================================
# Policy:
# - Aliases are session-scoped (Global within the user session)
# - Functions remain the formal exported API surface
# - Aliases provide interactive ergonomics only
# - No persistent system/global environment mutation


# ---------------------------------
# Core verbs
# ---------------------------------

# Primary PulseAI command surface entrypoint

# Structured help surface for the PulseAI ecosystem
Set-Alias -Name pulse-help -Value Get-PulseHelp -Scope Global
Set-Alias -Name ph         -Value Get-PulseHelp -Scope Global

# Alias viewer (self-introspection)
Set-Alias -Name pulse-aliases   -Value Show-PulseAliases      -Scope Global
Set-Alias -Name pa              -Value Show-PulseAliases      -Scope Global

# Repository synchronization (Environment capability)
Set-Alias -Name pulse-sync      -Value Invoke-RepoSync        -Scope Global


# ---------------------------------
# Cross-module capabilities (conditional)
# ---------------------------------
# These aliases are only created if the providing module is present.
# This keeps PulseAI portable and Spark-friendly.


# Bootstrap surface (future)
# if (Get-Command Invoke-PulseBootstrap -ErrorAction SilentlyContinue) {
#     Set-Alias -Name pulse-bootstrap -Value Invoke-PulseBootstrap -Scope Global
# }


# ---------------------------------
# Navigation
# ---------------------------------

# Repository quick navigation helper
Set-Alias -Name repo            -Value Set-PulseRepo          -Scope Global

# ---------------------------------
# Theme control
# ---------------------------------

# Switch shell to developer-focused theme
Set-Alias -Name devmode         -Value Use-DevTheme           -Scope Global

# Switch shell to casual/minimal theme
Set-Alias -Name chill           -Value Use-CasualTheme        -Scope Global


# ---------------------------------
# Ergonomic shortcuts
# ---------------------------------

# Quick RipClip module reload helper
Set-Alias -Name rrc             -Value Update-RipClip           -Scope Global
Set-Alias -Name pa              -Value Show-PulseAliases        -Scope Global
Set-Alias -Name flush           -Value Invoke-PulseFlushModule  -Scope Global

# ---------------------------------
# Future examples (disabled)
# ---------------------------------
# Set-Alias syncall Invoke-RepoSync
