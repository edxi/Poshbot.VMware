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
        [ValidateScript( { ($_ |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -contains "VIServer" -and ($_ |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -contains "CredentialUser" -and ($_ |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -contains "Path" })]
        [array]
        $VIServerConfig
    )

    begin {

    }
    process {
        foreach ($config in $VIServerConfig) {
            if ($config.path -match 'DisabledVIServer') {
                Move-Item "$($config.Path)\$($config.VIServer)-$($config.CredentialUser).clixml" "$(Split-Path $config.Path -Parent)"
                Write-Verbose "VI Server $($config.VIServer) with Credential of $($config.CredentialUser) enabled. (stored file moved to $($config.Path))"
            }
        }
    }
    end {

    }
}
