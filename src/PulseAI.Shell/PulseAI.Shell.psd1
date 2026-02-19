@{

RootModule        = 'PulseAI.Shell.psm1'
ModuleVersion     = '0.1.0'
CompatiblePSEditions = @('Core')

GUID              = '6b6d3b45-3c7e-4c7b-8f5d-1c6c9e0d7a11'

Author            = 'Henrik Burchardt'
CompanyName       = 'Reservehjernen'
Copyright         = '(c) Henrik Burchardt. All rights reserved.'
Description       = 'PulseAI Shell UX Module'
PowerShellVersion = '7.0'

FunctionsToExport = @(
    'Initialize-PulseAIShell',
    'Set-PulseDevTheme',
    'Set-PulseCasualTheme',
    'Set-PulseRepo'
)

CmdletsToExport   = @()
VariablesToExport = @()
AliasesToExport   = @()

PrivateData = @{
    PSData = @{
        Tags = @('PulseAI','Shell','UX')
    }
}

}
