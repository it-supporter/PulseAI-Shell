# =================================
# PulseAI.Shell Module Entry
# =================================

Set-StrictMode -Version Latest

# ---------------------------------
# Module-Level State (MUST be first)
# ---------------------------------

# Inside a module, $PSScriptRoot equals:
# ...\src\PulseAI.Shell
$script:ShellRoot = $PSScriptRoot

# --- Theme paths (normalized & deterministic) ---
# --- Theme paths (normalized & canonical) ---
$script:DevThemePath = Join-Path $script:ShellRoot '..\..\themes\pulseai-dev.omp.json'
$script:CasualThemePath = Join-Path $script:ShellRoot '..\..\themes\pulseai-casual.omp.json'

# Canonicalize if possible (defensive hardening)
try {
    if (Test-Path $script:DevThemePath) {
        $script:DevThemePath = (Resolve-Path $script:DevThemePath).Path
    }

    if (Test-Path $script:CasualThemePath) {
        $script:CasualThemePath = (Resolve-Path $script:CasualThemePath).Path
    }
}
catch {
    Write-Verbose "[PulseAI.Shell] Theme path normalization failed: $_"
}

$script:PulseActiveTheme = $null

# ---------------------------------
# PulseAI Visual Theme Contract (bootstrap safety)
# ---------------------------------

if (-not (Get-Variable -Name PulseTheme -Scope Global -ErrorAction SilentlyContinue)) {
    $Global:PulseTheme = @{
        Name    = 'Bootstrap'
        Accent  = 'Cyan'
        Success = 'Green'
        Warning = 'Yellow'
        Error   = 'Red'
    }
}

# ---------------------------------
# Load runtime primitives (AFTER state)
# ---------------------------------

. (Join-Path $PSScriptRoot 'runtime\PromptIndicator.ps1')
. (Join-Path $PSScriptRoot 'runtime\Shell.ps1')

# --- Debug (safe but useful) ---
Write-Host "[DEBUG] PSScriptRoot = $PSScriptRoot"
Write-Host "[DEBUG] PromptIndicator exists = $(Test-Path (Join-Path $PSScriptRoot 'runtime\PromptIndicator.ps1'))"

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
    Use-CasualTheme,
    Get-PulsePromptIndicator,
    Update-PulseSignalEnvironment

# ---------------------------------
# Automatic shell bootstrap (safe)
# ---------------------------------

try {
    if (Get-Command Initialize-PulseAIShell -ErrorAction SilentlyContinue) {
        Initialize-PulseAIShell
    }
}
catch {
    Write-Verbose "[PulseAI.Shell] Automatic initialization failed: $_"
}