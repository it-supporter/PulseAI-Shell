function Set-PulseRepo {

    param(
        [Parameter(Mandatory)]
        [ValidateSet("env","shell","rip","core","spark")]
        [string]$Name
    )

    $DevRoot = Join-Path $HOME "Dev"

    $map = @{
        env   = "PulseAI-Environment"
        shell = "PulseAI-Shell"
        rip   = "RipClip"
        core  = "PulseAI-Core"
        spark = "PulseAI-Spark"
    }

    $target = Join-Path $DevRoot $map[$Name]

    if (Test-Path $target) {
        Set-Location $target
    }
    else {
        Write-Warning "Repository '$Name' not found."
    }
}
