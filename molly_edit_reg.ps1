#Invoke-Command -ComputerName wds-server {Set-ItemProperty -Path Registry::"HKEY_USERs\S-1-5-21-1451675095-1370712997-3717827785-6824\Control Panel\Desktop\" -Name DragHeight -Value '15'} -ErrorAction 'Stop'

$computers= get-content "f:\molly.txt"

#$credential = Get-Credential -Credential atomiccartoons.com\mtran

foreach ($computer in $computers)
    {
    $profiles = Get-WmiObject -Class Win32_UserProfile -Computer $Computer -ea 0

        Write-Output $computers
        foreach ($profile in $profiles) {

        try {
      $objSID = New-Object System.Security.Principal.SecurityIdentifier($profile.sid)
      $objuser = $objsid.Translate([System.Security.Principal.NTAccount])
      $objusername = $objuser.value
  } catch {
        $objusername = $profile.sid
  }
    Set-ItemProperty -Path Registry::"HKEY_USERS\S-1-5-21-1451675095-1370712997-3717827785-6824\Control Panel\Desktop\" -Name DragWidth -Value '42'
    #$set = {Set-ItemProperty -Path Registry::"HKEY_USERS\$($profile.sid)\Control Panel\Desktop\" -Name DragWidth -Value '39'}
    #Invoke-Command -computername $computer -ScriptBlock {$set}

    #{Set-ItemProperty -Path Registry::"HKEY_USERS\$($profile.sid)\Control Panel\Desktop\" -Name DragWidth -Value '30'}
    #Invoke-Command -computername $computer {Set-ItemProperty -Path Registry::"HKEY_USERS\$($profile.sid)\Control Panel\Desktop\" -Name DragWidth -Value '30'}
    #Set-ItemProperty -Path Registry::"HKEY_USERS\$($objSID)\Control Panel\Desktop\" -Name DragHeight -Value '30'
    #Set-ItemProperty -Path Registry::"HKEY_USERS\S-1-5-21-1451675095-1370712997-3717827785-6824\Control Panel\Desktop\" -Name DragHeight -Value '31'
    #Invoke-Command -ComputerName $computers {Set-ItemProperty -Path Registry::"HKEY_USERS\$($objSID)\Control Panel\Desktop\" -Name DragHeight -Value '18'}
       
}
}