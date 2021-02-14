Add-Type -AssemblyName System.Windows.Forms

$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Atom Tool"
$Form.Size = New-Object System.Drawing.Size(300,250)
$Form.StartPosition = "CenterScreen"

$Form.KeyPreview = $True
$Form.Add_KeyDown({if ($_.KeyCode -eq "Enter")
{$x=$ListBox.SelectedItem;$Form.Close()}})
$Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
{$Form.Close()}})

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Size(5,5)
$label.Size = New-Object System.Drawing.Size(240,30)
$label.Text = "Input computer name:"
$Form.Controls.Add($label)

$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Location = New-Object System.Drawing.Size(5,40)
$textbox.Size = New-Object System.Drawing.Size(120,20)
#$textbox.Text = "Select source PC:"
$Form.Controls.Add($textbox)

$ping_computer_click =
{
 
$statusBar1.Text = $result_label.Text = "System Successfully Pinged""Testing..."
$ComputerName = $textbox.Text
 
if (Test-Connection $ComputerName -quiet -Count 2){
Write-Host -ForegroundColor Green "Computer $ComputerName has network connection"
$username = gwmi win32_computersystem -comp $ComputerName | Select USername

$result_label.ForeColor= "Green"
$result_label.Text = $username
#$result_label.Text = "System Successfully Pinged"
}
Else{
Write-Host -ForegroundColor Red "Computer $ComputerName does not have network connection"
$result_label.ForeColor= "Red"
$result_label.Text = "System is NOT Pingable"
} 

}

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(140,38)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click($ping_computer_click)
$Form.Controls.Add($OKButton)

$result_label = New-Object System.Windows.Forms.label
$result_label.Location = New-Object System.Drawing.Size(5,65)
$result_label.Size = New-Object System.Drawing.Size(240,30)
$result_label.Text = "Results will be listed here"
$Form.Controls.Add($result_label)

#Show form
$Form.Topmost = $True
$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()