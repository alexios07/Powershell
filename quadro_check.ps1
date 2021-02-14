$computers = Get-Content "C:\list\computers2.txt"

foreach ($computer in $computers)
{
    If (test-connection -ComputerName $computer -count 1 -quiet)
    {
        get-wmiobject -ComputerName $computer win32_VideoController | select name, systemname | Where {$_.Name -like '*P4000*'}
    }
    else
    {
         write-host $computer "is offline" 
    }
}

