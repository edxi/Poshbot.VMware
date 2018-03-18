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
        [ValidateScript( { ($_ |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -contains "VIServer" -and ($_ |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -contains "CredentialUser" -and ($_ |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -contains "Path" })]
        [array]
        $VIServerConfig
    )

    begin {

    }
    process {
        foreach ($config in $VIServerConfig) {
            if ($config.path -notmatch 'DisabledVIServer') {
                Move-Item "$($config.Path)\$($config.VIServer)-$($config.CredentialUser).clixml" "$($config.Path)\DisabledVIServer"
                Write-Verbose "VI Server $($config.VIServer) with Credential of $($config.CredentialUser) disabled. (stored file moved to $($config.Path))"
            }
        }
    }
    end {

    }
}
