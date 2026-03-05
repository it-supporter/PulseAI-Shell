Set-StrictMode -Version Latest

function Register-PulseArgumentCompleter {

    [CmdletBinding()]
    param()

    Register-ArgumentCompleter `
        -CommandName pulse `
        -ScriptBlock {

            param(
                $commandName,
                $parameterName,
                $wordToComplete,
                $commandAst,
                $fakeBoundParameters
            )

            # ---------------------------------
            # Extract tokens (StrictMode safe)
            # ---------------------------------

            $tokens = @(
                $commandAst.CommandElements |
                Select-Object -Skip 1 |
                ForEach-Object { $_.Extent.Text }
            )

            $current = ($wordToComplete ?? "").ToLowerInvariant()

            # ---------------------------------
            # ROOT COMMAND COMPLETION
            # ---------------------------------

            if (-not $tokens -or $tokens.Count -le 1) {

                $capabilities = Get-PulseCommandCapabilities
                if (-not $capabilities) { return }

                foreach ($cmd in ($capabilities.Keys | Sort-Object)) {

                    if ($cmd.ToLowerInvariant() -like "$current*") {

                        [System.Management.Automation.CompletionResult]::new(
                            $cmd,
                            $cmd,
                            'ParameterValue',
                            $capabilities[$cmd].Description
                        )

                    }

                }

                return
            }

            # ---------------------------------
            # SUBCOMMAND COMPLETION
            # ---------------------------------

            $root = $tokens[0].ToLowerInvariant()

            $shell = Get-Module PulseAI.Shell -ErrorAction Ignore
            if (-not $shell) { return }

            $commandsPath = Join-Path $shell.ModuleBase "Commands"
            $rootPath = Join-Path $commandsPath $root

            if (Test-Path $rootPath) {

                foreach ($file in Get-ChildItem $rootPath -Recurse -Filter "Invoke-*.ps1" -File | Sort-Object Name) {

                    $name = $file.BaseName

                    if ($name -match "^Invoke-Pulse($root)(.+)$") {

                        $sub = $Matches[2].ToLowerInvariant()

                        if ($sub -eq "command") { continue }

                        if ($sub -like "$current*") {

                            [System.Management.Automation.CompletionResult]::new(
                                $sub,
                                $sub,
                                'ParameterValue',
                                "$root $sub"
                            )

                        }

                    }

                }

                return
            }

            # ---------------------------------
            # STATIC FALLBACK
            # ---------------------------------

            switch ($root) {

                "repo"   { $subs = "list","status","dirty","doctor" }
                "doctor" { $subs = "architecture","modules","repos","workspace" }
                "sync"   { $subs = "repos" }

                default { return }

            }

            foreach ($s in $subs) {

                if ($s -like "$current*") {

                    [System.Management.Automation.CompletionResult]::new(
                        $s,
                        $s,
                        'ParameterValue',
                        "$root $s"
                    )

                }

            }

        }

}