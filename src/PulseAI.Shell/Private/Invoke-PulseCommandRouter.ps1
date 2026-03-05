Set-StrictMode -Version Latest

<#
.SYNOPSIS
Routes PulseAI CLI commands to handlers.

.DESCRIPTION
Receives CLI arguments and dispatches to the appropriate
PulseAI command handler with support for git-style prefix
resolution.
#>

function Invoke-PulseCommandRouter {

    [CmdletBinding()]
    param(
        [string[]]$CommandArgs
    )

    Write-Verbose "[PulseAI.Shell] Router invoked"

    # ------------------------------------------------
    # StrictMode-safe normalization
    # ------------------------------------------------

    if ($null -eq $CommandArgs) {
        $CommandArgs = @()
    }

    # ------------------------------------------------
    # Load command registry
    # ------------------------------------------------

    $capabilities = Get-PulseCommandCapabilities

    if (-not $capabilities -or $capabilities.Count -eq 0) {

        Write-Host ""
        Write-Host "PulseAI CLI: No commands registered." -ForegroundColor Yellow
        Write-Host ""
        return
    }

    # ------------------------------------------------
    # Ensure prefix cache exists
    # ------------------------------------------------

    if (-not (Get-Variable PulseCommandPrefixCache -Scope Script -ErrorAction SilentlyContinue)) {
        $script:PulseCommandPrefixCache = @{}
    }

    # ------------------------------------------------
    # Build prefix cache
    # ------------------------------------------------

    if ($script:PulseCommandPrefixCache.Count -ne $capabilities.Count) {

        $script:PulseCommandPrefixCache.Clear()

        foreach ($entry in ($capabilities.GetEnumerator() | Sort-Object Key)) {

            $keyLower = $entry.Key.ToLowerInvariant()

            for ($i = 1; $i -le $keyLower.Length; $i++) {

                $prefix = $keyLower.Substring(0, $i)

                if (-not $script:PulseCommandPrefixCache.ContainsKey($prefix)) {
                    $script:PulseCommandPrefixCache[$prefix] = @()
                }

                if ($script:PulseCommandPrefixCache[$prefix] -notcontains $keyLower) {
                    $script:PulseCommandPrefixCache[$prefix] += $keyLower
                }

            }
        }
    }

    # ------------------------------------------------
    # No command → discovery
    # ------------------------------------------------

    if ($CommandArgs.Count -eq 0) {

        Show-PulseCommandDiscovery
        return
    }

    $commandInput = $CommandArgs[0].ToLowerInvariant()

    $remaining = @()

    if ($CommandArgs.Count -gt 1) {
        $remaining = $CommandArgs[1..($CommandArgs.Count - 1)]
    }

    # ------------------------------------------------
    # Resolve command
    # ------------------------------------------------

    $resolved = $null

    if ($capabilities.ContainsKey($commandInput)) {

        $resolved = $commandInput

    }
    elseif ($script:PulseCommandPrefixCache.ContainsKey($commandInput)) {

        $matches = $script:PulseCommandPrefixCache[$commandInput]

        if ($matches.Count -eq 1) {

            $resolved = $matches[0]

        }
        elseif ($matches.Count -gt 1) {

            Write-Host ""
            Write-Host "Ambiguous command '$commandInput'" -ForegroundColor Yellow
            Write-Host ""

            foreach ($m in ($matches | Sort-Object)) {
                Write-Host "  $m"
            }

            Write-Host ""
            return
        }
    }

    if ($null -eq $resolved) {

        Write-Host ""
        Write-Host "Unknown command: $commandInput" -ForegroundColor Red
        Write-Host ""

        Show-PulseCommandDiscovery
        return
    }

    # ------------------------------------------------
    # Resolve handler
    # ------------------------------------------------

    $cap = $capabilities[$resolved]

    if (-not $cap -or -not $cap.Handler) {
        throw "[PulseAI.Shell] Command '$resolved' has no valid handler."
    }

    $handler = $cap.Handler

    # ------------------------------------------------
    # Execute handler
    # ------------------------------------------------

    if ($handler -is [ScriptBlock]) {

        & $handler -CommandArgs $remaining
        return
    }

    if ($handler -is [string]) {

        $cmdInfo = Get-Command -Name $handler -CommandType Function -ErrorAction SilentlyContinue

        if ($null -eq $cmdInfo) {
            throw "[PulseAI.Shell] Handler '$handler' not found."
        }

        & $cmdInfo -CommandArgs $remaining
        return
    }

    throw "[PulseAI.Shell] Invalid handler type for command '$resolved'."
}