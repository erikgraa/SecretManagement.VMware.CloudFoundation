function Connect-SecretVault {
    [CmdletBinding()]
    param (
        [string] $VaultName,
        [hashtable] $AdditionalParameters,
        [string] $Server
    )

    if (Test-Path -Path $AdditionalParameters.CredentialPath -PathType Leaf -ErrorAction SilentlyContinue) {
        Write-Debug ("Setting encrypted credential file path to '{0}' from vault parameter" -f $AdditionalParameters.CredentialPath)
        $script:thisVaultCredentialPath = $AdditionalParameters.CredentialPath
    }
    else {
        $script:thisVaultCredentialPath = ('{0}\Vault_{1}_Credential.xml' -f $script:defaultVaultCredentialPath, $VaultName)
        Write-Debug ("Setting encrypted credential file path to the default for this vault- {0}" -f $script:thisVaultCredentialPath)        
    }

    $authenticated = $false

    $accessToken = (Get-Variable -Name ('SecretManagement_{0}_AccessToken' -f $VaultName) -Scope Script -ErrorAction SilentlyContinue) | Select-Object -ExpandProperty Value
    $refreshToken = (Get-Variable -Name ('SecretManagement_{0}_RefreshToken' -f $VaultName) -Scope Script -ErrorAction SilentlyContinue) | Select-Object -ExpandProperty Value

    if ($null -ne $accessToken) {
        if (Test-SecretVaultAccessToken -VaultName $VaultName -AdditionalParameters $AdditionalParameters -AccessToken $accessToken -Server $server) {
            $authenticated = $true
        }
    }

    if ($authenticated -eq $false -and $refreshToken) {
        try {
            Update-SecretVaultAccessToken -VaultName $vaultName -RefreshToken $refreshToken -Server $server
            $authenticated = $true
        }
        catch {
            Write-Debug 'Refresh token was invalid or has expired'
        }
    }

    if ($authenticated -eq $false) {
        if (Test-Path -Path $script:thisVaultCredentialPath -PathType Leaf -ErrorAction SilentlyContinue) {        
            Write-Debug ("Found CliXml file in path '{0}'" -f $script:thisVaultCredentialPath)            
            $credential = Import-CliXml -Path $script:thisVaultCredentialPath

            try {
                New-SecretVaultAccessToken -VaultName $vaultName -AdditionalParameters $AdditionalParameters -Credential $Credential -Server $server
                $authenticated = $true
            }
            catch {
                Write-Debug 'Credential in CliXml was invalid'
            }
        }
        else {
            Write-Debug ("Did not not find CliXml file in path '{0}'" -f $script:thisVaultCredentialPath)
        }        
    }

    if ($authenticated -eq $false) {
        try {
            New-SecretVaultAccessToken -VaultName $vaultName -AdditionalParameters $AdditionalParameters -Server $server
            $authenticated = $true
        }
        catch {
            Write-Debug 'Credential acquired interactively was invalid'
        }
    }    

    if ($authenticated -eq $false) {
        throw ("Failed authenticating with VMware Cloud Foundation vault '{0}' after exhausting every option" -f $VaultName)
    }
}