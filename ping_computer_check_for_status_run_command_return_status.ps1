$computers = Get-Content "C:\list\computers2.txt"
#$Path = "HKEY_LOCAL_MACHINE:SYSTEM\CurrentControlSet\Services\USBSTOR"
$Path = "HKEY_LOCAL_MACHINE:SYSTEM\CurrentControlSet\Services\USBSTOR"
$Property = 'Start'
$Value = '4'

$results = foreach ($computer in $computers)
{
    If (test-connection -ComputerName $computer -Count 1 -Quiet)
    {
        Write-host $computer "is online"
        Try {
            #Set-ItemProperty -Path $Path -Name $Property -Value '4' -ErrorAction 'Stop'
            Set-ItemProperty -Path $Path -Name Start -Value '4'
            $status = "Success"
        } Catch {
            $status = "Failed"
        }
    }
    else
    {   
        $status = "Unreachable"
    }
    
    New-Object -TypeName PSObject -Property @{
        'Computer'=$computer
        'Status'=$status
    }
}

$results