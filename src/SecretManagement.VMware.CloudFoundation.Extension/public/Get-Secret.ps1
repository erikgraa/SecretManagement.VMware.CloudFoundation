function Get-Secret {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string] $Name,
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )

    $server = Resolve-SecretVault -Server $AdditionalParameters.Server

    Test-SecretVault -VaultName $VaultName -AdditionalParameters $AdditionalParameters

    $resourceName = $Name
    $userName = $Name

    if ($name -match '\/') {
        $resourceName = $name.split('/')[0]
        $userName = $name.split('/')[-1]
    }

    $results = @()

    $uri = ('{0}/v1/credentials?resourceName={1}' -f $server, $resourcename)      

    $results += (Invoke-RestMethod -Uri $uri -Headers $script:headers @script:irmSplat).elements

    $uri = ('{0}/v1/system/credentials/service' -f $server)    

    $results += Invoke-RestMethod -Uri $uri -Headers $script:headers @script:irmSplat

    if (($results| Measure-Object).Count -ge 1) {     
        $results = $results | Where-Object { $_.username -eq $userName }

        if ($null -ne $results) {
            $password = $null

            if ([string]::IsNullOrEmpty($results.password.length) -or $results.password.Length -gt 0) {
                $password = $results.password            
            }
            elseif ([string]::IsNullOrEmpty($results.secret.length) -or $results.secret.Length -gt 0) {
                $password = $results.secret
            }

            if ($null -eq $password) {
                $password =  (New-Object System.Security.SecureString)
                Write-Debug 'Password is empty'
            }
            else {
                $password = (ConvertTo-SecureString -String $password -AsPlainText -Force)
            }

            [System.Management.Automation.PSCredential]::new($results.userName, $password)
        }
    }
}