# =================================
# PulseAI.Shell Module Entry
# =================================

Set-StrictMode -Version Latest

# ---------------------------------
# Module-Level State (MUST be first)
# ---------------------------------

$script:ShellRoot = $PSScriptRoot

# ---------------------------------
# Command Engine State (StrictMode safe)
# ---------------------------------

if (-not (Get-Variable PulseCommandRegistry -Scope Script -ErrorAction SilentlyContinue)) {
    $script:PulseCommandRegistry = @{}
}

if (-not (Get-Variable PulseCommandPrefixCache -Scope Script -ErrorAction SilentlyContinue)) {
    $script:PulseCommandPrefixCache = @{}
}

# ---------------------------------
# Ensure Shell owns CLI entrypoint
# ---------------------------------

$existingPulse = Get-Command pulse -ErrorAction SilentlyContinue

if ($existingPulse -and $existingPulse.CommandType -eq 'Alias') {

    Write-Verbose "[PulseAI.Shell] Removing bootstrap alias 'pulse'"
    Remove-Item Alias:pulse -Force -ErrorAction SilentlyContinue

}

# ---------------------------------
# Theme paths (normalized & canonical)
# ---------------------------------

$script:DevThemePath    = Join-Path $script:ShellRoot '..\..\themes\pulseai-dev.omp.json'
$script:CasualThemePath = Join-Path $script:ShellRoot '..\..\themes\pulseai-casual.omp.json'

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
# PulseAI Visual Theme Contract
# ---------------------------------

if (-not (Get-Variable PulseTheme -Scope Global -ErrorAction SilentlyContinue)) {

    $Global:PulseTheme = @{
        Name    = 'Bootstrap'
        Accent  = 'Cyan'
        Success = 'Green'
        Warning = 'Yellow'
        Error   = 'Red'
    }

}

# =================================
# Runtime Layer
# =================================

$runtimePath = Join-Path $script:ShellRoot "runtime"

if (Test-Path $runtimePath) {

    $runtimeFiles = @(Get-ChildItem -Path $runtimePath -Filter *.ps1 -File | Sort-Object Name)

    foreach ($file in $runtimeFiles) {

        Write-Verbose "[PulseAI.Shell] Loading runtime: $($file.Name)"
        . $file.FullName

    }

}

# =================================
# Private Engine Layer
# =================================

$privatePath = Join-Path $script:ShellRoot "Private"

if (Test-Path $privatePath) {

    $privateFiles = @(Get-ChildItem -Path $privatePath -Filter *.ps1 -File | Sort-Object Name)

    foreach ($file in $privateFiles) {

        Write-Verbose "[PulseAI.Shell] Loading private: $($file.Name)"
        . $file.FullName

    }

}

# =================================
# Completion Layer
# =================================

$completionPath = Join-Path $script:ShellRoot "Completion"

if (Test-Path $completionPath) {

    $completionFiles = @(Get-ChildItem -Path $completionPath -Filter *.ps1 -File | Sort-Object Name)

    foreach ($file in $completionFiles) {

        Write-Verbose "[PulseAI.Shell] Loading completion: $($file.Name)"
        . $file.FullName

    }

}

# =================================
# Public Surface Layer
# =================================

$publicPath = Join-Path $script:ShellRoot "Public"

if (Test-Path $publicPath) {

    $publicFiles = @(Get-ChildItem -Path $publicPath -Filter *.ps1 -File | Sort-Object Name)

    foreach ($file in $publicFiles) {

        Write-Verbose "[PulseAI.Shell] Loading public: $($file.Name)"
        . $file.FullName

    }

}

# =================================
# Command Plugin Loader (Safe)
# =================================

$commandsPath = Join-Path $script:ShellRoot "Commands"

if (Test-Path $commandsPath) {

    Write-Verbose "[PulseAI.Shell] Discovering command plugins..."

    $commandDirs = @(Get-ChildItem $commandsPath -Directory | Sort-Object Name)

    foreach ($dir in $commandDirs) {

        Write-Verbose "[PulseAI.Shell] Loading command module: $($dir.Name)"

        $commandFiles = @(Get-ChildItem $dir.FullName -Recurse -Filter *.ps1 -File | Sort-Object FullName)

        if (-not $commandFiles) {

            Write-Warning "[PulseAI.Shell] Command folder empty: $($dir.Name)"
            continue

        }

        foreach ($file in $commandFiles) {

            Write-Verbose "[PulseAI.Shell] Loading command file: $($file.Name)"
            . $file.FullName

        }

    }

}

# ---------------------------------
# Interactive helpers (console only)
# ---------------------------------

if ($Host.Name -eq "ConsoleHost") {

    $interactivePath = Join-Path $script:ShellRoot "Interactive"

    if (Test-Path $interactivePath) {

        $interactiveFiles = @(Get-ChildItem $interactivePath -Filter *.ps1 -File | Sort-Object Name)

        foreach ($file in $interactiveFiles) {

            Write-Verbose "[PulseAI.Shell] Loading interactive: $($file.Name)"
            . $file.FullName

        }

    }

}

# =================================
# Register CLI Completion
# =================================

if (Get-Command Register-PulseArgumentCompleter -ErrorAction SilentlyContinue) {

    Write-Verbose "[PulseAI.Shell] Registering CLI argument completer"
    Register-PulseArgumentCompleter

}

# =================================
# CLI Core Validation
# =================================

if (-not (Get-Command pulse -ErrorAction SilentlyContinue)) {
    throw "[PulseAI.Shell] CLI entry command 'pulse' failed to load."
}

if (-not (Get-Command Invoke-PulseCommandRouter -ErrorAction SilentlyContinue)) {
    throw "[PulseAI.Shell] Command router failed to load."
}

if (-not (Get-Command Get-PulseCommandCapabilities -ErrorAction SilentlyContinue)) {
    throw "[PulseAI.Shell] Command capability registry failed to load."
}

# =================================
# Ergonomic Wrapper Surface
# =================================

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

# =================================
# Explicit Public Surface
# =================================

Export-ModuleMember -Function `
    Initialize-PulseAIShell,
    Set-PulseDevTheme,
    Set-PulseCasualTheme,
    Set-PulseRepo,
    Use-DevTheme,
    Use-CasualTheme,
    Get-PulsePromptIndicator,
    Update-PulseSignalEnvironment,
    Get-PulseCommandCapabilities,
    pulse

# =================================
# Automatic Shell Bootstrap
# =================================

try {

    if (Get-Command Initialize-PulseAIShell -ErrorAction SilentlyContinue) {

        Initialize-PulseAIShell

    }

}
catch {

    Write-Verbose "[PulseAI.Shell] Automatic initialization failed: $_"

}