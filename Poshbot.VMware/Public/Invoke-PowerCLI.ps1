function Invoke-PowerCLI {
    <#
    .SYNOPSIS
        Pass cmdlet to PowerCLI
    .EXAMPLE
        !powercli 'Get-VM'
    #>
    [PoshBot.BotCommand(CommandName = 'powercli', Permissions = 'vmwarepluginadmin')]
    [cmdletbinding()]
    param(
        [PoshBot.FromConfig('VIServerConfigStore')]
        [parameter(Mandatory = $true)]
		[string]$VIServerConfigStore,
        [parameter(Position=0, Mandatory = $false, ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )

    Get-VIServerConfig $VIServerConfigStore | ForEach-Object {
        Connect-VIServer $_.VIServer -User $_.CredentialUser -Password $(LoadAndUnencryptKey "$($_.Path)\$($_.VIServer)-$($_.CredentialUser).clixml")
    }

    $cmdlets = $Arguments -join ';'
    $r = &([Scriptblock]::Create($cmdlets))
    Write-Output $r

    Disconnect-VIServer * -Confirm:$false
}
