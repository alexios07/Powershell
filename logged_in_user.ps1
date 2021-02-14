Import-Module ActiveDirectory

$computer=read-host "Enter computer name:"
$Username=gwmi win32_computersystem -comp $computer | Select USername 
$IP=Get-ADComputer -Identity $computer -Properties IPv4Address | Select IPv4Address


Write-host "User" $Username
Write-host "IP" $IP


