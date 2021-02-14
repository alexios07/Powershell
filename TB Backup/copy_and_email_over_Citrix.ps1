################## Email setup ###########################

$SMTPServer = "smtp.gmail.com"

$SMTPPort = "587"

$username = "printer@atomiccartoons.com"

$secpasswd = ConvertTo-SecureString "&D:zavuo.Sc!@#" -AsPlainText -Force

$cred = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)



################## Backup location setup##################

$netdrive = "\\client\w$"

$source = "D:\Sage 50 Backups"

$destination = "\\Client\W$\Resrc\IT\backup\thunderbird\Sage_test"

$filename = (Get-Date).tostring("dd-MM-yyyy-hh-mm-ss")

$backupfolder_name = New-Item -itemType Directory -Path $destination -Name ($filename)

$log_folder = "\\Client\W$\Resrc\IT\backup\thunderbird\Sage_test\log"

########################################################

if (Test-Path -Path $netdrive){

   Write-host "Map Drive is online"      

   $copy = Copy-Item -Path $source -Recurse -Destination $backupfolder_name -Container -ErrorAction silentlyContinue  -PassThru
   $getlog = $copy | Out-File -FilePath $log_folder\$filename.txt
       
   Send-MailMessage -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl -Credential $cred `
   -from "TB Sage Daily Backup <printer@atomiccartoons.com>" -to "Minh Tran <mtran@atomiccartoons.com>","Robert Crowther <rcrowther@atomiccartoons.com>"`
   -subject "Backup completed" -body "Network drive was online. Backup was completed successfully." `
   -Attachments "$log_folder\$filename.txt"  
}
else{
   write-host "Map Drive is offline"
   Send-MailMessage -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl -Credential $cred -from "TB Sage Daily Backup <printer@atomiccartoons.com>" -to "Minh <mtran@atomiccartoons.com>" -subject "Backup failed" -body "Network drive was not detected."
}