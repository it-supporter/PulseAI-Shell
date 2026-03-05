Set-StrictMode -Version Latest

function pulse {

    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$CommandArgs
    )

    Write-Verbose "[PulseAI.Shell] CLI entry invoked"

    # ------------------------------------------------
    # StrictMode-safe normalization
    # ------------------------------------------------

    if ($null -eq $CommandArgs) {
        $CommandArgs = @()
    }

    # ------------------------------------------------
    # Ensure router exists
    # ------------------------------------------------

    $router = Get-Command -Name Invoke-PulseCommandRouter -ErrorAction SilentlyContinue

    if ($null -eq $router) {
        throw "[PulseAI.Shell] Command router not loaded."
    }

    # ------------------------------------------------
    # Resolve theme colors safely
    # ------------------------------------------------

    $accentColor  = "Cyan"
    $warningColor = "Yellow"

    if ($Global:PulseTheme) {

        if ($Global:PulseTheme.Accent) {
            $accentColor = $Global:PulseTheme.Accent
        }

        if ($Global:PulseTheme.Warning) {
            $warningColor = $Global:PulseTheme.Warning
        }

    }

    # ------------------------------------------------
    # No arguments → command discovery
    # ------------------------------------------------

    if ($CommandArgs.Count -eq 0) {

        $capabilities = Get-PulseCommandCapabilities

        Write-Host ""

        # ---------------------------------
        # Determine divider width
        # ---------------------------------

        $dividerWidth = 30

        try {

            if ($Host -and $Host.UI -and $Host.UI.RawUI) {

                $width = $Host.UI.RawUI.WindowSize.Width

                if ($width -gt 20) {

                    $dividerWidth = [math]::Min(
                        [math]::Floor($width * 0.5),
                        80
                    )

                }

            }

        }
        catch {}

        $divider = "─" * $dividerWidth

        Write-Host "PulseAI Commands" -ForegroundColor $accentColor
        Write-Host $divider -ForegroundColor $accentColor

        if (-not $capabilities -or $capabilities.Count -eq 0) {

            Write-Host ""
            Write-Host "No commands registered." -ForegroundColor $warningColor
            Write-Host ""
            return
        }

        Write-Host ""

        # ---------------------------------
        # Determine column width
        # ---------------------------------

        $commandNames = $capabilities.Keys | Sort-Object

        $maxWidth = ($commandNames |
                    Measure-Object -Maximum Length).Maximum

        if ($null -eq $maxWidth) {
            $maxWidth = 10
        }

        $maxWidth += 2

        # ---------------------------------
        # Render command table
        # ---------------------------------

        foreach ($name in $commandNames) {

            $cap = $capabilities[$name]

            $description = ""

            if ($cap -and $cap.Description) {
                $description = $cap.Description
            }

            $paddedCommand = "{0,-$maxWidth}" -f $name

            Write-Host $paddedCommand -ForegroundColor $accentColor -NoNewline
            Write-Host $description
        }

        Write-Host ""
        return
    }

    # ------------------------------------------------
    # Forward to router
    # ------------------------------------------------

    try {

        & $router -CommandArgs $CommandArgs

    }
    catch {

        $msg = $_.Exception.Message

        if (-not $msg) {
            $msg = "Unknown CLI error"
        }

        throw "[PulseAI.Shell] CLI execution failed: $msg"
    }

}