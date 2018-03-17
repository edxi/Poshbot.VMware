function EncryptAndSaveKey {
    param(
        [Parameter(Mandatory, ParameterSetName='SecureString')]
        [ValidateNotNull()]
        [SecureString]
        $KeySecureString,

        [Parameter(Mandatory, ParameterSetName='PlainText')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Key,

        [Parameter(Mandatory)]
        $Path
    )

    if ($PSCmdlet.ParameterSetName -eq 'PlainText') {
        $KeySecureString = ConvertTo-SecureString -String $Key -AsPlainText -Force
    }

    $parentDir = Split-Path $Path -Parent
    if (!(Test-Path -LiteralPath $parentDir)) {
        $null = New-Item -Path $parentDir -ItemType Directory
    }
    elseif (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path
    }

    $KeySecureString | ConvertFrom-SecureString | Export-Clixml $Path
    Write-Verbose "The Key has been encrypted and saved to $Path"
}

function LoadAndUnencryptKey {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path
    )

    $storedKey = Import-Clixml $Path | ConvertTo-SecureString
    $cred = New-Object -TypeName PSCredential -ArgumentList 'jpgr',$storedKey
    # $cred.GetNetworkCredential().Password
    # Write-Verbose "The Key has been loaded and unencrypted from $Path"
    $cred.GetNetworkCredential().Password
}

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
    $pbc.PluginConfiguration.VMware=@{
        VIServerConfigStore = $Store
    }
    Save-PoshBotConfiguration $pbc -Path $PoshBotConfigFile -Force

    Write-Verbose "Stored plugin setting VIServerConfigStore = $Store into poshbot configuration file $PoshBotConfigFile"
}
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
        $VIServerConfigStore = (Get-PoshBotConfiguration $PoshBotConfigFile).PluginConfiguration.VMware.VIServerConfigStore
    }
    if (!(Test-Path "$VIServerConfigStore")) {
        mkdir "$VIServerConfigStore" | Out-Null
    }
    $cred = Get-Credential -Message "Input $VIServer credential"
    $EncryptedKeyPath = "$($VIServerConfigStore)\$VIServer-$($cred.UserName).clixml"
    EncryptAndSaveKey -KeySecureString $cred.Password -Path $EncryptedKeyPath

    Write-Verbose "Stored credential of VIServer $VIServer's user $($cred.UserName) in $EncryptedKeyPath"
}

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
        $VIServerConfigStore = (Get-PoshBotConfiguration $PoshBotConfigFile).PluginConfiguration.VMware.VIServerConfigStore
    }

    $r = New-Object System.Collections.ArrayList

    if (!(Test-Path "$VIServerConfigStore")) {
        mkdir "$VIServerConfigStore" | Out-Null
    }
    $id = 1
    (Get-ChildItem "$VIServerConfigStore\*.clixml").Name | ForEach-Object{
        $obj = "" | Select-Object Id,VIServer,CredentialUser,Path
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
        (Get-ChildItem "$VIServerConfigStore\DisabledVIServer\*.clixml").Name | ForEach-Object{
            $obj = "" | Select-Object Id,VIServer,CredentialUser,Path
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

function Remove-VIServerConfig {
    <#
    .SYNOPSIS
        Remove VI Server Config from the pipeline object.
    .EXAMPLE
        Get-VIServerConfig c:\poshbot -IncludeDisabled | ?{$_.Id -eq "1"} | Remove-VIServerConfig -Verbose
    #>
    param(
        [Parameter(
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({ ($_ |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -contains "VIServer" -and ($_ |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -contains "CredentialUser" -and ($_ |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -contains "Path" })]
        [array]
        $VIServerConfig
    )

    begin{

    }
    process {
        foreach ($config in $VIServerConfig){
            Remove-Item "$($config.Path)\$($config.VIServer)-$($config.CredentialUser).clixml"
            Write-Verbose "VI Server $($config.VIServer) with Credential of $($config.CredentialUser) removed. (stored file deleted from $($config.Path))"
        }
    }
    end{

    }
}

function Disable-VIServerConfig {
    <#
    .SYNOPSIS
        Disable VI Server Config from the pipeline object.
    .EXAMPLE
        Get-VIServerConfig c:\poshbot | ?{$_.VIServer -eq "10.224.146.29"} | Disable-VIServerConfig
    #>
    param(
        [Parameter(
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({ ($_ |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -contains "VIServer" -and ($_ |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -contains "CredentialUser" -and ($_ |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -contains "Path" })]
        [array]
        $VIServerConfig
    )

    begin{

    }
    process {
        foreach ($config in $VIServerConfig){
            if ($config.path -notmatch 'DisabledVIServer') {
                Move-Item "$($config.Path)\$($config.VIServer)-$($config.CredentialUser).clixml" "$($config.Path)\DisabledVIServer"
                Write-Verbose "VI Server $($config.VIServer) with Credential of $($config.CredentialUser) disabled. (stored file moved to $($config.Path))"
            }
        }
    }
    end{

    }
}

function Enable-VIServerConfig {
    <#
    .SYNOPSIS
        Enable VI Server Config from the pipeline object.
    .EXAMPLE
        Get-VIServerConfig c:\poshbot -IncludeDisabled | ?{$_.VIServer -eq "10.224.146.29"} | Enable-VIServerConfig
    #>
    param(
        [Parameter(
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({ ($_ |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -contains "VIServer" -and ($_ |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -contains "CredentialUser" -and ($_ |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -contains "Path" })]
        [array]
        $VIServerConfig
    )

    begin{

    }
    process {
        foreach ($config in $VIServerConfig){
            if ($config.path -match 'DisabledVIServer') {
                Move-Item "$($config.Path)\$($config.VIServer)-$($config.CredentialUser).clixml" "$(Split-Path $config.Path -Parent)"
                Write-Verbose "VI Server $($config.VIServer) with Credential of $($config.CredentialUser) enabled. (stored file moved to $($config.Path))"
            }
        }
    }
    end{

    }
}