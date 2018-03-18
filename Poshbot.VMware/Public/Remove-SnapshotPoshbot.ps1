function Remove-SnapshotPoshbot {
    <#
    .SYNOPSIS
        PoshBot command for remove vmware snapshot. (Only support remove all snapshot)
    .EXAMPLE
        !removesnapshot vm1 'vm2' 'vm 3'
    #>
    [PoshBot.BotCommand(CommandName = 'removesnapshot', Permissions = 'snapshot')]
    [cmdletbinding()]
    param(
        [PoshBot.FromConfig('VIServerConfigStore')]
        [parameter(Mandatory = $true)]
		[string]$VIServerConfigStore,
        [parameter(Position=0, Mandatory = $false, ValueFromRemainingArguments = $true)]
        [string[]]$vm
    )

    Get-VIServerConfig $VIServerConfigStore | ForEach-Object {
        Connect-VIServer $_.VIServer -User $_.CredentialUser -Password $(LoadAndUnencryptKey "$($_.Path)\$($_.VIServer)-$($_.CredentialUser).clixml") | Out-Null
    }

    Get-VM $vm -ErrorAction SilentlyContinue| Get-Snapshot | Remove-Snapshot -Confirm:$false | Out-Null

    New-PoshBotTextResponse -Text "Snapshot Removed"

    Disconnect-VIServer * -Confirm:$false | Out-Null
}
