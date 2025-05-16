# SecretManagement.VMware.CloudFoundation

![SecretManagement.VMware.CloudFoundation](https://raw.githubusercontent.com/erikgraa/SecretManagement.VMware.CloudFoundation/main/images/logo.png)

[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/erikgraa/SecretManagement.VMware.CloudFoundation/raw/main/LICENSE.txt)
![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/SecretManagement.VMware.CloudFoundation?label=PowerShell%20Gallery&color=green)
![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/SecretManagement.VMware.CloudFoundation?color=green)

> This PowerShell module is a Microsoft.PowerShell.SecretManagement extension for VMware Cloud Foundation available in [the PowerShell Gallery](https://www.powershellgallery.com/packages/SecretManagement.VMware.CloudFoundation).

> [!TIP]
> Read the related blog post at https://blog.graa.dev/PowerShell-SecretManagementVCF

- [📄 Prerequisites](#-prerequisites)
- [📦 Installation](#-installation)
- [🔧 Usage](#-usage)
- [🙌 Contributing](#-contributing)

## 🚀 Features 

* Secret retrieval from VMware Cloud Foundation 4.x and 5.x instances
* Cross-platform / Support for PowerShell Core

## 📄 Prerequisites

### PowerShell version

> [!IMPORTANT]  
> At present only PowerShell 7 is supported, and testing has been done on PowerShell `7.5.1`.

### VMware Cloud Foundation

> [!NOTE]  
> This module is tested on VMware Cloud Foundation version `5.2.1.2`, but should be compatible with all 5.x versions and possibly 4.x as the API for token creation and credential retrieval has not changed in years.

### Microsoft.PowerShell.SecretManagement

Make sure that the requisite `Microsoft.PowerShell.SecretManagement` module is installed.

```powershell
Install-Module -Name Microsoft.PowerShell.SecretManagement
```

## 📦 Installation

Install the VMware Cloud Foundation extension that is published to the PowerShell Gallery:

```powershell
Install-Module -Name SecretManagement.VMware.CloudFoundation -AllowClobber
```

## 🔧 Usage

### Register vault

A Vault name and Server are required to register a VMware Cloud Foundation instance. Enable certificate checking if a valid certificate is present.

To access secrets in the vault after registering one needs a user that has the `ADMIN` role. This could be a local `vsphere.local` user or an identity provider-backed one.

```powershell
$vaultName = 'lab-vcf01'
$module = 'SecretManagement.VMware.Cloudfoundation'

$vaultParameters = @{ 
    'Server' = 'https://lab-vcf01.dev.graa'
    'SkipCertificateCheck' = $false
}

Register-SecretVault -Name $vaultName -Module $module -VaultParameters $vaultParameters
```

One can also point to an encrypted file with credentials to authenticate with VMware Cloud Foundation for automation purposes.

If `CredentialPath` is not passed when registering, the default path of `$env:LocalAppData\Microsoft\PowerShell\secretmanagement\Vault_<VaultName>_Credential.xml` will be tested, or `$HOME/.secretmanagement/Vault_<VaultName>_Credential.xml` on Linux/macOS.

```powershell
$vaultParameters = @{ 
    'Server' = 'https://lab-vcf01.dev.graa'
    'SkipCertificateCheck' = $false
    'CredentialPath' = 'C:\ProgramData\VaultCredential.xml'     
}
```

Optionally set this vault as the default one.

```powershell
Set-SecretVaultDefault -Name 'lab-vcf01'
```

### Authenticating

When using the cmdlets exposed by the module, authentication attempts happen in this order until one succeeds or they are all exhausted:

1. If `$script:SecretManagement_<VaultName>_AccessToken` exists - check if it is valid and not expired
2. If instead `$script:SecretManagement_<VaultName>_RefreshToken` exists - check if it is valid and not expired and can be used for a new access token
3. Checking whether `%ProgramData%\Vault_<VaultName>_Credential.xml` exists and has a valid credential, or `$HOME/.secretmanagement` on Linux/macOS
4. Checking whether the file in the `CredentialPath` VaultParameter exists and has a valid credential
5. Interactively asking for a username and password

#### Credential file

The current alternative for using the module for non-interactive automation purposes is to save a credential to access SDDC Manager to disk.

> [!NOTE]  
> On Windows the contents of this file can only be unlocked by the user creating the file on that machine. 

> [!IMPORTANT]  
> Saving credentials with `Export-CliXml` on Linux or macOS does not encrypt the contents.

This is done like so for each VMware Cloud Foundation instance, in the example below for the `lab-vcf01` vault:

```powershell
$credential = Get-Credential -Message 'Enter VMware Cloud Foundation credential'
$vaultName = 'lab-vcf01'

$credentialPath = if ($IsWindows) {
    ('{0}\Microsoft\PowerShell\secretmanagement' -f $env:LocalAppData)
}
elseif ($IsLinux -or $IsMacOS) {
    ('{0}/.secretmanagement' -f $env:HOME)
}

$credentialFilePath = ('{0}\Vault_{1}_Credential.xml' -f $credentialPath, $vaultName)

$credential | Export-CliXml -Path $credentialFilePath
```

### Retrieve secret info

Retrieve information about every secret:

```powershell
Get-SecretInfo -Vault 'lab-vcf01'
```

Retrieve metadata:

![Get-Secret](/images/Get-SecretInfo-Metadata.png)

Filter by VMware Cloud Foundation workload name:

```powershell
Get-SecretInfo -Vault 'lab-vcf01' -Name 'lab-m01'
```

Filter by resource:

```powershell
Get-SecretInfo -Vault 'lab-vcf01' -Name 'lab-m01-vc01.dev.graa'
```

**Get-SecretInfo example**

![Get-SecretInfo](/images/Get-SecretInfo.gif)

### Retrieve secret

Retrieve a secret by specifying the full identifier:

```powershell
Get-Secret -Vault 'lab-vcf01' -Name 'lab-m01-vc01.dev.graa/administrator@vsphere.local'
```

**Get-Secret example**

![Get-Secret](/images/Get-Secret.gif)

## 🙌 Contributing

Any contributions are welcome and appreciated!

Please do so by forking the project and opening a pull request!

## ✨ Credits

> [!NOTE]
> This module is not supported by VMware in any way. The module logo is a blending of the VMware vCF logo, the PowerShell logo and a [free stock padlock icon](https://www.iconpacks.net/free-icon/yellow-padlock-11726.html).