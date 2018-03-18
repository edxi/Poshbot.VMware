function Get-VIServerConfig {
    <#
    .SYNOPSIS
        Get VIServer and credential list.
    .EXAMPLE
        Get-VIServerConfig -PoshBotConfigFile 'c:\poshbot\config.psd1'
        Get-VIServerConfig c:\poshbot -IncludeDisabled
    #>
    [CmdletBinding(DefaultParameterSetName = 'VIServerConfigStore')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'PoshBotConfigFile', Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$PoshBotConfigFile,
        [Parameter(Mandatory = $true, ParameterSetName = 'VIServerConfigStore', Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$VIServerConfigStore,
        [switch]$IncludeDisabled = $false
    )

    if ($PSCmdlet.ParameterSetName -eq 'PoshBotConfigFile') {
        if (!(Test-Path -LiteralPath "$PoshBotConfigFile")) {
            Write-Error "PoshBot config file $PoshBotConfigFile not exist."
            return
        }
        $VIServerConfigStore = (Get-PoshBotConfiguration $PoshBotConfigFile).PluginConfiguration.'Poshbot.VMware'.VIServerConfigStore
    }

    $r = New-Object System.Collections.ArrayList

    if (!(Test-Path "$VIServerConfigStore")) {
        mkdir "$VIServerConfigStore" | Out-Null
    }
    $id = 1
    (Get-ChildItem "$VIServerConfigStore\*.clixml").Name | ForEach-Object {
        $obj = "" | Select-Object Id, VIServer, CredentialUser, Path
        $filename = [io.path]::GetFileNameWithoutExtension("$_").split("-")
        $obj.Id = $id++
        $obj.VIServer = $filename[0]
        $obj.CredentialUser = $filename[1]
        $obj.Path = $VIServerConfigStore
        [void]($r.Add($obj))
    }
    if ($IncludeDisabled) {
        if (!(Test-Path "$VIServerConfigStore\DisabledVIServer")) {
            mkdir "$VIServerConfigStore\DisabledVIServer" | Out-Null
        }
        (Get-ChildItem "$VIServerConfigStore\DisabledVIServer\*.clixml").Name | ForEach-Object {
            $obj = "" | Select-Object Id, VIServer, CredentialUser, Path
            $filename = [io.path]::GetFileNameWithoutExtension("$_").split("-")
            $obj.Id = $id++
            $obj.VIServer = $filename[0]
            $obj.CredentialUser = $filename[1]
            $obj.Path = "$VIServerConfigStore\DisabledVIServer"
            [void]($r.Add($obj))
        }
    }

    $r
}
