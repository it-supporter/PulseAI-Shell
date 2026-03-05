Set-StrictMode -Version Latest

function Show-PulseDoctorHelp {

    # ---------------------------------
    # Theme resolution (StrictMode safe)
    # ---------------------------------

    $headerColor  = "Cyan"
    $commandColor = "Green"

    if ($Global:PulseTheme) {

        if ($Global:PulseTheme.ContainsKey("Accent")) {
            $headerColor = $Global:PulseTheme.Accent
        }

        if ($Global:PulseTheme.ContainsKey("Success")) {
            $commandColor = $Global:PulseTheme.Success
        }

    }

    # ---------------------------------
    # Command definitions
    # ---------------------------------

    $commands = @(
        @{ Name = "architecture"; Description = "Validate module architecture" }
        @{ Name = "workspace";    Description = "Validate workspace state" }
        @{ Name = "repos";        Description = "Validate repository health" }
        @{ Name = "modules";      Description = "Validate PulseAI module state" }
    )

    # ---------------------------------
    # Determine column width
    # ---------------------------------

    $max = 10

    if ($commands) {

        $maxMeasured = ($commands |
                        ForEach-Object { $_.Name } |
                        Measure-Object -Property Length -Maximum).Maximum

        if ($maxMeasured) {
            $max = $maxMeasured
        }

    }

    # ---------------------------------
    # Determine divider width
    # ---------------------------------

    $dividerLength = 40

    try {

        if ($Host -and $Host.UI -and $Host.UI.RawUI) {

            $width = $Host.UI.RawUI.WindowSize.Width

            if ($width -gt 20) {

                $dividerLength = [math]::Min(
                    60,
                    [math]::Max(
                        30,
                        [math]::Floor($width * 0.5)
                    )
                )

            }

        }

    }
    catch {}

    $divider = "─" * $dividerLength

    # ---------------------------------
    # Render help
    # ---------------------------------

    Write-Host ""
    Write-Host "PulseAI Doctor Commands" -ForegroundColor $headerColor
    Write-Host $divider -ForegroundColor $headerColor
    Write-Host ""

    foreach ($item in $commands) {

        $name = $item.Name.PadRight($max + 2)

        Write-Host "doctor " -NoNewline
        Write-Host $name -ForegroundColor $commandColor -NoNewline
        Write-Host $item.Description

    }

    Write-Host ""

}