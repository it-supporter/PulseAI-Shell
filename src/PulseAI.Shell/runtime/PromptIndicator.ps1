# =================================
# PulseAI Prompt Indicator
# =================================

Set-StrictMode -Version Latest

# ---------------------------------
# Resolve Worst Pulse Severity
# ---------------------------------

function Get-PulseWorstSeverity {
<#
.SYNOPSIS
Returns the highest PulseSeverity currently active.
.PULSE Tier Internal
#>

    if (-not (Get-Command Get-PulseSignals -ErrorAction SilentlyContinue)) {
        return $null
    }

    $signals = Get-PulseSignals
    if (-not $signals) {
        return $null
    }

    # Severity ordering contract (highest wins)
    $order = @{
        Critical      = 4
        Error         = 3
        Warning       = 2
        Advisory      = 1
        Informational = 0
    }

    $worst = $signals |
        Sort-Object { $order[$_.Severity.ToString()] } -Descending |
        Select-Object -First 1

    return $worst.Severity
}

# ---------------------------------
# Render Prompt Indicator
# ---------------------------------

function Get-PulsePromptIndicator {
<#
.SYNOPSIS
Return a compact prompt indicator based on active Pulse signals.
.PULSE Tier Common
#>

    [CmdletBinding()]
    param()

    Set-StrictMode -Version Latest

    # ---------------------------------
    # Resolve severity via canonical helper
    # ---------------------------------

    $severity = Get-PulseWorstSeverity
    if (-not $severity) {
        return ''
    }

    # ---------------------------------
    # Nerd Font detection (lightweight)
    # ---------------------------------

    $useIcons = $true
    try {
        if ($env:TERM_PROGRAM -eq 'vscode') {
            $useIcons = $true
        }
    }
    catch {
        $useIcons = $false
    }

    # ---------------------------------
    # Map severity → symbol
    # ---------------------------------

    switch ($severity.ToString()) {

        'Critical' {
            return $useIcons ? '⛔ ' : '!! '
        }

        'Error' {
            return $useIcons ? ' ' : '!! '
        }

        'Warning' {
            return $useIcons ? ' ' : '! '
        }

        'Advisory' {
            return $useIcons ? '⚠ ' : '~ '
        }

        'Informational' {
            return $useIcons ? 'ℹ ' : 'i '
        }

        default {
            return ''
        }
    }
}

# ---------------------------------
# Project Pulse signals to environment (oh-my-posh bridge)
# ---------------------------------
function Update-PulseSignalEnvironment {
<#
.SYNOPSIS
Project active Pulse signals into environment variables for prompt rendering.
.PULSE Tier Internal
#>

    Set-StrictMode -Version Latest

    # Defaults (clean state)
    $env:PULSE_SIGNAL_ICON     = ''
    $env:PULSE_SIGNAL_SEVERITY = ''
    $env:PULSE_SIGNAL_COUNT    = '0'

    if (-not (Get-Command Get-PulseSignals -ErrorAction SilentlyContinue)) {
        return
    }

    $signals = Get-PulseSignals

    if (-not $signals -or $signals.Count -eq 0) {
        return
    }

    # Severity ranking contract
    $rank = @{
        Critical      = 4
        Warning       = 3
        Advisory      = 2
        Informational = 1
    }

    $top = $signals |
        Sort-Object { $rank[$_.Severity.ToString()] } -Descending |
        Select-Object -First 1

    # Map severity → icon
    $icon = switch ($top.Severity) {
        'Critical'      { '⛔' }
        'Warning'       { '' }
        'Advisory'      { '⚠' }
        'Informational' { 'ℹ' }
        default         { '' }
    }

    $env:PULSE_SIGNAL_ICON     = $icon
    $env:PULSE_SIGNAL_SEVERITY = $top.Severity
    $env:PULSE_SIGNAL_COUNT    = [string]$signals.Count
}