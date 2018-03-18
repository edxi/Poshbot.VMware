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
        [ValidateScript( { ($_ |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -contains "VIServer" -and ($_ |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -contains "CredentialUser" -and ($_ |Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name') -contains "Path" })]
        [array]
        $VIServerConfig
    )

    begin {

    }
    process {
        foreach ($config in $VIServerConfig) {
            Remove-Item "$($config.Path)\$($config.VIServer)-$($config.CredentialUser).clixml"
            Write-Verbose "VI Server $($config.VIServer) with Credential of $($config.CredentialUser) removed. (stored file deleted from $($config.Path))"
        }
    }
    end {

    }
}
