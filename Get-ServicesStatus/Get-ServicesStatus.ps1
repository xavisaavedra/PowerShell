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

            /**
             * [$x Counter. multiplier to control the start of label writing]
             * @type {Number}
             */
            $x = 0

            foreach ($Service in $Services) {
            
                $svc = get-service $Service -ErrorAction SilentlyContinue
                $x ++

                /**
                 * [$Inicio  Y coordinates that determine where the label text will be displayed within the dialog box]
                 * @type {[Number]}
                 */
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