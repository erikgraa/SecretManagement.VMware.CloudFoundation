function Test-SecretVault {
    [CmdletBinding()]
    param (
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )

    $server = Resolve-SecretVault -Server $AdditionalParameters.Server
      
    if (-not($server)) {
        throw ("Vault '{0}' is missing a VMware Cloud Foundation server in its configuration. Re-register according to documentation" -f $VaultName)
    }

    if (-not($script:irmSplat)) {
        if ($AdditionalParameters.SkipCertificateCheck -eq $true) {
            $script:irmSplat = @{
                'SkipCertificateCheck' = $true
            }
        }
        else {
            $script:irmSplat = @{
                'SkipCertificateCheck' = $false
            }
        }

        $script:irmSplat.Add('SkipHttpErrorCheck', $true)
        $script:irmSplat.Add('StatusCodeVariable', 'statusCode')
    }  
    
    try {
        $null = Invoke-RestMethod -Uri $server @script:irmSplat
    }
    catch {
        if ($_.Exception.Message -eq 'The SSL connection could not be established, see inner exception.') {
            throw ("Failed to connect to VMware Cloud Foundation instance '{0}': Untrusted certificate - either add SkipCertificateCheck to the vault's parameters or install a certificate on the SDDC Manager" -f $server)
        }
        
        throw ("Failed to connect to VMware Cloud Foundation instance '{0}': {1}" -f $server, $_)
    }

    Connect-SecretVault -VaultName $VaultName -AdditionalParameters $AdditionalParameters -Server $server
}