function LoadAndUnencryptKey {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path
    )

    $storedKey = Import-Clixml $Path | ConvertTo-SecureString
    $cred = New-Object -TypeName PSCredential -ArgumentList 'jpgr', $storedKey
    # $cred.GetNetworkCredential().Password
    # Write-Verbose "The Key has been loaded and unencrypted from $Path"
    $cred.GetNetworkCredential().Password
}
