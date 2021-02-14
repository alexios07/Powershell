################## Email setup ###########################

$SMTPServer = "smtp.gmail.com"

$SMTPPort = "587"

$username = "printer@atomiccartoons.com"

$secpasswd = ConvertTo-SecureString "&D:zavuo.Sc!@#" -AsPlainText -Force

$cred = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)



################## Backup location setup##################

$netdrive = "\\Client\w$"

$sage50backup_src = "D:\Sage 50 Backups"

$sage50data_src = "D:\Sage 50 Data\*"

$sage50backup_dst = "\\Client\W$\Sage_50_backups"

$sage50data_dst = "\\Client\W$\Sage_50_data"

$filename = (Get-Date).tostring("dd-MM-yyyy-hh-mm-ss")

$backupfolder = New-Item -itemType Directory -Path $sage50backup_dst -Name ($filename)

$log_folder = "\\Client\W$\Sage_50_backups\2_log"

$root_folder = "\\Client\W$\Sage_50_backups\1_root_backup\*"


########################################################

if (Test-Path -Path $netdrive){

   ############Check for logged-in users#######################

   $sage_user = Get-Process -Name Sage50Accounting -IncludeUserName | Select UserName `
   | ConvertTo-Html   -body "<b>The following users were online during the backup process:</b>"| Out-File $log_folder\users.html



   ##########Back up the Sage 50 Backups folder#######

   Write-host "Root copy is running..."
   Copy-Item -Path $root_folder -Destination $backupfolder -Recurse -Container -ErrorAction silentlyContinue

   Write-host "Robocopy is running..." 
   $copy = robocopy $sage50backup_src $backupfolder /MIR /FFT /R:3 /W:10 /Z /NP /NDL
   
   Write-host "Generating log file..."
   $getlog = $copy | Out-File -FilePath $log_folder\$filename.txt
      


   ##########Compress the Sage 50 Data folder and backup to Isilon#######

   Write-host "Compressing Sage 50 Data folder..."
   Compress-Archive -path "$sage50data_src" `
   -CompressionLevel Optimal `
   -Force `
   -DestinationPath "D:\$filename.zip"

   Write-host "Moving the compressed file to the Isilon..."
   Move-Item -Path "D:\$filename.zip" -Destination $sage50data_dst 


   ##########Delete backup folders older than 15 days#######

   Write-host "Deleting Sage 50 Backup folders older than 15 days..."
   Get-childitem -Path $sage50backup_dst `
   | Where {$_.Name -like '*-*' -and (get-date) - $_.lastwritetime -gt 15.} `
   | remove-item -recurse

   Write-host "Deleting Sage 50 Data folders older than 15 days..."
   Get-childitem -Path $sage50data_dst `
   | Where {$_.Name -like '*-*' -and (get-date) - $_.lastwritetime -gt 15.} `
   | remove-item -recurse



   ############Send email######################

   $body = [System.IO.File]::ReadAllText("$log_folder\users.html")
       
   Send-MailMessage -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl -Credential $cred `
   -from "Thunderbird Sage Daily Backup <printer@atomiccartoons.com>" -to "Atomic Cartoons IT Dept <mtran@atomiccartoons.com>"`
   -subject "Daily Backup completed" -body "Network drive was online. Backup was completed successfully. <br><br>$body" `
   -BodyAsHTML `
   -Attachments "$log_folder\$filename.txt"
}
else{
   write-host "Map Drive is offline"
   Send-MailMessage -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl -Credential $cred `
   -from "Thunderbird Sage Daily Backup <printer@atomiccartoons.com>" `
   -to "Minh <mtran@atomiccartoons.com>"`
   -subject "Daily backup failed"`
   -body "Network drive was not detected."
}