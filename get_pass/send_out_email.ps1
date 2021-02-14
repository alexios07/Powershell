$PSEmailServer = "smtp.atomiccartoons.net"
$day = read-host ("Day:")
Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} –Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed" | Select-Object -Property "Displayname",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed").ToShortDateString()}} | Where {$_.ExpiryDate -match ((get-date).AddDays($day)).ToShortDateString()}

$PSEmailServer = "smtp.atomiccartoons.net"
if (test-connection atomic066 -count 3 -quiet)
{
   #Write-host "Comp is online"
   Send-MailMessage -from "Minh <test@atomiccartoons.com>" -to "Minh <mtran@atomiccartoons.com>", "Minh2 <minhtran07@gmail.com>" -subject "AD test email" -body "AD test email"
}
else
{
   #write-host "comp is offline"
   Send-MailMessage -from "Minh <test@atomiccartoons.com>" -to "Minh <mtran@atomiccartoons.com>", "Minh2 <minhtran07@gmail.com>" -subject "AD test email" -body "AD test email"
}