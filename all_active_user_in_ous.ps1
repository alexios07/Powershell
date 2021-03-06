import-module activedirectory

$ous=
"OU=Corporate,OU=All Atomic Cartoons Staff,DC=atomiccartoons,DC=net",
"OU=Production Staff,OU=All Atomic Cartoons Staff,DC=atomiccartoons,DC=net",
"OU=IT Staff,OU=All Atomic Cartoons Staff,DC=atomiccartoons,DC=net",
"OU=Line Producers,OU=All Atomic Cartoons Staff,DC=atomiccartoons,DC=net",
"OU=VPN Users,OU=All Atomic Cartoons Staff,DC=atomiccartoons,DC=net",
"OU=Production,OU=Groups,OU=All Atomic Cartoons Staff,DC=atomiccartoons,DC=net"


$ous | foreach {
    Get-ADUser -SearchBase $_ -Filter * -properties mail,description | select name,mail,description | sort-object name
} | export-csv "$home/documents/Asset Panda/Users/all_active_employees.csv" -NoTypeInformation
