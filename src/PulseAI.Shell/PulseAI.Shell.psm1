# =================================
# PulseAI.Shell Module Entry
# =================================

# ---------------------------------
# Module-Level State
# ---------------------------------

# Inside a module, $PSScriptRoot already equals:
# ...\src\PulseAI.Shell
$script:ShellRoot = $PSScriptRoot

$script:DevThemePath    = Join-Path $script:ShellRoot "..\..\themes\pulseai-dev.omp.json"
$script:CasualThemePath = Join-Path $script:ShellRoot "..\..\themes\pulseai-casual.omp.json"

$script:PulseActiveTheme = $null

# ---------------------------------
# Load Private Functions
# ---------------------------------

$privatePath = Join-Path $PSScriptRoot "Private"

if (Test-Path $privatePath) {
    Get-ChildItem -Path $privatePath -Filter *.ps1 | ForEach-Object {
        . $_.FullName
    }
}

# ---------------------------------
# Load Public Functions
# ---------------------------------

$publicPath = Join-Path $PSScriptRoot "Public"

if (Test-Path $publicPath) {
    Get-ChildItem -Path $publicPath -Filter *.ps1 | ForEach-Object {
        . $_.FullName
    }
}

# ---------------------------------
# Explicit Public Surface
# ---------------------------------

Export-ModuleMember -Function `
    Initialize-PulseAIShell,
    Set-PulseDevTheme,
    Set-PulseCasualTheme,
    Set-PulseRepo

