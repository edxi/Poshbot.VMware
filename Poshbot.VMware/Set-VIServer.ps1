$Private = Get-ChildItem $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue
# Dot source the files
Foreach ($import in @($Private)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error "Failed to import function $($import.fullname): $_"
    }
}


Clear-Host
@"
-----------------------------
Welcome to use Poshbot.VMware
-----------------------------

This plugin connects VI servers by read a store.
The store is a path which includes VI servers with Credentials.
The store path setting will write into PoshBot config file.

So, First, we need to set the store path.

"@

$PoshBotConfigFile = 'c:\poshbot\config.psd1'
$Store = 'c:\poshbot'

$defult = $PoshBotConfigFile
$PoshBotConfigFile = Read-Host -Prompt "Input your poshbot configuration file:($PoshBotConfigFile)"
if ($PoshBotConfigFile -eq $null -or $PoshBotConfigFile -eq '') {
    $PoshBotConfigFile = $defult
}
$defult = $Store
$Store = Read-Host -Prompt "Input your VI Server list store path:($Store)"
if ($Store -eq $null -or $Store -eq '') {
    $Store = $defult
}

Set-VIServerConfigStore -PoshBotConfigFile $PoshBotConfigFile -Store $Store -Verbose

Pause

$menu = @"
-------------------------------------
Now, you could setup VI server store.
-------------------------------------

1. List VI Servers
2. Store new VI Server
3. Remove VI Server
4. Enable VI Server
5. Disable VI Server
0. Exit

"@
Clear-Host
$menu
while (($choice = Read-Host -Prompt "Input 0-6") -ne '0') {
    switch ($choice) {
        '1' {
            Clear-Host
            Get-VIServerConfig $Store -IncludeDisabled | Format-Table -AutoSize
            Pause
            break;
        }
        '2' {
            New-VIServerConfig $Store -Verbose
            Pause
            break;
        }
        '3' {
            Clear-Host
            Get-VIServerConfig $Store -IncludeDisabled | Format-Table -AutoSize
            $Id = Read-Host -Prompt "Input Id"
            Get-VIServerConfig c:\poshbot -IncludeDisabled |
                Where-Object {$_.Id -eq $Id } |
                Remove-VIServerConfig -Verbose
            Pause
            break;
        }
        '4' {
            Clear-Host
            Get-VIServerConfig $Store -IncludeDisabled | Format-Table -AutoSize
            $Id = Read-Host -Prompt "Input Id"
            Get-VIServerConfig c:\poshbot -IncludeDisabled |
                Where-Object {$_.Id -eq $Id} |
                Enable-VIServerConfig -Verbose
            Pause
            break;
        }
        '5' {
            Clear-Host
            Get-VIServerConfig $Store | Format-Table -AutoSize
            $Id = Read-Host -Prompt "Input Id"
            Get-VIServerConfig c:\poshbot -IncludeDisabled |
                Where-Object {$_.Id -eq $Id} |
                Disable-VIServerConfig -Verbose
            Pause
            break;
        }
    }
    Clear-Host
    $menu
}
