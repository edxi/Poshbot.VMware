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
        [PoshBot.FromConfig('VIServerConfig')]
        [parameter(Mandatory)]
        [string]$VIServerConfig,
        [parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )

    $cmdlets = $Arguments -join ';'
	$r = &([Scriptblock]::Create($cmdlets))
	Write-Output $r
}
