function Get-ErrorInformation {
    [cmdletbinding()]
    param($incomingError)

    if ($incomingError -and (($incomingError| Get-Member | Select-Object -ExpandProperty TypeName -Unique) -eq 'System.Management.Automation.ErrorRecord')) 
        {
        Write-Host `n"Error Detectado:"`n
        Write-Host `t"Exception type for catch: [$($IncomingError.Exception | Get-Member | Select-Object -ExpandProperty TypeName -Unique)]"`n 

        if ($incomingError.InvocationInfo.Line) 
            {
            Write-Host `t"Command                 : [$($incomingError.InvocationInfo.Line.Trim())]"  
            }
        else
            {
            Write-Host `t"Unable to get command information! Multiple catch blocks can do this :("`n
            }

        Write-Host `t"Exception               : [$($incomingError.Exception.Message)]"`n
        Write-Host `t"Target Object           : [$($incomingError.TargetObject)]"`n
    }
    Else 
    {
    Write-Host "Please include a valid error record when using this function!" -ForegroundColor Red -BackgroundColor DarkBlue
}

}
function Get-PWD_Crypt([string]$fase){

    if ((Test-Path ".\secure") -eq $false) {
        write-host "No existe la carpeta .\secure"
        }

        $servername           = $fase
        $enc                  = [system.Text.Encoding]::UTF8
        $encrypted            = Import-Clixml $(".\secure\"+$servername+".SEC")            
        $uid                  = $(Get-WmiObject -Class Win32_ComputerSystemProduct | Select-Object -Property UUID).UUID ### Se crea key válida para usar con ConvertFrom-SecureString     (La seguridad la da RSA, esto simplemente es para crear el objeto system.security)
        $key                  = $enc.GetBytes($uid.Replace("-",""))        
        $csp                  = New-Object System.Security.Cryptography.CspParameters
        $csp.KeyContainerName = $("ContenedorKey"+$servername)
        $csp.Flags            = $csp.Flags -bor [System.Security.Cryptography.CspProviderFlags]::UseMachineKeyStore
        $rsa                  = New-Object System.Security.Cryptography.RSACryptoServiceProvider -ArgumentList 5120,$csp
        $rsa.PersistKeyInCsp  = $true            
        $password             = [char[]]$rsa.Decrypt($encrypted, $true) -join "" | ConvertTo-SecureString -Key $key
        return $password
    }

function Set-PWD_Crypt([string]$password){

    if ((Test-Path ".\secure") -eq $false) {
    New-Item "secure"-type directory | out-null
    }

    $servername           = $env:computername
    $enc                  = [system.Text.Encoding]::UTF8
    $uid                  = $(Get-WmiObject -Class Win32_ComputerSystemProduct | Select-Object -Property UUID).UUID
    $key                  = $enc.GetBytes($uid.Replace("-",""))
    $pass                 = (ConvertTo-SecureString -String "$password" -AsPlainText -force)
    $securepass           = $pass |ConvertFrom-SecureString -Key $key
    $bytes                = [byte[]][char[]]$securepass            
    $csp                  = New-Object System.Security.Cryptography.CspParameters
    $csp.KeyContainerName = $("ContenedorKey"+$servername)
    $csp.Flags            = $csp.Flags -bor [System.Security.Cryptography.CspProviderFlags]::UseMachineKeyStore
    $rsa                  = New-Object System.Security.Cryptography.RSACryptoServiceProvider -ArgumentList 5120,$csp
    $rsa.PersistKeyInCsp  = $true
    $encrypted            = [char[]]$rsa.Encrypt($bytes, $true)

    $encrypted | Export-Clixml $(".\secure\"+$servername+"TJ.SEC")
    }

Function Get-SOVersion(){
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

function Get-ServicesStatus() {
    <#
        .Synopsis
            list the status of the service or services indicated in the input parameter
        .DESCRIPTION
            list in a form the status of the service or services indicated in the input parameter. 
            The possible states are STARTED, STOPPED and DOES NOT EXIST
        .EXAMPLE 
            Obtain the status of the services contained in a csv:
                    
                    $services = Get-Content .\services.csv
                    $Services = ($services).split(",")
                    Get-ServicesStatus $services
        .EXAMPLE
            Get the status of a service passed as a parameter (ServiceName):

                    Get-ServicesStatus mfefire
        .OUTPUTS
            n/a
        .NOTES
            Written by Xavi Saavedra, https://github.com/xavisaavedra/
            I take no responsibility for any issues caused by this script.
        .FUNCTIONALITY
            Status of services
        .LINK
            https://github.com/xavisaavedra/PowerShell/tree/master/Get-ServicesStatus
           #>


    [CmdletBinding()]
    param (
            [parameter(Mandatory=$true)]
            [ValidateNotNull()]
            [string[]]$Services
            )


    PROCESS {
    
            $Servidor = $env:computername
            Add-Type -AssemblyName System.Windows.Forms
            $form                 = new-object System.Windows.Forms.form 
            $form.StartPosition   = "CenterScreen"
            $Form.FormBorderStyle = 'Fixed3D'
            $Form.MaximizeBox     = $false
            $Form.AutoSize        = $True
            $Form.width           = 800
            $Form.height          = 400

            $Form.Text = "Estado Servicios Servidor: $($Servidor)"


            $button            = New-Object System.Windows.Forms.Button
            $button.Location   = New-Object System.Drawing.Size(365,380)
            $button.Size       = New-Object System.Drawing.Size(100,50)
            $button.Text       = "Salir"
            $form.CancelButton = $button

            $Form.Controls.Add($button)

            
             # [$x Counter. multiplier to control the start of label writing]
             # @type {Number}
             #
            $x = 0

            foreach ($Service in $Services) {
            
                $svc = get-service $Service -ErrorAction SilentlyContinue
                $x ++

                
                 # [$Inicio  Y coordinates that determine where the label text will be displayed within the dialog box]
                 # @type {[Number]}
                 #
                $Inicio                     = $x * 20
                $Label                      = new-object System.Windows.Forms.Label
                $Label.Location             = new-object System.Drawing.Size(10,$inicio)
                $System_Drawing_Size        = New-Object System.Drawing.Size 
                $System_Drawing_Size.Width  = 800
                $System_Drawing_Size.Height = 23
                $Label.Size                 = $System_Drawing_Size 
                $Label.Font                 = New-Object System.Drawing.Font("Microsoft Sans Serif",9,1,3,0)
    
                if ($svc.Length -gt 0) {

                    if ($svc.status -eq "Stopped") {
                        $Label.Text      = "El servicio $($svc.DisplayName) ($($Svc.name)) esta Stopped"
                        $Label.ForeColor = [System.Drawing.Color]::FromArgb(255,255,0,0) }
                        
                        else {
                        $Label.Text      = "El servicio $($svc.DisplayName) ($($Svc.name)) esta Started"
                        $Label.ForeColor = [System.Drawing.Color]::FromArgb(255,50,0,100) }
              
                    }    
                    else {
                        $Label.Text      =  "El servicio $($Service) NO EXISTE"
                        $Label.ForeColor = [System.Drawing.Color]::FromArgb(255,255,0,0) } 
                    
                    $Form.Controls.Add($Label)   
                   
                }
                 $form.ShowDialog() 
            }
        } 

 function Get-Cert(){
<#
    .SYNOPSIS
        VERSION = 1.0.0
        Get info from certificates stored in localhost and bindings asociated.

    .DESCRIPTION
        The Get-Cert.ps1 obtains all the certificates stored in Stores "My","WebHosting" [Variable $StoreNames], several of its properties [Line 78 select-object (https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/providers/get-childitem-for-certificate?view=powershell-6)], and the associated bindings. This information is export to CSV file.

    .INPUTS
        None. Get-Cert.ps1 does not require any input parameter.

    .OUTPUTS
        In the same folder: Cert.csv.

    .EXAMPLE
        C:\PS> .\Get-Cert.ps1

#>

        
        [CmdletBinding()]
        [OutputType('System.Array')]
        param
            # Especifique nombre de maquina 
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
    

function Logg([string]$level, [string]$Type, [string]$Titulo, [string]$Valor){
       
       
        if (!"DEBUG".equals(${LogLevel}) -and "DEBUG".equals(${level})) {
            return
            }
        
        $color="White"
        if ("ERROR".equals(${level}.toupper())) {
            $color="Red"
            } elseif ("WARNING".equals(${level}.toupper())) {
            $color="Yellow"
            } elseif ("DEBUG".equals(${level}.toupper())) {
            $color="Cyan"
            }elseif ("OK".equals(${level}.toupper())) {
            $color="green"
            }


        $date = Get-Date -Format g

        If($Type.equals("HEAD")){
        
        $Tab           = 15
        $measureObject = $Titulo | Measure-Object -Character
        $Spaces        = $measureObject.Characters
        $AddSpaces     = $tab - $Spaces
        Write-host "$($Titulo)"(" " * $AddSpaces)"$($valor)" -ForegroundColor ${color}
        
        $text = $titulo.PadRight($Tab," ") + $valor
        # Out-File -FilePath ${TranscriptFile} -encoding "ASCII" -Append -InputObject "$($Text)"
        
        }
        else
        {
        Write-Host "${Type}" -ForegroundColor ${color}
        # Out-File -FilePath ${TranscriptFile} -encoding "ASCII" -Append -InputObject "${Type}"
        }   
        }

