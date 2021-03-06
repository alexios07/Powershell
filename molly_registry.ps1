$complist = Get-Content f:\molly.txt
$PatternSID = 'S-1-5-21-\d+-\d+\-\d+\-\d+$'
$ProfileList = gp 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' | Where-Object {$_.PSChildName -match $PatternSID}
$LoadedHives = gci Registry::HKEY_USERS | ? {$_.PSChildname -match $PatternSID} | Select @{name="SID";expression={$_.PSChildName}}
$UnloadedHives = Compare-Object $ProfileList $LoadedHives -Property SID -PassThru | Select SID, UserHive, Username


foreach ($comp in $complist){
	$PingStatus = Gwmi Win32_PingStatus -Filter "Address = '$comp'" | Select-Object StatusCode
	If ($PingStatus.StatusCode -eq 0){
    
        Write-Host "$comp responding"
        
        Set-ItemProperty -Path Registry::"HKEY_CURRENT_USER\Control Panel\Desktop\" -Name DragWidth -Value 60
        Set-ItemProperty -Path Registry::"HKEY_CURRENT_USER\Control Panel\Desktop\" -Name DragHeight -Value 60
        
        #$regPath = 'HKEY_CURRENT_USER\Control Panel\Desktop\'
        #$regPath = Registry::"HKEY_CURRENT_USER\Control Panel\Desktop\"
        #Set-ItemProperty $regPath -Name 'DragHeight' -Value 60
        
        #$regPath = 'HKCU:\Control Panel\Desktop\'
        #$regPath = Registry::"HKEY_CURRENT_USER\Control Panel\Desktop\"
        #Set-ItemProperty -path $regPath -Name 'DragWidth' -Value 60
		
	}
	else {
		Write-Host "$comp not responding"
	}
}