    $profiles = Get-WmiObject -Class Win32_UserProfile -ea 0

    foreach ($profile in $profiles) {
    
    try {
      $objSID = New-Object System.Security.Principal.SecurityIdentifier($profile.sid)
      $objuser = $objsid.Translate([System.Security.Principal.NTAccount])
      $objusername = $objuser.value
  } catch {
        $objusername = $profile.sid
        write-host $objSID
  }

    #write-output $profile.sid
    Invoke-Command -ScriptBlock {

    Set-ItemProperty -Path Registry::"HKEY_USERS\$($objSID)\Control Panel\Desktop\" -Name DragWidth -Value '60'
    Set-ItemProperty -Path Registry::"HKEY_USERS\$($objSID)\Control Panel\Desktop\" -Name DragHeight -Value '60'
    

}
}
