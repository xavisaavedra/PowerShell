﻿<#
.SYNOPSIS
VERSION = 0.0.1
Create WebApplication in SharePoint 2019

.DESCRIPTION
The Set-WebApp.ps1 create a WebApplication based on file Settings.xml parameters

.INPUTS
Set-WebApp.ps1 require file Settings.xml in folder /Config

.OUTPUTS
None. Set-WebApp.ps1 create Log file in /logs

.EXAMPLE
C:\PS> .\Set-WebApp.ps1

#>


function CN-Path {
    [cmdletbinding()]
    param($Path)

	switch(Test-Path $path){
   		$False {$Result = "No Existe"
			$Color = "Red"}

   		$True  {$Result = "OK"
			$Color = "Green"}
		}

	Return $Path, $Result, $Color
   }


function CN-File {
    [cmdletbinding()]
    param($File)

  switch(Test-Path $File){
      $False {$Result = "No Existe"
      $Color = "Red"}

      $True  {$Result = "OK"
      $Color = "Green"}
    }

  Return $File, $Result, $Color
   }


clear
#############################################################################################################
# Get Start Time
#############################################################################################################
$startDTM = (Get-Date)
	

$Tab = [char]9

$PSscript       = $MyInvocation.ScriptName 
$ScriptName     = ([io.fileinfo]$MyInvocation.MyCommand.Definition).BaseName
$ScriptPath     = Split-Path ($MyInvocation.mycommand.Path)
$GeneralPath    = Split-Path $scriptpath

####  Creamos HashTable con los Paths
$ConfigPaths = @{LogFolder    ="$($ScriptPath)\LOGs"; 
                ModulesFolder ="$($ScriptPath)\Modules"; 
                PathSettings  ="$($ScriptPath)\Config"}

####  Creamos HashTable con los Archivos necesarios
$ConfigFiles = @{ModuleSharePoint  = "$($ConfigPaths.ModulesFolder)\TSSharePoint\TSSharePoint.psm1"; 
                SettingsFile      = "$($ConfigPaths.PathSettings)\Settings.xml"}


 $TranscriptFile   = "$($ConfigPaths.LogFolder)\$($ScriptName)_"+(Get-Date -format "yyyyMMddHHss")+".txt"


##############################################################################################################
##  Validamos todos los paths necesarios
##############################################################################################################

####   Recorremos el HashTable con un Bucle For, y ejecutamos la función CN-Path
####   Para validar si existe el Path

foreach ($Key in $ConfigPaths.keys)
	{ 
	$Result = CN-Path $ConfigPaths[$Key]
	Write-Host "Folder$Tab$($Result[0])$Tab-->$Tab$($Result[1])" -ForegroundColor $Result[2]
	if($Result[1]-ne"Ok")
	   {
	   Write-Host "******** Suspendemos la ejecución del script." -ForegroundColor Red
	   exit
       }	
    }  
Write-Host "------------------------------------------------------------"  -ForegroundColor Green

$Null =  Start-Transcript -Path $TranscriptFile


####   Recorremos el HashTable con un Bucle For, y ejecutamos la función CN-File
####   Para validar si existe el archivo

foreach ($Key in $ConfigFiles.keys)
  { 
  $Result = CN-File $ConfigFiles[$Key]
  $file = Split-Path $Result[0] –Leaf
  $tab = 59 - $file.length

  Write-Host "File: $($File)"$Result[1].PadLeft($tab) -ForegroundColor $Result[2]
  if($Result[1]-ne"Ok")
     {
     Write-Host "******** Suspendemos la ejecución del script." -ForegroundColor Red
     exit
       }  
    }  

Write-Host "------------------------------------------------------------"  -ForegroundColor Green


import-module "$($ConfigPaths.ModulesFolder)\TSSharepoint"
Logg OK "Importamos modulo TTSharePoint..." 
Logg OK ""
Logg OK "Iniciamos Log en:    $($TranscriptFile) ..." 
Logg OK ""
Logg OK ""
 [xml]$Config = Get-Content $configfiles.SettingsFile
Logg OK "Configuración WebApplication a crear:"


##############################################################################################################
##  fin codigo comun!!!!!
##############################################################################################################


  try{

        ##############################################################################################################
        ##  Carga de variables
        ##############################################################################################################

        $WebAppSettings = @{
            Name          		        = $Config.Settings.WebAppSettings.name
            Url           		        = $Config.Settings.WebAppSettings.URL
            ApplicationPool 		      = $Config.Settings.WebAppSettings.AppPool
            ApplicationPoolAccount    = $Config.Settings.WebAppSettings.AppPoolAcc
            DatabaseServer		        = $Config.Settings.WebAppSettings.DataBaseServer
            DatabaseName		          = $Config.Settings.WebAppSettings.DataBaseName
            HostHeader 			          = $Config.Settings.WebAppSettings.HostHeader
            portalsuperuseraccount	  = $Config.Settings.WebAppSettings.portalsuperuseraccount
            portalsuperreaderaccount	= $Config.Settings.WebAppSettings.portalsuperreaderaccount
            }


	
	   $WebAppSettings

	#   $ap = New-SPAuthenticationProvider 
	#   New-SPWebApplication -Name $WebAppSettings.Name -Port 443 -SecureSocketsLayer -HostHeader $WebAppSettings.HostHeader -URL $WebAppSettings.Url -ApplicationPool $WebAppSettings.ApplicationPool -ApplicationPoolAccount (Get-SPManagedAccount $WebAppSettings.ApplicationPoolAccount) -AuthenticationProvider $ap -DatabaseServer $WebAppSettings.DatabaseServer -DatabaseName $WebAppSettings.DatabaseName 
  #   $wa = Get-SPWebApplication -Identity $WebAppSettings.Url
   #  $wa.Properties["portalsuperuseraccount"]   = $WebAppSettings.portalsuperuseraccount	
   #  $wa.Properties["portalsuperreaderaccount"] = $WebAppSettings.portalsuperreaderaccount
	 #  $wa.Update() 
    }
    
     
  Catch
    {
    Get-ErrorInformation -incomingError $_
    }


#############################################################################################################
# Get End Time
#############################################################################################################
$endDTM = (Get-Date)


$Horas    = ($endDTM-$startDTM).hours
$Minutos  = ($endDTM-$startDTM).minutes
$Segundos = "$(($endDTM-$startDTM).seconds),$(($endDTM-$startDTM).Milliseconds)"


#############################################################################################################
# Echo Time elapsed
#############################################################################################################
Write-Host ""
Write-Host "------------------------------------------------------------"  -ForegroundColor Green
Write-Host "Tiempo de Ejecucion: $(($endDTM-$startDTM).hours) Horas - $(($endDTM-$startDTM).minutes) minutos - $(($endDTM-$startDTM).seconds),$(($endDTM-$startDTM).Milliseconds) segundos" -ForegroundColor Green
Write-Host "" 
remove-module TSSharepoint
$Null = Stop-Transcript



