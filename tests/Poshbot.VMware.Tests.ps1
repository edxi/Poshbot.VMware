$Verbose = @{}
if ($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master") {
    $Verbose.add("Verbose", $True)
}

$ModuleName = 'Poshbot.VMware'
Import-Module "$PSScriptRoot\..\$ModuleName\$ModuleName.psd1"

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path "$PSScriptRoot\..\$ModuleName\$ModuleName.psd1"
        $? | Should Be $true
    }
}
