function EncryptAndSaveKey {
    param(
        [Parameter(Mandatory, ParameterSetName = 'SecureString')]
        [ValidateNotNull()]
        [SecureString]
        $KeySecureString,

        [Parameter(Mandatory, ParameterSetName = 'PlainText')]
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
