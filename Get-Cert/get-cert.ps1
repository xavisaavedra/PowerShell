 <#
.SYNOPSIS
VERSION = 1.0.0
Get info from certificates stored in localhost and bindings asociated.

.DESCRIPTION
The Get-Cert.ps1 obtains all the certificates stored in Stores "My","WebHosting" [Variable $StoreNames], several of its properties [Line 78 select-object
(https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/providers/get-childitem-for-certificate?view=powershell-6)],
and the associated bindings. This information is export to CSV file.

.INPUTS
None. Get-Cert.ps1 does not require any input parameter.

.OUTPUTS
In the same folder: Cert.csv.

.EXAMPLE
C:\PS> .\Get-Cert.ps1.ps1

#>
 function Get-Cert()
        {

        [CmdletBinding()]
        [OutputType('System.Array')]
        param 
            (
            [parameter(Mandatory=$true)]
            [ValidateNotNull()]
            [string[]]$computer
            )


       PROCESS
            {
           $out                = [Reflection.Assembly]::LoadWithPartialName('Microsoft.Web.Administration')
           $sm                 = [Microsoft.Web.Administration.ServerManager]::OpenRemote($computer)  
           $WebSiteBindings    = @()   
           $WebSites           = $sm.Sites
           foreach ($WebSite in $WebSites)
               {
                $WebSiteName = $WebSite.Name        
                $Bindings = $WebSite.Bindings       
                foreach ($Binding in $Bindings)
                    {   
                     $BindingInformation = $Binding.BindingInformation
                     $RawAttributes = $Binding.RawAttributes
                     if ($RawAttributes -ne $null)
                        {
                            if ($RawAttributes.ContainsKey("certificateHash"))
                              {                                   
                               $ThumbPrint = $RawAttributes["certificateHash"]
                               if ($ThumbPrint -ne "")
                                    {   
                                    $WebSiteBinding = $null
                                    $WebSiteBinding = New-Object PSObject
                                    $WebSiteBinding | Add-Member -type NoteProperty -Name "BindingInformation" -Value $BindingInformation
                                    $WebSiteBinding | Add-Member -type NoteProperty -Name "WebSiteName" -Value $WebSiteName
                                    $WebSiteBinding | Add-Member -type NoteProperty -Name "ThumbPrint" -Value $ThumbPrint 
                                    $WebSiteBindings+=$WebSiteBinding 
                                    }
                                }
                            }
                        }
                    }   


          $dFechaRevision        = [datetime] (get-date)
          [string]$FechaRevision = "{0:dd/MM/yyyy}" -f $dFechaRevision
          $StoreNames            = "My","WebHosting"

          foreach ($StoreName in $StoreNames)
            {
            $ro    =[System.Security.Cryptography.X509Certificates.OpenFlags]"ReadOnly"
            $lm    =[System.Security.Cryptography.X509Certificates.StoreLocation]"LocalMachine"
            $store = new-object System.Security.Cryptography.X509Certificates.X509Store("\\$computer\$Storename",$lm)
            $store.Open($ro)


            $certEquipo = $store.Certificates | select-object  @{label = 'FrName'; expression='FriendlyName'},Issuer,NotBefore,NotAfter,HasPrivate,Thumbprint, Subject -ExpandProperty SignatureAlgorithm 
    
            $Certificados=@()   
                foreach ($cert in $certEquipo)
                    {
                    $certificadoequipo = New-Object PSObject
                    $certificadoequipo | Add-Member -type NoteProperty -Name FechaRevision -Value $FechaRevision
                    $certificadoequipo | Add-Member -type NoteProperty -Name Servidor -Value $($computer)
                    $certificadoequipo | Add-Member -type NoteProperty -Name StoreName -Value $StoreName
                    $certificadoequipo | Add-Member -type NoteProperty -Name FriendlyName -Value $cert.FrName
                    $certificadoequipo | Add-Member -type NoteProperty -Name Issuer -Value $cert.Issuer
                    $certificadoequipo | Add-Member -type NoteProperty -Name NotBefore -Value $cert.NotBefore
                    $certificadoequipo | Add-Member -type NoteProperty -Name NotAfter -Value $cert.NotAfter

                    $Fecha = [datetime]$certificadoequipo.NotAfter
                    [string]$stringfecha = "{0:dd/MM/yyyy}" -f $Fecha

                    $certificadoequipo | Add-Member -type NoteProperty -Name Caducidad -Value $stringfecha
                    $certificadoequipo | Add-Member -type NoteProperty -Name Thumbprint -Value $cert.Thumbprint

                    $WebBinding = $null
                    $ContadorWebBindings=0
                    $WebBindings = $WebSiteBindings | ?{$_.Thumbprint -eq $certificadoequipo.Thumbprint} 
                    foreach($WebBinding in $WebBindings)
                        {
                        $certificadoequipo | Add-Member -type NoteProperty -Name "WebSiteName$ContadorWebBindings" -Value $WebBinding.WebSiteName
                        $certificadoequipo | Add-Member -type NoteProperty -Name "BindingInformation$ContadorWebBindings" -Value $WebBinding.BindingInformation 
                        $ContadorWebBindings++
                        }

                    $certificadoequipo | Add-Member -type NoteProperty -Name HasPrivate -Value $cert.HasPrivate
                    $Subject            = $cert | select-object Subject
                    $SignatureAlgorithm = $cert | select-object FriendlyName
                    $Value              = $cert | select-object Value
                    $certificadoequipo | Add-Member -type NoteProperty -Name Subject -Value $Subject.subject
                    $certificadoequipo | Add-Member -type NoteProperty -Name SignatureAlgorithm -Value $SignatureAlgorithm.FriendlyName
                    $certificados = $certificados + $certificadoequipo
                    }
                return $certificados 
                }
            }       # END PROCESS
        }           # END FUNCTION
    






clear

$computer = $env:COMPUTERNAME
$Certificates = get-cert $computer
$Certificates | select-object StoreName,Servidor,Caducidad,FechaRevision,WebSiteName0,BindingInformation0,WebSiteName1,BindingInformation1,WebSiteName2,BindingInformation2,WebSiteName3,BindingInformation3,WebSiteName4,BindingInformation4,Subject,Issuer,NotBefore,NotAfter,HasPrivate,Thumbprint,FriendlyName,SignatureAlgorithm | export-csv ".\cert.csv" -Delimiter ";"-NoTypeInformation










