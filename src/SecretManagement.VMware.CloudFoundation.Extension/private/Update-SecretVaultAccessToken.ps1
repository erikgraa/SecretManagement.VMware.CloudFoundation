function Update-SecretVaultAccessToken {
    [CmdletBinding()]
    param (
        [string] $VaultName,
        [hashtable] $AdditionalParameters,
        [string] $Server,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $RefreshToken
    )

    $uri = ('{0}/v1/tokens/access-token/refresh' -f $Server)

    Write-Debug 'Refreshing access token'

    $request = Invoke-RestMethod -Uri $uri -Method PATCH -Headers $script:tokenHeaders -Body $RefreshToken @script:irmSplat

    if ($statusCode -ne '200') {
        switch ($statusCode) {
            default {
                throw 'Refresh token is either invalid or expired'
            }
        }
    }
    else {
        Write-Debug 'Refreshed access token'

        Set-Variable -Name ('SecretManagement_{0}_AccessToken' -f $VaultName) -Value $request -Scope Global -Force

        $script:headers = $script:defaultHeaders.Clone()

        $script:headers.Add('Authorization', ('Bearer {0}' -f (Get-Variable -Name ('SecretManagement_{0}_AccessToken' -f $VaultName) -Scope Global).Value))
    }
}