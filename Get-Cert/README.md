# Get-Cert
VERSION = 1.0.0

Get info from certificates stored in localhost and bindings asociated.

## Getting Started

The Get-Cert.ps1 obtains all the certificates stored in Stores "My","WebHosting" [Variable $StoreNames], several of its properties [Line 78 select-object
(https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/providers/get-childitem-for-certificate?view=powershell-6)],
and the associated bindings. This information is export to CSV file. (.\cert.csv)

### Prerequisites

N/A

```
C:\PS> .\ Get-Cert.ps1
```

## Authors

* **Xavi Saavedra** 

## License

[GNU General Public License v3.0](PowerShell/LICENSE)