$Process = Get-Process CDViewer -ErrorAction SilentlyContinue

if($Process -eq $null)
{
 Write-host "Citrix connection is NOT running. Check ASAP!"

 Send-MailMessage -SmtpServer mail-01-v.atomiccartoons.net `
   -from "TBird Backup - Citrix connection disconnected <tb_backup@atomiccartoons.com>" -to "Minh Tran <mtran@atomiccartoons.com>", "Robert Crowther <rcrowther@atomiccartoons.com>" `
   -subject "Citrix connection disconnected" -body "Cannot detect an active Citrix connection on tbws13 machine!" `
}
else
{
 Write-host "Citrix connection is running."
}
