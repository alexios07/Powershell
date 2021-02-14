$PSEmailServer = "smtp.atomiccartoons.net"

$netdrive = "\\ac-van-prod\data\PrjData"

$source = "C:\Users\mtran\Documents\Notes"

$destination = "\\ac-van-prod\data\PrjData\Resrc\IT\backup\thunderbird\Sage_test"

$filename = (Get-Date).tostring("dd-MM-yyyy-hh-mm-ss")

if (Test-Path -Path $netdrive)
{
   Write-host "Map Drive is online"   

   $destination2 = New-Item -itemType Directory -Path $destination -Name ($filename)
   
   Copy-Item -Path $source -Recurse -Destination $destination2 -Container

   Send-MailMessage -from "Minh <test@atomiccartoons.com>" -to "Minh <mtran@atomiccartoons.com>", "Minh2 <minhtran07@gmail.com>" -subject "Map drive is online" -body "Map drive is online. Backup is completed."
}
else
{
   write-host "Map Drive is offline"
   #Send-MailMessage -from "Minh <test@atomiccartoons.com>" -to "Minh <mtran@atomiccartoons.com>", "Minh2 <minhtran07@gmail.com>" -subject "Map drive is offline" -body "Map drive is offline"
}