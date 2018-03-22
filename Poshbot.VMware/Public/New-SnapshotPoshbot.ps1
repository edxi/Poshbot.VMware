function New-SnapshotPoshbot {
    <#
    .SYNOPSIS
        PoshBot command for create vmware snapshot
    .EXAMPLE
        !newsnapshot vm1 'vm2' 'vm 3'
    #>
    [PoshBot.BotCommand(CommandName = 'newsnapshot', Permissions = 'snapshot')]
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

    Get-VM $vm -ErrorAction SilentlyContinue | New-Snapshot -name "PoshBot snapshot $(Get-Date -Format u)" | Out-Null

    $r = Get-VM $vm -ErrorAction SilentlyContinue | Get-Snapshot
    $r| ForEach-Object {
        New-PoshBotCardResponse -Title "VM $($_.vm) snapshot:" -Text ($_ | Format-List -Property vm, name | Out-String)
    }

    Disconnect-VIServer * -Confirm:$false | Out-Null
}
