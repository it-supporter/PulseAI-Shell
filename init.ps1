# ---------------------------------
# PulseAI Shell Initialization
# ---------------------------------

# Resolve repo root dynamically
$ShellRoot = $PSScriptRoot

# Paths
$ThemePath  = Join-Path $ShellRoot "themes\pulseai-shell.omp.json"
$ConfigPath = Join-Path $ShellRoot "config\pulseai-shell.config.json"

# Load Shell Config (if present)
if (Test-Path $ConfigPath) {
    try {
        $ShellConfig = Get-Content $ConfigPath -Raw | ConvertFrom-Json
    }
    catch {
        Write-Warning "PulseAI-Shell config.json is invalid."
    }
}

# Verify Oh My Posh availability
$OMP = Get-Command oh-my-posh -ErrorAction SilentlyContinue

if (-not $OMP) {
    Write-Warning "Oh My Posh not found. PulseAI theme not loaded."
    return
}

# Load Theme
if (Test-Path $ThemePath) {
    oh-my-posh init pwsh --config $ThemePath | Invoke-Expression
}
else {
    Write-Warning "PulseAI theme file missing: $ThemePath"
}
