$group = (read-host "group name:")
$groups = $group.split(",")

$results = foreach ($group in $groups) {
    Get-ADGroupMember $group | get-aduser -properties mail | select samaccountname,name,mail,@{n='GroupName';e={$group}}
    #,@{n='GroupName';e={$group}}, @{n='Description';e={(Get-ADGroup $group -Properties description).description}}
}

$results
