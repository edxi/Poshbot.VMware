function New-VIServerConfig {
    <#
    .SYNOPSIS
        Store new VIServer and the encrypted credential in a file.
    .EXAMPLE
        New-VIServerConfig c:\poshbot 'vcenter.mylab.com'
    #>
    [CmdletBinding(DefaultParameterSetName = 'VIServerConfigStore')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'PoshBotConfigFile', Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$PoshBotConfigFile,
        [Parameter(Mandatory = $true, ParameterSetName = 'VIServerConfigStore', Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$VIServerConfigStore,
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$VIServer
    )

    if ($PSCmdlet.ParameterSetName -eq 'PoshBotConfigFile') {
        if (!(Test-Path -LiteralPath "$PoshBotConfigFile")) {
            Write-Error "PoshBot config file $PoshBotConfigFile not exist."
            return
        }
        $VIServerConfigStore = (Get-PoshBotConfiguration $PoshBotConfigFile).PluginConfiguration.'Poshbot.VMware'.VIServerConfigStore
    }
    if (!(Test-Path "$VIServerConfigStore")) {
        mkdir "$VIServerConfigStore" | Out-Null
    }
    $cred = Get-Credential -Message "Input $VIServer credential"
    $EncryptedKeyPath = "$($VIServerConfigStore)\$VIServer-$($cred.UserName).clixml"
    EncryptAndSaveKey -KeySecureString $cred.Password -Path $EncryptedKeyPath

    Write-Verbose "Stored credential of VIServer $VIServer's user $($cred.UserName) in $EncryptedKeyPath"
}
