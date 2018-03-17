function New-SnapshotPoshbot {
    <#
    .SYNOPSIS
        PoshBot command for create vmware snapshot
    .EXAMPLE
        !newsnapshot 'vm1' 'vm2'
    #>
    [PoshBot.BotCommand(CommandName = 'newsnapshot', Permissions = 'snapshot')]
    [cmdletbinding()]
    param(
        [PoshBot.FromConfig('VIServerConfig')]
        [parameter(Mandatory)]
        [string]$VIServerConfig,
		[parameter(Mandatory)]
        [parameter(ValueFromRemainingArguments = $true)]
        [string[]]$vm
    )

    Get-VIServerConfig $VIServerConfig | ForEach-Object{
        Connect-VIServer $_.VIServer -User $_.CredentialUser -Password $(LoadAndUnencryptKey "$($config.Path)\$($config.VIServer)-$($config.CredentialUser).clixml")
    }



    Disconnect-VIServer * -Confirm:$false
}

function Get-SnapshotPoshbot {
    <#
    .SYNOPSIS
        PoshBot command for list vmware snapshot
    .EXAMPLE
        !getsnapshot 'vm1' 'vm2'
    #>
    [PoshBot.BotCommand(CommandName = 'getsnapshot', Permissions = 'snapshot')]
    [cmdletbinding()]
    param(
        [PoshBot.FromConfig('VIServerConfig')]
        [parameter(Mandatory)]
        [string]$VIServerConfig,
		[parameter(Mandatory)]
        [parameter(ValueFromRemainingArguments = $true)]
        [string[]]$vm
    )

    Get-VIServerConfig $VIServerConfig | ForEach-Object{
        Connect-VIServer $_.VIServer -User $_.CredentialUser -Password $(LoadAndUnencryptKey "$($config.Path)\$($config.VIServer)-$($config.CredentialUser).clixml")
    }

    Get-VM $vm | Get-Snapshot

    Disconnect-VIServer * -Confirm:$false
}

function Remove-SnapshotPoshbot {
    <#
    .SYNOPSIS
        PoshBot command for remove vmware snapshot
    .EXAMPLE
        !removesnapshot 'vm1' 'vm2'
    #>
    [PoshBot.BotCommand(CommandName = 'removesnapshot', Permissions = 'snapshot')]
    [cmdletbinding()]
    param(
        [PoshBot.FromConfig('VIServerConfig')]
        [parameter(Mandatory)]
        [string]$VIServerConfig,
		[parameter(Mandatory)]
        [parameter(ValueFromRemainingArguments = $true)]
        [string[]]$vm
    )

    Get-VIServerConfig $VIServerConfig | ForEach-Object{
        Connect-VIServer $_.VIServer -User $_.CredentialUser -Password $(LoadAndUnencryptKey "$($config.Path)\$($config.VIServer)-$($config.CredentialUser).clixml")
    }

    Get-VM $vm | Get-Snapshot | Remove-Snapshot -Confirm:$false

    Disconnect-VIServer * -Confirm:$false
}
