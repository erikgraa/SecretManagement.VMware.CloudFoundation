function Get-SecretInfo {
    [CmdletBinding()]
    param (
        [string] $Filter,
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )
   
    $server = Resolve-SecretVault -Server $AdditionalParameters.Server

    Test-SecretVault -VaultName $VaultName -AdditionalParameters $AdditionalParameters

    $results = @()

    $uri = ('{0}/v1/credentials' -f $server)

    $results += (Invoke-RestMethod -Uri $uri -Headers $script:headers @script:irmSplat).elements

    $uri = ('{0}/v1/system/credentials/service' -f $server)    

    $results += Invoke-RestMethod -Uri $uri -Headers $script:headers @script:irmSplat
    
    if (-not([string]::IsNullOrEmpty($Filter)) -and $Filter -ne '*') {
        if ($Filter -match '\/') { 
            $resourceName = $filter.split('/')[0]
            $userName = $filter.split('/')[-1]
        
            $results = $results | Where-Object { $_.resource.resourceName -match $resourceName -and $_.username -match $username  }    
        }
        else {
            $results = $results | Where-Object { $_.resource.resourceName -match $Filter -or $_.username -match $Filter -or $_.id -match $Filter }
        }
    }

    $results | ForEach-Object {
        if ($PSItem.Resource.Count -gt 0) {
            $metadata = [Ordered]@{
                'Id' = $PSItem.Id
                'CredentialType' = $PSItem.credentialType
                'AccountType' = $PSItem.accountType
                'CreationTimestamp' = $PSItem.CreationTimestamp
                'ModificationTimestamp' = $PSItem.ModificationTimestamp
                'Resource' = $PSItem.resource
            }

            return @(,[Microsoft.PowerShell.SecretManagement.SecretInformation]::new(
                ('{0}/{1}' -f $PSItem.resource.resourceName, $PSItem.userName),
                [Microsoft.PowerShell.SecretManagement.SecretType]::PSCredential,
                $VaultName,
                $metadata))
        } 
        else {
            $metadata = [Ordered]@{
                'CredentialType' = $PSItem.credentialType
                'EntityType' = $PSItem.EntityType
                'CreationTimestamp' = $PSItem.CreationTime
                'ModificationTimestamp' = $PSItem.ModificationTime
                'TargetType' = $PSItem.TargetType
            }

            return @(,[Microsoft.PowerShell.SecretManagement.SecretInformation]::new(
                ('{0}' -f $PSItem.userName),        # Name of secret
                "String",      # Secret data type [Microsoft.PowerShell.SecretManagement.SecretType]
                $VaultName,    # Name of vault
                $metadata))    # Optional Metadata parameter
        }
    }
}