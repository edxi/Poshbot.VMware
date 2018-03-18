function Set-VIServerConfigStore {
    <#
    .SYNOPSIS
        Set path to Store VIServer list, write it into poshbot configuration file.
    .EXAMPLE
        Set-VIServerConfigStore -PoshBotConfigFile "c:\poshbot\config.psd1" -Store "c:\poshbot"
    #>
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$PoshBotConfigFile = 'c:\poshbot\config.psd1',
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Store = 'c:\poshbot'
    )

    if (!(Test-Path -LiteralPath "$PoshBotConfigFile")) {
        Write-Error "PoshBot config file $PoshBotConfigFile not exist."
        return
    }
    $pbc = Get-PoshBotConfiguration $PoshBotConfigFile
    $pbc.PluginConfiguration.'Poshbot.VMware' = @{
        'VIServerConfigStore' = $Store
    }
    Save-PoshBotConfiguration $pbc -Path $PoshBotConfigFile -Force

    Write-Verbose "Stored plugin setting VIServerConfigStore = $Store into poshbot configuration file $PoshBotConfigFile"
}
