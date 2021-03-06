Import-Module ActiveDirectory

#Get-ADOrganizationalUnit –Filter “Name –eq ‘All Atomic Cartoons Staff’” -Properties ProtectedFromAccidentalDeletion | 
#Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $False 

Search-ADAccount –AccountDisabled –UsersOnly –SearchBase “OU=Production Staff, OU=All Atomic Cartoons Staff, DC=atomiccartoons,DC=net”  | 
Move-ADObject –TargetPath “OU=X-Employees, OU=All Atomic Cartoons Staff,DC=atomiccartoons,DC=net”