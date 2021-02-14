Import-Module ActiveDirectory

$Max = Get-ADGroup -Properties gidNumber -Filter * | Measure-Object gidNumber -Maximum | Select-Object Maximum
[int]$MaxGroupID = $Max.Maximum
$Max = Get-ADUser -Properties uidNumber -Filter * | Measure-Object uidNumber -Maximum | Select-Object Maximum
[int]$MaxUserID = $Max.Maximum
[int]$LastIDNumber = 0
[string]$DefaultGroupID = "10000"

Write-Host "Max Group ID = $MaxGroupID"
Write-Host "Max User ID = $MaxUserID"

if ($MaxGroupID -gt $MaxUserID)
{
	$LastIDNumber = $MaxGroupID
}
elseif($MaxUserID -gt $MaxGroupID)
{
	$LastIDNumber = $MaxUserID
}

Write-Host "MaxID = $LastIDNumber"

if($LastIDNumber -gt 0)
{
	$Users = Get-ADUser -filter {Enabled -eq $True} -SearchBase "ou=All Atomic Cartoons Staff,dc=atomiccartoons,dc=net" -Properties SamAccountName,uidNumber | Select-Object SamAccountName,uidNumber
	foreach($User in $Users)
	{
		[string]$UserName = $User.SamAccountName.ToLower().Trim()
		if($UserName -ne "Administrator")
		{
			if($User.uidNumber -eq $Null)
			{
				Write-Warning "$UserName will need to be setup for Linux."
				$LastIDNumber = $LastIDNumber + 1
				[int]$Counter = 1
				$IsUIDAssigned = dsquery * domainroot -filter "(|(&(objectCategory=Person)(objectClass=User)(uidNumber=$LastIDNumber))(&(objectClass=group)(gidNumber=$LastIDNumber)))"
				# if the uid is being used, increment it until it's no longer being used
				while ($IsUIDAssigned -ne $Null)
				{
					$LastIDNumber = $LastIDNumber + 1
						
					$IsUIDAssigned = dsquery * domainroot -filter "(|(&(objectCategory=Person)(objectClass=User)(uidNumber=$LastIDNumber))(&(objectClass=group)(gidNumber=$LastIDNumber)))"
					$Counter = $Counter + 1

					if ($Counter -eq 5)
					{
						Write-Warning "Cannot get a vaild UID Number for the new users. Tried 5 times, quitting now!!"
						Exit
					}
				}
				try
				{
					Write-Host "Set-ADUser -Identity `"$UserName`" -Add @{`"loginShell`"=`"/bin/bash`";`"unixHomeDirectory`"=`"/home/$UserName`";`"gidNumber`"=`"$DefaultGroupID`";uid=`"$UserName`";`"uidNumber`"=`"$LastIDNumber`"}"
					Set-ADUser -Identity "$UserName" -Add @{"loginShell"="/bin/bash";"unixHomeDirectory"="/home/$UserName";"gidNumber"="$DefaultGroupID";uid="$UserName";"uidNumber"="$LastIDNumber"}
					#Write-Host "Add-ADGroupMember -Identity Domain Users -Members $UserName"
					#Add-ADGroupMember -Identity "Domain Users" -Members $UserName
					Write-Host "Set-ADGroup -Identity Domain Users -Add @{`"memberUid`"=`"$UserName`"}"
					Set-ADGroup -Identity "Domain Users" -Add @{"memberUid"="$UserName"}
				}
				catch
				{
					Write-Warning "Unable to set Unix attributes!!"
					Write-Warning $_.Exception.Message
					Exit
				}
				#Write-Host "Set-ADUser -Identity `"$UserName`" -Add @{`"loginShell`"=`"/bin/bash`";`"unixHomeDirectory`"=`"/home/$UserName`";`"gidNumber`"=`"$DefaultGroupID`";uid=`"$UserName`";`"uidNumber`"=`"$LastIDNumber`"}"
			}
			else
			{
				[string]$Uid = $User.uidNumber
				Write-Host "$UserName is setup for Linux with uidNumber $Uid"
			}
		}
		else
		{
			Write-Host "Skipping $UserName"
		}
	}
}
else
{
	Write-Warning "The Last ID number should be greater than 0, got $LastIDNumber"
}
