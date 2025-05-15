function Unregister-SecretVault {
    [CmdletBinding()]
    param (
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )    

    Remove-Variable -Name ('SecretManagement_{0}_AccessToken' -f $VaultName) -Scope Script -Force -ErrorAction SilentlyContinue
    Remove-Variable -Name ('SecretManagement_{0}_RefreshToken' -f $VaultName) -Scope Script -Force -ErrorAction SilentlyContinue    
}