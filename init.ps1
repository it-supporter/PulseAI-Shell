# PulseAI Shell Initialization

$PulseAITheme = "$HOME\Dev\PulseAI-Shell\themes\pulseai-shell.omp.json"

if (Test-Path $PulseAITheme) {
    oh-my-posh init pwsh --config $PulseAITheme | Invoke-Expression
}
