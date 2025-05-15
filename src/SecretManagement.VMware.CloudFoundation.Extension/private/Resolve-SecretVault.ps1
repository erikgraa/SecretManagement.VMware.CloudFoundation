function Resolve-SecretVault {
    [CmdletBinding()]
    param (
        [string] $Server
    )

    if (-not($server -match '^https:\/\/')) {
        $server = 'https://' + $server
    } 

    $server
}