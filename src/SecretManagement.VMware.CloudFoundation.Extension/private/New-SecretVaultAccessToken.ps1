function New-SecretVaultAccessToken {
    [CmdletBinding()]
    param (
        [string] $VaultName,
        [hashtable] $AdditionalParameters,
        [string] $Server,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $Credential
    )

    if (-not($Credential)) {
        $credential = Get-Credential -Message 'Enter VMware Cloud Foundation credential that has been granted the ADMIN role'
    }

    $uri = ('{0}/v1/tokens' -f $Server)

    $body = @{
        'username' = $credential.UserName
        'password' = $credential.GetNetworkCredential().Password
    } | ConvertTo-Json

    $request = Invoke-RestMethod -Uri $uri -Method POST -Headers $script:defaultHeaders -Body $body @script:irmSplat

    if ($statusCode -ne '200') {
        throw 'Invalid credential passed'
    }
    else {
        Set-Variable -Name ('SecretManagement_{0}_AccessToken' -f $VaultName) -Value $request.accessToken -Scope Script -Force
        Set-Variable -Name ('SecretManagement_{0}_RefreshToken' -f $VaultName) -Value $request.refreshToken.id -Scope Script -Force

        $script:headers = $script:defaultHeaders.Clone()

        $script:headers.Add('Authorization', ('Bearer {0}' -f (Get-Variable -Name ('SecretManagement_{0}_AccessToken' -f $VaultName) -Scope Script).Value))
    }
}    