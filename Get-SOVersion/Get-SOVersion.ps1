<#
.SYNOPSIS
VERSION = 1.0.0
Get the SO version, architecture and Service Pack Installed.

.DESCRIPTION
The Get-SOVersion.ps1 function obtains the OS version, the architecture and the service pack installed. This information is displayed on the screen.

.INPUTS
None. Get-SOVersion.ps1 does not require any input parameter.

.OUTPUTS
None. Update-Month.ps1 does not generate any output.

.EXAMPLE
C:\PS> .\Get-SOVersion.ps1

#>


Function Get-SOVersion()
{
 $sOS =Get-WmiObject -class Win32_OperatingSystem  -Impersonation 3 -ComputerName $env:COMPUTERNAME

 foreach($sProperty in $sOS)
     {
      $SOCaption = $sProperty.Caption
      $SOArch    = $sProperty.OSArchitecture
      $SOSP      = $sProperty.ServicePackMajorVersion
     }

 $SOTotal = "$SOCaption SP$SOSP - $SOArch"
 return $SOTotal 
}

Get-SOVersion