function Remove-Secret {
    [CmdletBinding()]
    param (
        [string] $Name,
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )

    Write-Warning "It's not possible to remove secrets from a VMware Cloud Foundation Vault"
}