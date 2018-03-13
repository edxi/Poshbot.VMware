<#
.SYNOPSIS
    Pass cmdlet to PowerCLI
.EXAMPLE
    !powercli 'Get-VM'
#>
function Invoke-PowerCLI {

    [PoshBot.BotCommand(CommandName = 'powercli')]
    [cmdletbinding()]
    param(
        [parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )

    $cmdlets = $Arguments -join ';'
	$r = &([Scriptblock]::Create($cmdlets))
	Write-Output $r
}
