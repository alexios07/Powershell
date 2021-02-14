import-module activedirectory

Get-ADUser -SearchBase "OU=Production Staff,OU=All Atomic Cartoons Staff,DC=atomiccartoons,DC=net" -Filter * -properties mail | select name,mail | sort-object name |Export-Csv C:\active_production_staff.csv