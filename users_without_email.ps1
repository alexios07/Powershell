import-module activedirectory
Get-ADUser -filter "enabled -eq '$true' -and mail -notlike '*'" | select name 