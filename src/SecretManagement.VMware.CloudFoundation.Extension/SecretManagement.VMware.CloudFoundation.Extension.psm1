$script:defaultHeaders = @{
    'Accept' = 'application/json'
    'Content-Type' = 'application/json'
}

$script:tokenHeaders = @{
    'Accept' = 'application/json'
    'Content-Type' = 'text/plain'
}

$script:defaultVaultCredentialPath = if ($IsWindows) {
    ('{0}\Microsoft\PowerShell\secretmanagement' -f $env:LocalAppData)
}
elseif ($IsLinux -or $IsMacOS) {
    ('{0}/.secretmanagement' -f $env:HOME)
}

<#
$script:vaultApiEndpoints = @{
	'credentials' = @{
		'5.x' = @{
            'uri' = '/v1/credentials'
            'method' = 'GET'
        }
	}
    'serviceCredentials' = @{
        '5.x' = 
            'uri' = '/v1/system/credentials/service'
            'method' = 'GET'
        }
    }
    'tokenCreation' = @{
        '5.x' = @{
            'uri' = '/v1/tokens'
            'method' = 'POST'
        }
    }
    'tokenRefresh' = @{
        '5.x' = @{
            'uri' = '/v1/tokens/access-token/refresh'
            'method' = 'PATCH'
        }
    }
    'version' = @{
        '5.x' = 
            'uri' = '/v1/sddc-managers' 
            'method' = 'GET'  # [version]elements.version
        }
    }
}
#>    

# Dot sourcing functions/classes/enums

$public = Get-ChildItem -Path ('{0}/public' -f $PSScriptRoot) -File -Recurse -ErrorAction Stop | Where-Object { $_.Extension -eq '.ps1' } 
$private = Get-ChildItem -Path ('{0}/private' -f $PSScriptRoot) -File -Recurse -ErrorAction Stop | Where-Object { $_.Extension -eq '.ps1' } 

foreach ($_cmdlet in @($public + $private)) {
    try {
        . $_cmdlet.FullName
    }
    catch {
        throw ("Failed to dot-source '{0}': {1}" -f $_cmdlet.Name, $_)
    }
}

Export-ModuleMember -Function $public.BaseName