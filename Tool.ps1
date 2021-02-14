<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Untitled
#>

Add-Type -AssemblyName System.Windows.Forms
Import-Module ActiveDirectory
[System.Windows.Forms.Application]::EnableVisualStyles()

#$computer=read-host "Enter computer name:"
$LoggedInUser=gwmi win32_computersystem -computer $computer | Select USername 
$LoggedInUser_Click={
    $GetData= gwmi win32_computersystem -computer $computer | Select USername
    $label.text=$GetData
}

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '400,400'
$Form.text                       = "Atomic Tool"
$Form.TopMost                    = $false

$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $false
$TextBox1.width                  = 100
$TextBox1.height                 = 20
$TextBox1.location               = New-Object System.Drawing.Point(10,16)
$TextBox1.Font                   = 'Microsoft Sans Serif,10'

$label = New-Object system.windows.Forms.Label
$label.AutoSize = $true
$label.Width = 25
$label.Height = 10
$label.location = new-object system.drawing.size(71,89)
$label.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($label)

$Button1                         = New-Object system.Windows.Forms.Button
$button1.add_Click($LoggedInUser_Click)
$Button1.text                    = "LoggedIn"
$Button1.width                   = 60
$Button1.height                  = 30
$Button1.location                = New-Object System.Drawing.Point(10,49)
$Button1.Font                    = 'Microsoft Sans Serif,10'

$Form.controls.AddRange(@($TextBox1,$Button1))

$Button1.Add_Click({ LoggedInUser })


#$IP=Get-ADComputer -Identity $computer -Properties IPv4Address | Select IPv4Address


[void]$Form.ShowDialog()