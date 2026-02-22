# =================================
# PulseAI.Shell Module Entry
# =================================

# ---------------------------------
# Module-Level State
# ---------------------------------

# Inside a module, $PSScriptRoot already equals:
# ...\src\PulseAI.Shell
$script:ShellRoot = $PSScriptRoot

# Paths resolved relative to module root; validated at theme activation time
$script:DevThemePath    = Join-Path $script:ShellRoot "..\..\themes\pulseai-dev.omp.json"
$script:CasualThemePath = Join-Path $script:ShellRoot "..\..\themes\pulseai-casual.omp.json"

$script:PulseActiveTheme = $null

# ---------------------------------
# PulseAI Visual Theme Contract (bootstrap safety)
# ---------------------------------
# Ensures the visual contract exists. Theme functions
# are responsible for authoritative values.

if (-not ($Global:PulseTheme -is [hashtable])) {
    $Global:PulseTheme = @{
        Name    = 'Bootstrap'
        Accent  = 'Cyan'
        Success = 'Green'
        Warning = 'Yellow'
        Error   = 'Red'
    }
}

# ---------------------------------
# Load Private Functions
# ---------------------------------

$privatePath = Join-Path $PSScriptRoot "Private"

if (Test-Path $privatePath) {
    Get-ChildItem -Path $privatePath -Filter *.ps1 |
        Sort-Object Name |
        ForEach-Object { . $_.FullName }
}

# ---------------------------------
# Load Public Functions
# ---------------------------------

$publicPath = Join-Path $PSScriptRoot "Public"

if (Test-Path $publicPath) {
    Get-ChildItem -Path $publicPath -Filter *.ps1 |
        Sort-Object Name |
        ForEach-Object { . $_.FullName }
}

# ---------------------------------
# Ergonomic Wrapper Surface
# ---------------------------------
# These provide stable human-friendly verbs while the canonical
# implementation remains the Set-Pulse* functions.

function Use-DevTheme {
    [CmdletBinding()]
    param()

    Set-PulseDevTheme @PSBoundParameters
}

function Use-CasualTheme {
    [CmdletBinding()]
    param()

    Set-PulseCasualTheme @PSBoundParameters
}

# ---------------------------------
# Explicit Public Surface
# ---------------------------------

Export-ModuleMember -Function `
    Initialize-PulseAIShell,
    Set-PulseDevTheme,
    Set-PulseCasualTheme,
    Set-PulseRepo,
    Use-DevTheme,
    Use-CasualTheme