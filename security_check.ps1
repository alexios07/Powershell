$computers= get-content "c:\computers.txt"


$result=Get-WmiObject -computername $computers -Namespace root/hp/instrumentedBIOS -Class hp_biosEnumeration `
| select Name, Value `
| Where {`
$_.Name -like '*Removable Media Boot*' `
-or $_.Name -like '*Front USB Ports*' `
-or $_.Name -like '*Front USB Ports*'`
-or $_.Name -like '*USB Media Boot Support*'`
-or $_.Name -like '*USB Storage Boot*'
} | format-table -autosize | out-file c:\bios.txt

