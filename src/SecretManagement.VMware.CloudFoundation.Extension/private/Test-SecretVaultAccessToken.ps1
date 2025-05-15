function Test-SecretVaultAccessToken {
    [CmdletBinding()]
    param (
        [string] $VaultName,
        [hashtable] $AdditionalParameters,
        [string] $Server,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $AccessToken
    )

    $uri = ('{0}/v1/sddc-managers' -f $Server)

    $script:testHeaders = @{
        'Accept' = 'application/json'
        'Authorization' = ('Bearer {0}' -f $AccessToken)
    }

    $response = Invoke-RestMethod -Uri $uri -Headers $testheaders -Method GET @script:irmSplat

    if ($statusCode -ne '200') {
        switch ($statusCode) {
            '403' {
                Write-Debug 'Access token has insufficient privileges'
            }
            default {
                Write-Debug 'Access token is either invalid or expired'
            }
        }

        $false
    }
    else {
        try {
            [version]$version = $response.elements.version.tostring().split('-')[0]
            
            Write-Debug ("VMware Cloud Foundation instance '{0}' is on version '{1}'" -f $Server, $version)

            $true            
        }
        catch {
            Write-Error ("Received garbled version number from VMware Cloud Foundation instance '{0}': {1}" -f $Server, $_)

            $false
        }
    }
}