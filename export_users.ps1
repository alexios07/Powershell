Import-Module ActiveDirectory

$properties=@(
    'emailaddress',
    'displayname'    
    ) 

$expressions=@(   
    @{Expression={$_.DisplayName};Label="Name"},
    @{Expression={$_.EmailAddress};Label="Email"}   
    )
 
#$path_to_file = "C:\user-report_$((Get-Date).ToString('yyyy-MM-dd_hh-mm-ss')).csv"
$path_to_file = "$home/documents/atomic_active_users.csv"
 
Get-ADUser -Filter 'enabled -eq $true' -Properties $properties | select $expressions | Export-CSV $path_to_file -notypeinformation -Encoding UTF8