#$computers=Read-Host -Prompt "Enter the Name of the Computer you want to reboot"
$computers = Get-Content "C:\list\boardroom_comps.txt"

Write-host $computers "will be rebooted"
$Prompt=Read-Host -prompt "Proceed with the reboot? (Y / N)?"

If(($Prompt-eq"Y")-or($Prompt-eq"y"))
{
    $results = foreach ($computer in $computers)
    {
         If (test-connection -ComputerName $computers -count 1 -Quiet)
         {
             Write-host $computer "is online"
             Try{
                  Restart-Computer -ComputerName $computer -Force 
                  $status = "Success"
             }Catch{
                 $status= "Failed"
             }
         }
         else
         {
             $status = "Computer unreachable"
         }
         New-Object -TypeName PSObject -Property @{
        'Computer'=$computer
        'Status'=$status            
    }
}
}
$results