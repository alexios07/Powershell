$computers= get-content "c:\list\computers.txt"

foreach ($computer in $computers)
{
    if (test-connection $computer -count 3 -quiet)
    {
        Write-host $computer "is online"
        $result=Get-WmiObject -computername $computer -Namespace root/hp/instrumentedBIOS -Class hp_biosEnumeration `
                | select Name, Value `
                | Where {`
                $_.Name -like '*Front USB Ports*'} | format-table -autosize
        $result
    }
    else
    {
        Write-host $computer "is offline"
    }
}
