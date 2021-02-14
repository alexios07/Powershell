param([switch]$Elevated)

function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) 
    {
        # tried to elevate, did not work, aborting
    } 
    else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}

exit
}

cls
Write-Host "This tool is intended to be used directly, or as directed by, Atomic IT staff only."
$firstresponse = Read-Host -Prompt "ARE YOU SURE YOU WANT TO CONTINUE? Y/N"
	If (-Not ($firstresponse -eq "y")) {stop-process -Id $PID}

Function RoboLogGen {
                write-host "Robocopy log parser. $(if($fp){"Parsing file entries"} else {"Parsing summaries only, use -fp to parse file entries"})"
 
                #Arguments
                # -fp File parse. Counts status flags and oldest file Slower on big files.
 
                $ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew()
                $refreshrate=1 # progress counter refreshes this often when parsing files (in seconds)
 
                # These summary fields always appear in this order in a robocopy log
                $HeaderParams = @{
                    "04|Started" = "date"; 
                    "01|Source" = "string";
                    "02|Dest" = "string";
                    "03|Options" = "string";
                    "09|Dirs" = "counts";
                    "10|Files" = "counts";
                    "11|Bytes" = "counts";
                    "12|Times" = "counts";
                    "05|Ended" = "date";
                    "07|Speed" = "default";
                    "08|Speednew" = "default"
 
                }
 
                $ProcessCounts = @{
                    "Processed" = 0;
                    "Error" = 0;
                    "Incomplete" = 0
                }
 
                $tab=[char]9
 
                $files=get-childitem $SourcePath
 
                $writer=new-object System.IO.StreamWriter("C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopySummary.csv")
                function Get-Tail([object]$reader, [int]$count = 10) {
 
                    $lineCount = 0
                    [long]$pos = $reader.BaseStream.Length - 1
 
                    while($pos -gt 0)
                    {
                    $reader.BaseStream.position=$pos
 
                    # 0x0D (#13) = CR
                    # 0x0A (#10) = LF
                    if ($reader.BaseStream.ReadByte() -eq 10)
                    {
                    $lineCount++
                    if ($lineCount -ge $count) { break }
                    }
                    $pos--
                    } 
 
                    # tests for file shorter than requested tail
                    if ($lineCount -lt $count -or $pos -ge $reader.BaseStream.Length - 1) {
                    $reader.BaseStream.Position=0
                    } else {
                    # $reader.BaseStream.Position = $pos+1
                    }
 
                    $lines=@()
                    while(!$reader.EndOfStream) {
                    $lines += $reader.ReadLine()
                    }
                    return $lines
                }
 
                function Get-Top([object]$reader, [int]$count = 10)
                {
                    $lines=@()
                    $lineCount = 0
                    $reader.BaseStream.Position=0
                    while(($linecount -lt $count) -and !$reader.EndOfStream) {
                    $lineCount++
                    $lines += $reader.ReadLine()  
                    }
                    return $lines
                }
                function RemoveKey ( $name ) {
                    if ( $name -match "|") {
                    return $name.split("|")[1]
                    } else {
                    return ( $name )
                    }
                }
 
                function GetValue ( $line, $variable ) {
 
                    if ($line -like "*$variable*" -and $line -like "* : *" ) {
                    $result = $line.substring( $line.IndexOf(":")+1 )
                    return $result 
                    } else {
                    return $null
                    }
                }

                function UnBodgeDate ( $dt ) {
                    # Fixes RoboCopy botched date-times in format Sat Feb 16 00:16:49 2013
                    if ( $dt -match ".{3} .{3} \d{2} \d{2}:\d{2}:\d{2} \d{4}" ) {
                    $dt=$dt.split(" ")
                    $dt=$dt[2],$dt[1],$dt[4],$dt[3]
                    $dt -join " "
                    }
                    if ( $dt -as [DateTime] ) {
                    return ([DateTime]$dt).ToString("dd/MM/yyyy hh:mm:ss")
                    } else {
                    return $null
                    }
                }
                function UnpackParams ($params ) {
                    # Unpacks file count bloc in the format
                    # Dirs :      1827         0      1827         0         0         0
                    # Files :      9791         0      9791         0         0         0
                    # Bytes :  165.24 m         0  165.24 m         0         0         0
                    # Times :   1:11:23   0:00:00                       0:00:00   1:11:23
                    # Parameter name already removed
 
                    if ( $params.length -ge 58 ) {
                    $params = $params.ToCharArray()
                    $result=(0..5)
                    for ( $i = 0; $i -le 5; $i++ ) {
                    $result[$i]=$($params[$($i*10 + 1) .. $($i*10 + 9)] -join "").trim()
                    }
                    $result=$result -join ","
                    } else {
                    $result = ",,,,,"
                    }
                    return $result
                }
 
                $sourcecount = 0
                $targetcount = 1
 
                # Write the header line
                $writer.Write("File")
                foreach ( $HeaderParam in $HeaderParams.GetEnumerator() | Sort-Object Name ) {
                    if ( $HeaderParam.value -eq "counts" ) {
                    $tmp="~ Total,~ Copied,~ Skipped,~ Mismatch,~ Failed,~ Extras"
                    $tmp=$tmp.replace("~","$(removekey $headerparam.name)")
                    $writer.write(",$($tmp)")
                    } else {
                    $writer.write(",$(removekey $HeaderParam.name)")
                    }
                }
 
                if($fp){
                    $writer.write(",Scanned,Newest,Summary")
                }
 
                $writer.WriteLine()
 
                $filecount=0
 
                # Enumerate the files
                foreach ($file in $files) {  
                    $filecount++
                    write-host "$filecount/$($files.count) $($file.name) ($($file.length) bytes)"
                    $results=@{}
                $Stream = $file.Open([System.IO.FileMode]::Open, 
                                    [System.IO.FileAccess]::Read, 
                                    [System.IO.FileShare]::ReadWrite) 
                    $reader = New-Object System.IO.StreamReader($Stream) 
                    #$filestream=new-object -typename System.IO.StreamReader -argumentlist $file, $true, [System.IO.FileAccess]::Read
 
                    $HeaderFooter = Get-Top $reader 16
 
                    if ( $HeaderFooter -match "ROBOCOPY     ::     Robust File Copy for Windows" ) {
                    if ( $HeaderFooter -match "Files : " ) {
                    $HeaderFooter = $HeaderFooter -notmatch "Files : "
                    }
 
                    [long]$ReaderEndHeader=$reader.BaseStream.position
 
                    $Footer = Get-Tail $reader 16
 
                    $ErrorFooter = $Footer -match "ERROR \d \(0x000000\d\d\) Accessing Source Directory"
                    if ($ErrorFooter) {
                    $ProcessCounts["Error"]++
                    write-host -foregroundcolor red "`t $ErrorFooter"
                    } elseif ( $footer -match "---------------" ) {
                    $ProcessCounts["Processed"]++
                    $i=$Footer.count
                    while ( !($Footer[$i] -like "*----------------------*") -or $i -lt 1 ) { $i-- }
                    $Footer=$Footer[$i..$Footer.Count]
                    $HeaderFooter+=$Footer
                    } else {
                    $ProcessCounts["Incomplete"]++
                    write-host -foregroundcolor yellow "`t Log file $file is missing the footer and may be incomplete"
                    }
 
                    foreach ( $HeaderParam in $headerparams.GetEnumerator() | Sort-Object Name ) {
                    $name = "$(removekey $HeaderParam.Name)"
                                        if ($name -eq "speed"){ #handle two speed
                        
                                        ($HeaderFooter -match "$name : ")|foreach{
                                            $tmp=GetValue $_ "speed"
                                            $results[$name] = $tmp.trim()
                                            $name+="new"}
                                                                }
                                        elseif ($name -eq "speednew"){} #handle two speed
　　　　　　　　　　　　　　　　
                                        else{
                    $tmp = GetValue $($HeaderFooter -match "$name : ") $name
                    if ( $tmp -ne "" -and $tmp -ne $null ) {
                    switch ( $HeaderParam.value ) {
                        "date" { $results[$name]=UnBodgeDate $tmp.trim() }
                        "counts" { $results[$name]=UnpackParams $tmp }
     
                        "string" { $results[$name] = """$($tmp.trim())""" }  
                        default { $results[$name] = $tmp.trim() }  
                    }
                    }      
                                                }
                    }
 
                    if ( $fp ) {
                    write-host "Parsing $($reader.BaseStream.Length) bytes"
                    # Now go through the file line by line
                    $reader.BaseStream.Position=0
                    $filesdone = $false
                    $linenumber=0
                    $FileResults=@{}
                    $newest=[datetime]"1/1/1900"
                    $linecount++
                    $firsttick=$elapsedtime.elapsed.TotalSeconds
                    $tick=$firsttick+$refreshrate
                    $LastLineLength=1
 
                    try {
                    do {
                        $line = $reader.ReadLine()
                        $linenumber++
                        if (($line -eq "-------------------------------------------------------------------------------" -and $linenumber -gt 16)  ) { 
                        # line is end of job
                        $filesdone=$true
                        } elseif ($linenumber -gt 16 -and $line -gt "" ) {
                        $buckets=$line.split($tab)
 
                        # this test will pass if the line is a file, fail if a directory
                        if ( $buckets.count -gt 3 ) {
                        $status=$buckets[1].trim()
                        $FileResults["$status"]++
 
                        $SizeDateTime=$buckets[3].trim()
                        if ($sizedatetime.length -gt 19 ) {
                        $DateTime = $sizedatetime.substring($sizedatetime.length -19)
                        if ( $DateTime -as [DateTime] ){
                            $DateTimeValue=[datetime]$DateTime
                            if ( $DateTimeValue -gt $newest ) { $newest = $DateTimeValue }
                        }
                        }
                        }
                        }
 
                        if ( $elapsedtime.elapsed.TotalSeconds -gt $tick ) {
                        $line=$line.Trim()
                        if ( $line.Length -gt 48 ) {
                        $line="[...]"+$line.substring($line.Length-48)
                        }
                        $line="$([char]13)Parsing > $($linenumber) ($(($reader.BaseStream.Position/$reader.BaseStream.length).tostring("P1"))) - $line"
                        write-host $line.PadRight($LastLineLength) -NoNewLine
                        $LastLineLength = $line.length
                        $tick=$tick+$refreshrate      
                        }
                    } until ($filesdone -or $reader.endofstream)
                    }
                    finally {
                    $reader.Close()
                    }
 
                    $line=$($([string][char]13)).padright($lastlinelength)+$([char]13)
                    write-host $line -NoNewLine
                    }
 
                    $writer.Write("`"$file`"")
                    foreach ( $HeaderParam in $HeaderParams.GetEnumerator() | Sort-Object Name ) {
                    $name = "$(removekey $HeaderParam.Name)"
                    if ( $results[$name] ) {
                    $writer.Write(",$($results[$name])")
                    } else {
                    if ( $ErrorFooter ) {
                        #placeholder
                    } elseif ( $HeaderParam.Value -eq "counts" ) {
                        $writer.Write(",,,,,,") 
                    } else {
                        $writer.Write(",") 
                    }
                    }
                    }
 
                    if ( $ErrorFooter ) {
                    $tmp = $($ErrorFooter -join "").substring(20)
                    $tmp=$tmp.substring(0,$tmp.indexof(")")+1)+","+$tmp
                    $writer.write(",,$tmp")
                    } elseif ( $fp ) {
                    $writer.write(",$LineCount,$($newest.ToString('dd/MM/yyyy hh:mm:ss'))")   
                    foreach ( $FileResult in $FileResults.GetEnumerator() ) {
                    $writer.write(",$($FileResult.Name): $($FileResult.Value);")
                    }
                    }
 
                    $writer.WriteLine()
 
                    } else {
                    write-host -foregroundcolor darkgray "$($file.name) is not recognised as a RoboCopy log file"
                    }
                }
                $writer.close()
}

function mainMenu {
    $mainMenu = 'X'
    while($mainMenu -ne ''){
        Clear-Host
        Write-Host "`n AtomicTool`n"
        Write-Host -ForegroundColor Cyan "Main Menu"
        Write-Host
        Write-Host "1. Main Functions"
        Write-Host "2. Data Backup Functions"
        Write-Host "3. Links"
        $mainMenu = Read-Host "`nSelection (leave blank to quit)"
        # Launch submenu1
        if($mainMenu -eq 1){
            subMenu1
        }
        # Launch submenu2
        if($mainMenu -eq 2){
            subMenu2
        }
		# Launch submenu3
        if($mainMenu -eq 3){
            subMenu3
        }
    }
}

function subMenu1 {
    $subMenu1 = 'X'
    while($subMenu1 -ne ''){
        cls
        Write-Host "Main Functions"
        Write-Host
        Write-Host "1. Drive Cleanup"
        Write-Host "2. DirectAccess Cert/Client Reinstall"
        Write-Host "3. Clear SCCM Jobs"
        Write-Host "4. Remove TLM"
        Write-Host "5. Show BIOS Version"
        Write-Host "6. Fix Office Permissions"
        Write-Host "7. Suspend BitLocker"
	    Write-Host "8. Get IPConfig Info"
	    Write-Host "9. Reset SAP Homepage"
	    Write-Host "10. BSOD Log File Collection"
	    Write-Host "11. Start Office 365 Update"
        Write-Host "12. Credential Manager Fix"
        #Write-Host "13. Set Power Profile to High Performance"

        $subMenu1 = Read-Host "`nSelection (leave blank to quit)"
        # Option 1
        if($subMenu1 -eq 1){
                cls
                ipconfig /flushdns
				W32tm /resync /force
                ie4uinit.exe -show
                taskkill /f /im Spotify.exe
                cmd /c %appdata%\Spotify\Spotify.exe /uninstall /silent
                RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8
                cmd /c vssadmin.exe delete shadows /for=c: /all /quiet
                powercfg -h off
				cleanmgr /autoclean
                net stop ccmexec
                net stop wuauserv
                net stop bits
                del -path "$env:windir\SoftwareDistribution\DataStore\" -force -recurse -ErrorAction SilentlyContinue
                del -path "$env:windir\SoftwareDistribution\Download\" -force -recurse -ErrorAction SilentlyContinue
                net start bits
                net start wuauserv
                net start ccmexec
                del -path $env:Userprofile\AppData\Roaming\Spotify -force -ErrorAction SilentlyContinue
                del -path $env:Userprofile\AppData\LocalLow\Sun\Java\Deployment\cache -force -recurse -ErrorAction SilentlyContinue
                del -path $env:Userprofile\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache2\entries -force -recurse -ErrorAction SilentlyContinue
                del -path $env:Userprofile\AppData\Local\Mozilla\Firefox\Profiles\*.default\thumbnails -force -recurse -ErrorAction SilentlyContinue
                del -path "$env:Userprofile\AppData\Local\Google\Chrome\User Data\Default\Cache" -force -recurse -ErrorAction SilentlyContinue
                del -path "$env:Userprofile\AppData\Local\Google\Chrome\User Data\Default\Media Cache" -force -recurse -ErrorAction SilentlyContinue
                del -path $env:Temp -force -recurse -ErrorAction SilentlyContinue
                del -path $env:Windir\Temp -force -recurse -ErrorAction SilentlyContinue
        }
        # Option 2
        if($subMenu1 -eq 2){
                cls
                Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Issuer -match 'SAP Global Sub CA 04' } | Remove-Item
                \\dewdfnls01.wdf.global.corp.sap\kickstart\files\prep.bat
            [void][System.Console]::ReadKey($true)
        }
        # Option 3
        if($subMenu1 -eq 3){
                cls
                $a = Get-WmiObject -Query "select * from CCM_ExecutionRequestEx" -Namespace root\ccm\softmgmtagent
                $a | Remove-WmiObject
                Write-Host "Clear pending SCCM jobs complete!"
                net stop ccmexec
                net start ccmexec
            [void][System.Console]::ReadKey($true)
        }
        # Option 4
        if($subMenu1 -eq 4){
                cls
                taskkill /f /im agent.exe
                taskkill /f /im ConnectedAgent.exe
                net stop AgentService
                pause
                wmic.exe /interactive:off product where "name like 'Connected Backup/PC Agent%'" call uninstall
            [void][System.Console]::ReadKey($true)
        }
        # Option 5
        if($subMenu1 -eq 5){
                Get-WmiObject win32_bios
            [void][System.Console]::ReadKey($true)
        }
        # Option 6
        if($subMenu1 -eq 6){
                $Acl = Get-Acl "C:\ProgramData\Microsoft"

                $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
                $Ar2 = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
                $Ar3 = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow")
                $Ar4 = New-Object System.Security.AccessControl.FileSystemAccessRule("Users", "ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow")

                $Acl.SetAccessRule($Ar)
                $Acl.SetAccessRule($Ar2)
                $Acl.SetAccessRule($Ar3)
                $Acl.SetAccessRule($Ar4)

                Set-Acl "C:\ProgramData\Microsoft" $Acl 
                Write-Host "Permissions on folder 'C:\ProgramData\Microsoft' have been repaired."
            [void][System.Console]::ReadKey($true)
        }
        # Option 7
        if($subMenu1 -eq 7){
                Suspend-BitLocker -MountPoint C: -RebootCount 1
            [void][System.Console]::ReadKey($true)
        }
        # Option 8
        if($subMenu1 -eq 8){
				ipconfig /all > "$env:Userprofile\Desktop\IPConfigInfo.txt"
				Write-Host "IP Configuration info written to $env:Userprofile\Desktop\IPConfigInfo.txt"
            [void][System.Console]::ReadKey($true)
        }
        # Option 9
        if($subMenu1 -eq 9){
				 Set-ItemProperty -Path "HKCU:\Software\Microsoft\Internet Explorer\Main" -Name "Start Page" -value "https://portal.wdf.sap.corp/irj/portal"
				 Set-ItemProperty -Path "HKCU:\Software\Microsoft\Internet Explorer\Main" -Name "Default_Page_URL" -value "https://portal.wdf.sap.corp/irj/portal"
				 Write-Host "Home Page reset successfully!"
            [void][System.Console]::ReadKey($true)
        }
        # Option 10
        if($subMenu1 -eq 10){
				 Invoke-Expression "\\vanlabsit\BSODDumps\bsodcollect.ps1"
            [void][System.Console]::ReadKey($true)
        }
        # Option 11
        if($subMenu1 -eq 11){
                Start-Process -FilePath "$env:CommonProgramFiles\microsoft shared\ClickToRun\OfficeC2RClient.exe" -ArgumentList "/update user updatepromptuser=False forceappshutdown=True displaylevel=True"
            [void][System.Console]::ReadKey($true)
        }
        # Option 12
        if($subMenu1 -eq 12){
        $delete = "/delete /tn 'Credmanager'"
        cmdkey /delete portal.wdf.sap.corp
        cmdkey /delete cmp.wdf.sap.corp
        cmdkey /delete community.wdf.sap.corp
        cmdkey /delete cxy.wdf.sap.corp
        cmdkey /delete documents.wdf.sap.corp
        cmdkey /delete itdirect.wdf.sap.corp
        cmdkey /delete share.sap.com
        cmdkey /delete support.wdf.sap.corp
        cmdkey /delete wiki.wdf.sap.corp
        Unregister-ScheduledTask -TaskName Credmanager -Confirm
        Register-ScheduledTask -Xml (Get-Content “$PSScriptRoot\Support\credmanager.xml” | out-string) -TaskName "Credmanager" -User "$env:USERDOMAIN\$env:username"
        Start-ScheduledTask -TaskName Credmanager
        Write-Host "A reboot is required before these settings will take effect. Please reboot your computer."
        pause
        }
        # Option 13
        if($SubMenu1 -eq 13){
        $powerPlan = Get-WmiObject -Namespace root\cimv2\power -Class Win32_PowerPlan -Filter "ElementName = 'Balanced'"
        $powerPlan.Activate
        }
        # Option 98
        if($subMenu1 -eq 2){
				 Dism /Online /Cleanup-Image /RestoreHealth
				 sfc /scannow
        }
        # Option 99
        if($subMenu1 -eq 99){
				 $scrub = ('automount scrub')
				 $amdisable = ('automount disable')
				 $amenable = ('automount enable')
				 $scrub | diskpart
				 $amdisable | diskpart
				 pause
				 $amenable | diskpart
        }

    }
}

function subMenu2 {
    $subMenu2 = 'X'
    while($subMenu2 -ne ''){
    Clear-Host
    Write-Host "Backup Menu"
    Write-Host
    Write-Host "1. OneDrive Backup"
	Write-Host "2. OneDrive Backup À la carte"
    Write-Host "3. Local Backup"
	Write-Host "4. Local Backup À la carte"
	Write-Host "5. Sanitize OneDrive File Names"

    $subMenu2 = Read-Host "`nSelection (leave blank to return to the previous menu)"
        # Option 1
        if($subMenu2 -eq 1){
                Write-Host "This script will force all open instances of Outlook, Chrome, Firefox, and Internet Explorer to close immediately."
                Write-Host "Please ensure the user no longer requires these programs to be running before you continue."
                pause
				#Stop processes that will interfere with the cleanup
                Stop-Process -processname Outlook -ErrorAction SilentlyContinue
                Stop-Process -processname Chrome -ErrorAction SilentlyContinue
                Stop-Process -processname Firefox -ErrorAction SilentlyContinue
                Stop-Process -processname iexplore -ErrorAction SilentlyContinue

                RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8
                cmd /c vssadmin delete shadows /for=c: /all /quiet
                powercfg -h off
                del -path "$env:Userprofile\AppData\Roaming\Spotify" -force -ErrorAction SilentlyContinue
                del -path "$env:Userprofile\AppData\LocalLow\Sun\Java\Deployment\cache\" -force -recurse -ErrorAction SilentlyContinue
                del -path "$env:Userprofile\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache2\entries" -force -recurse -ErrorAction SilentlyContinue
                del -path "$env:Userprofile\AppData\Local\Mozilla\Firefox\Profiles\*.default\thumbnails" -force -recurse -ErrorAction SilentlyContinue
                del -path "$env:Userprofile\AppData\Local\Google\Chrome\User Data\Default\Cache\" -force -recurse -ErrorAction SilentlyContinue
                del -path "$env:Userprofile\AppData\Local\Google\Chrome\User Data\Default\Media Cache\" -force -recurse -ErrorAction SilentlyContinue
                del -path "$env:Temp\" -force -recurse -ErrorAction SilentlyContinue
                del -path "$env:Windir\Temp\" -force -recurse -ErrorAction SilentlyContinue

				#Create directory in C:\Temp to store log files
                md "C:\Temp\$ENV:Username\" -ErrorAction SilentlyContinue
                $ReferenceFilePath = "C:\Temp\$ENV:Username\FileStructureEval.txt"
				$FFPathResult = (Test-Path "$ENV:userprofile\AppData\Roaming\Mozilla\Firefox\Profiles\*.default")
				$FFPath = (Resolve-Path "$ENV:userprofile\AppData\Roaming\Mozilla\Firefox\Profiles\*.default" -ErrorAction SilentlyContinue)
                Get-ChildItem -Force -Path $ENV:userprofile\Appdata\Roaming\Microsoft\Signatures\ -Recurse -ErrorAction SilentlyContinue | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -ErrorAction SilentlyContinue
                Get-ChildItem -Force -Path $ENV:userprofile\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
                Get-ChildItem -Force -Path $ENV:userprofile\AppData\Roaming\SAP\Common\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
				Get-ChildItem -Force -Path "$ENV:userprofile\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\" -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
                Get-ChildItem -Force -Path $ENV:userprofile\Desktop\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
                Get-ChildItem -Force -Path $ENV:userprofile\Documents\ -Recurse -ErrorAction SilentlyContinue | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
                Get-ChildItem -Force -Path $ENV:userprofile\Favorites\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
                Get-ChildItem -Force -Path $ENV:userprofile\Downloads\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
                Get-ChildItem -Force -Path $ENV:userprofile\Pictures\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
                Get-ChildItem -Force -Path $ENV:userprofile\Music\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
                Get-ChildItem -Force -Path $ENV:userprofile\Videos\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
                Get-ChildItem -Force -Path "$ENV:userprofile\AppData\Local\Google\Chrome\User Data\Default" -Recurse -ErrorAction SilentlyContinue | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
                If ($FFPathResult -eq $True) {
				Get-ChildItem -Force -Path $FFPath | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append
				}

                $folder = Read-Host -Prompt "Enter the folder name for the OneDrive backup"

				reg export HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband "$ENV:userprofile\OneDrive - SAP SE\PinnedTaskbarItems.reg"
                reg export HKCU\Network "$ENV:userprofile\OneDrive - SAP SE\MappedDrives.reg"
                Stop-Process -processname "Microsoft.StickyNotes" -ErrorAction SilentlyContinue
                Stop-Process -processname "Microsoft.Notes" -ErrorAction SilentlyContinue
                robocopy "$ENV:userprofile\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState" "$ENV:userprofile\OneDrive - SAP SE\$folder\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyStickyNotes.log
                robocopy "$ENV:userprofile\Appdata\Roaming\Microsoft\Signatures\" "$ENV:userprofile\OneDrive - SAP SE\$folder\AppData\Roaming\Microsoft\Signatures" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopySig.log 
				robocopy "$ENV:userprofile\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch" "$ENV:userprofile\OneDrive - SAP SE\$folder\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyQL.log
                robocopy "$ENV:userprofile\AppData\Roaming\SAP\Common" "$ENV:userprofile\OneDrive - SAP SE\$folder\AppData\Roaming\SAP\Common" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyCommon.log 
                robocopy "$ENV:userprofile\Desktop" "$ENV:userprofile\OneDrive - SAP SE\$folder\Desktop" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyDesktop.log
                Stop-Process -processname Outlook -ErrorAction SilentlyContinue
                robocopy "$ENV:userprofile\Documents" "$ENV:userprofile\OneDrive - SAP SE\$folder\Documents" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyDocuments.log 
                robocopy "$ENV:userprofile\Favorites" "$ENV:userprofile\OneDrive - SAP SE\$folder\Favorites" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyFavorites.log 
                robocopy "$ENV:userprofile\Downloads" "$ENV:userprofile\OneDrive - SAP SE\$folder\Downloads" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyDownloads.log 
                robocopy "$ENV:userprofile\Music" "$ENV:userprofile\OneDrive - SAP SE\$folder\Music" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyMusic.log 
                robocopy "$ENV:userprofile\Pictures" "$ENV:userprofile\OneDrive - SAP SE\$folder\Pictures" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyPictures.log 
                robocopy "$ENV:userprofile\Videos" "$ENV:userprofile\OneDrive - SAP SE\$folder\Videos" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyVideo.log 
                Stop-Process -processname Chrome -ErrorAction SilentlyContinue
                Stop-Process -processname iexplore -ErrorAction SilentlyContinue
                robocopy "$ENV:userprofile\AppData\Local\Google\Chrome\User Data\Default" "$ENV:userprofile\OneDrive - SAP SE\$folder\AppData\Local\Google\Chrome\User Data\Default" /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyChrome.log 
				Remove-Item -Path "$ENV:userprofile\OneDrive - SAP SE\$folder\AppData\Local\Google\Chrome\User Data\Default" -Exclude Bookmarks -Force -Recurse -ErrorAction SilentlyContinue
                Stop-Process -processname Firefox -ErrorAction SilentlyContinue
                del -path "$env:Userprofile\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache2\entries\" -force -recurse
                del -path "$env:Userprofile\AppData\Local\Mozilla\Firefox\Profiles\*.default\thumbnails\" -force -recurse
                robocopy $FFPath "$ENV:userprofile\OneDrive - SAP SE\$folder\AppData\Roaming\Mozilla\Firefox\Profiles" /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyFirefox.log 
				Remove-Item -Path "$ENV:userprofile\OneDrive - SAP SE\$folder\AppData\Roaming\Mozilla\Firefox\Profiles" -Exclude places.sqlite -Force -Recurse -ErrorAction SilentlyContinue

                Write-Host "This script will now begin removing invalid characters from the name of every file under your 'OneDrive - SAP SE' folder. No further status will be shown."
                Write-Host "Note: The backup of your mapped network shares has been placed in the root of the 'OneDrive - SAP SE' folder as 'MappedDrives.reg'. Double click this file to import, and then restart the computer."

				$SourcePath="C:\Temp\$ENV:Username\" #robocopy log file
				RoboLogGen
				
                Get-ChildItem "$ENV:userprofile\OneDrive - SAP SE\$folder" -Recurse | rename-item -newname { $_.name -replace '#','' } -ErrorAction SilentlyContinue
                Get-ChildItem "$ENV:userprofile\OneDrive - SAP SE\$folder" -Recurse | rename-item -newname { $_.name -replace '%','' } -ErrorAction SilentlyContinue
                Get-ChildItem "$ENV:userprofile\OneDrive - SAP SE\$folder" -Recurse | rename-item -newname { $_.name -replace '.pst', '.pstbackup' } -ErrorAction SilentlyContinue

                #write-host "$filecount files scanned in $($elapsedtime.elapsed.tostring()), $($ProcessCounts["Processed"]) complete, $($ProcessCounts["Error"]) have errors, $($ProcessCounts["Incomplete"]) incomplete"
                #write-host  "Results written to $($writer.basestream.name)"

                md "\\vanlabsit\vanlabsit\CopyLogs\$ENV:Username"
                md "\\10.161.8.45\vanlabsit\CopyLogs\$ENV:Username"
                Copy-Item "C:\Temp\$ENV:Username\" "\\vanlabsit\vanlabsit\CopyLogs" -force -recurse
                Copy-Item "C:\Temp\$ENV:Username\" "\\10.161.8.45\vanlabsit\CopyLogs\$ENV:Username" -force -recurse
                Write-Host "Script complete. This window will close upon pressing Enter."
            [void][System.Console]::ReadKey($true)
        }
		# Option 2
		if($subMenu2 -eq 2){
				ODMenusub1
				}
        # Option 3
        if($subMenu2 -eq 3){
                Write-Host "This script will force all open instances of Outlook, Chrome, Firefox, and Internet Explorer to close immediately."
                Write-Host "Please ensure the user no longer requires these programs to be running before you continue."
                pause
                Stop-Process -processname Outlook -ErrorAction SilentlyContinue
                Stop-Process -processname Chrome -ErrorAction SilentlyContinue
                Stop-Process -processname Firefox -ErrorAction SilentlyContinue
                Stop-Process -processname iexplore -ErrorAction SilentlyContinue
                RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8
                cmd /c vssadmin delete shadows /for=c: /all /quiet
                powercfg -h off
                del -path "$env:Userprofile\AppData\Roaming\Spotify" -force -ErrorAction SilentlyContinue
                del -path "$env:Userprofile\AppData\LocalLow\Sun\Java\Deployment\cache\" -force -recurse -ErrorAction SilentlyContinue
                del -path "$env:Userprofile\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache2\entries" -force -recurse -ErrorAction SilentlyContinue
                del -path "$env:Userprofile\AppData\Local\Mozilla\Firefox\Profiles\*.default\thumbnails" -force -recurse -ErrorAction SilentlyContinue
                del -path "$env:Userprofile\AppData\Local\Google\Chrome\User Data\Default\Cache\" -force -recurse -ErrorAction SilentlyContinue
                del -path "$env:Userprofile\AppData\Local\Google\Chrome\User Data\Default\Media Cache\" -force -recurse -ErrorAction SilentlyContinue
                del -path "$env:Temp\" -force -recurse -ErrorAction SilentlyContinue
                del -path "$env:Windir\Temp\" -force -recurse -ErrorAction SilentlyContinue
                md C:\Temp\$ENV:Username\ -ErrorAction SilentlyContinue
                $ReferenceFilePath = "C:\Temp\$ENV:Username\FileStructureEval.txt"
				$FFPathResult = (Test-Path "$ENV:userprofile\AppData\Roaming\Mozilla\Firefox\Profiles\*.default")
				$FFPath = (Resolve-Path "$ENV:userprofile\AppData\Roaming\Mozilla\Firefox\Profiles\*.default" -ErrorAction SilentlyContinue)
				
                Get-ChildItem -Force -Path $ENV:userprofile\Appdata\Roaming\Microsoft\Signatures\ -Recurse -ErrorAction SilentlyContinue | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath
				Get-ChildItem -Force -Path "$ENV:userprofile\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\" -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
				Get-ChildItem -Force -Path $ENV:userprofile\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
                Get-ChildItem -Force -Path $ENV:userprofile\Desktop\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
                Get-ChildItem -Force -Path $ENV:userprofile\Documents\ -Recurse -ErrorAction SilentlyContinue | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
                Get-ChildItem -Force -Path $ENV:userprofile\Favorites\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
                Get-ChildItem -Force -Path $ENV:userprofile\Downloads\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
                Get-ChildItem -Force -Path $ENV:userprofile\Pictures\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
                Get-ChildItem -Force -Path $ENV:userprofile\Music\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
                Get-ChildItem -Force -Path $ENV:userprofile\Videos\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
                Get-ChildItem -Force -Path "$ENV:userprofile\AppData\Local\Google\Chrome\User Data\Default" -Recurse -ErrorAction SilentlyContinue | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append
                If ($FFPathResult -eq $True) {
				Get-ChildItem -Force -Path $FFPath | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append
				}
                $drive = Read-Host -Prompt "Enter a drive letter (please include a : - e.g. 'D:')"

                md $drive\$ENV:username -ErrorAction SilentlyContinue
                reg export HKCU\Network "$drive\$ENV:username\MappedDrives.reg"
				reg export HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband "$drive\$ENV:username\PinnedTaskbarItems.reg"
                Stop-Process -processname "Microsoft.StickyNotes" -ErrorAction SilentlyContinue
                robocopy "$ENV:userprofile\Appdata\Roaming\Microsoft\Signatures\" "$drive\$ENV:username\AppData\Roaming\Microsoft\Signatures" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopySig.log
                robocopy "$ENV:userprofile\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState" "$drive\$ENV:username\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyStickyNotes.log
				robocopy "$ENV:userprofile\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch" "$drive\$ENV:username\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyQL.log
                robocopy "$ENV:userprofile\AppData\Roaming\SAP\Common" "$drive\$ENV:username\AppData\Roaming\SAP\Common" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyCommon.log 
                robocopy "$ENV:userprofile\Desktop" "$drive\$ENV:username\Desktop" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyDesktop.log
                Stop-Process -processname Outlook -ErrorAction SilentlyContinue
                robocopy "$ENV:userprofile\Documents" "$drive\$ENV:username\Documents" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyDocuments.log 
                robocopy "$ENV:userprofile\Favorites" "$drive\$ENV:username\Favorites" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyFavorites.log 
                robocopy "$ENV:userprofile\Downloads" "$drive\$ENV:username\Downloads" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyDownloads.log 
                robocopy "$ENV:userprofile\Music" "$drive\$ENV:username\Music" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyMusic.log 
                robocopy "$ENV:userprofile\Pictures" "$drive\$ENV:username\Pictures" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyPictures.log 
                robocopy "$ENV:userprofile\Videos" "$drive\$ENV:username\Videos" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyVideo.log 
                Stop-Process -processname Chrome -ErrorAction SilentlyContinue
                Stop-Process -processname iexplore -ErrorAction SilentlyContinue
                robocopy "$ENV:userprofile\AppData\Local\Google\Chrome\User Data\Default" "$drive\$ENV:username\AppData\Local\Google\Chrome\User Data\Default"  /J /W:1 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyChrome.log
				Remove-Item -Path "$drive\$ENV:username\AppData\Local\Google\Chrome\User Data\Default" -Exclude Bookmarks -Force -Recurse -ErrorAction SilentlyContinue
                Stop-Process -processname Firefox -ErrorAction SilentlyContinue
                robocopy "$FFPath" "$drive\$ENV:username\AppData\Roaming\Mozilla\Firefox" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyFirefox.log 
				Remove-Item -Path "$drive\$ENV:username\AppData\Roaming\Mozilla\Firefox" -Exclude places.sqlite -Force -Recurse -ErrorAction SilentlyContinue

                $SourcePath="C:\Temp\$ENV:Username\" #robocopy log file
				RoboLogGen

                Get-ChildItem "$drive\$ENV:username" -Recurse | rename-item -newname { $_.name -replace '#','' } -ErrorAction SilentlyContinue
                Get-ChildItem "$drive\$ENV:username" -Recurse | rename-item -newname { $_.name -replace '%','' } -ErrorAction SilentlyContinue
                Get-ChildItem "$drive\$ENV:username" -Recurse | rename-item -newname { $_.name -replace '.pst', '.itpstbackup' } -ErrorAction SilentlyContinue

                #write-host "$filecount files scanned in $($elapsedtime.elapsed.tostring()), $($ProcessCounts["Processed"]) complete, $($ProcessCounts["Error"]) have errors, $($ProcessCounts["Incomplete"]) incomplete"
                #write-host  "Results written to $($writer.basestream.name)"

                md "\\vanlabsit\vanlabsit\CopyLogs\$ENV:Username"
                Copy-Item "C:\Temp\$ENV:Username\*" "\\vanlabsit\vanlabsit\CopyLogs\$ENV:Username\"
                Write-Host "Script complete. This window will close upon pressing Enter."
		}
		# Option 4
		if($subMenu2 -eq 4){
				LocalMenusub1
				}
		# Option 5
        if($subMenu2 -eq 5){
                $ProcessActive = Get-Process onedrive -ErrorAction SilentlyContinue
                Stop-Process -processname Outlook -ErrorAction SilentlyContinue
                if($ProcessActive -eq $null)
                {
                Write-Host "OneDrive process is not running. This script will now exit."
                pause
                stop-process -Id $PID
                }
                else
                {
                Write-Host "This script will now begin removing invalid characters from the name of every file under your 'OneDrive - SAP SE' folder. No further status will be shown."
                Get-ChildItem "$ENV:userprofile\OneDrive - SAP SE\" -Recurse | rename-item -newname { $_.name -replace '#','' } -ErrorAction SilentlyContinue
                Get-ChildItem "$ENV:userprofile\OneDrive - SAP SE\" -Recurse | rename-item -newname { $_.name -replace '%','' } -ErrorAction SilentlyContinue
                Get-ChildItem "$ENV:userprofile\OneDrive - SAP SE\" -Recurse | rename-item -newname { $_.name -replace '.pst', '.pstbackup' } -ErrorAction SilentlyContinue
                Write-Host "Script complete. This window will close upon pressing Enter."
            [void][System.Console]::ReadKey($true)
        }
        }
        }
}

function ODMenusub1 {
    $ODMenusub1 = 'X'
        while($ODMenusub1 -ne ''){

        Stop-Process -processname Outlook -ErrorAction SilentlyContinue
        Stop-Process -processname Chrome -ErrorAction SilentlyContinue
        Stop-Process -processname Firefox -ErrorAction SilentlyContinue
        Stop-Process -processname iexplore -ErrorAction SilentlyContinue
        md "C:\Temp\$ENV:Username\" -ErrorAction SilentlyContinue
        RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8
        cmd /c vssadmin delete shadows /for=c: /all /quiet
        powercfg -h off
        del -path "$env:Userprofile\AppData\Roaming\Spotify" -force -ErrorAction SilentlyContinue
        del -path "$env:Userprofile\AppData\LocalLow\Sun\Java\Deployment\cache\" -force -recurse -ErrorAction SilentlyContinue
        del -path "$env:Userprofile\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache2\entries" -force -recurse -ErrorAction SilentlyContinue
        del -path "$env:Userprofile\AppData\Local\Mozilla\Firefox\Profiles\*.default\thumbnails" -force -recurse -ErrorAction SilentlyContinue
        del -path "$env:Userprofile\AppData\Local\Google\Chrome\User Data\Default\Cache\" -force -recurse -ErrorAction SilentlyContinue
        del -path "$env:Userprofile\AppData\Local\Google\Chrome\User Data\Default\Media Cache\" -force -recurse -ErrorAction SilentlyContinue
        del -path "$env:Temp\" -force -recurse -ErrorAction SilentlyContinue
        del -path "$env:Windir\Temp\" -force -recurse -ErrorAction SilentlyContinue
        $ReferenceFilePath = "C:\Temp\$ENV:Username\FileStructureEval.txt"
        $FFPathResult = (Test-Path "$ENV:userprofile\AppData\Roaming\Mozilla\Firefox\Profiles\*.default")
		$FFPath = (Resolve-Path "$ENV:userprofile\AppData\Roaming\Mozilla\Firefox\Profiles\*.default" -ErrorAction SilentlyContinue)
        $SourcePath="C:\Temp\$ENV:Username\" #robocopy log file
        $folder = Read-Host -Prompt "Enter the folder name for the OneDrive backup"

        Write-Host ""
        Write-Host "A: Pinned Taskbar Items and Mapped Network drives"
        Write-Host "B: Sticky Notes"
        Write-Host "C: SAPGUI Settings"
        Write-Host "D: Desktop"
        Write-Host "E: Documents"
        Write-Host "F: Favorites"
        Write-Host "G: Downloads"
        Write-Host "H: Music"
        Write-Host "I: Videos"
        Write-Host "J: Chrome Bookmarks"
        Write-Host "K: Firefox Bookmarks"
        Write-Host ""
        
        $choice = Read-Host "Enter the combination of sections you want to copy"
        
        $ok = $choice -match '^[abcdefghijklmnopqrstuvwxyz]+$'
        
        if (-not $ok) {write-host "Invalid selection"}
    
    switch -RegEx ($choice) 
    {
        A
        {
			reg export HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband "$ENV:userprofile\OneDrive - SAP SE\PinnedTaskbarItems.reg"
            reg export HKCU\Network "$ENV:userprofile\OneDrive - SAP SE\MappedDrives.reg"           
        }
        B
        {
            Stop-Process -processname "Microsoft.StickyNotes" -ErrorAction SilentlyContinue
            Get-ChildItem -Force -Path $ENV:userprofile\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
            robocopy "$ENV:userprofile\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState" "$ENV:userprofile\OneDrive - SAP SE\$folder\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyStickyNotes.log
        }
        C
        {
            Get-ChildItem -Force -Path $ENV:userprofile\AppData\Roaming\SAP\Common\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
            robocopy "$ENV:userprofile\AppData\Roaming\SAP\Common" "$ENV:userprofile\OneDrive - SAP SE\$folder\AppData\Roaming\SAP\Common" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyCommon.log 
        }
        D
        {
            Get-ChildItem -Force -Path $ENV:userprofile\Desktop\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
            robocopy "$ENV:userprofile\Desktop" "$ENV:userprofile\OneDrive - SAP SE\$folder\Desktop" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyDesktop.log
        }
        E
        {
            Stop-Process -processname Outlook -ErrorAction SilentlyContinue
            Get-ChildItem -Force -Path $ENV:userprofile\Documents\ -Recurse -ErrorAction SilentlyContinue | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
            robocopy "$ENV:userprofile\Documents" "$ENV:userprofile\OneDrive - SAP SE\$folder\Documents" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyDocuments.log 
        }
        F
        {
            Get-ChildItem -Force -Path $ENV:userprofile\Favorites\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
            robocopy "$ENV:userprofile\Favorites" "$ENV:userprofile\OneDrive - SAP SE\$folder\Favorites" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyFavorites.log
        }
        G
        {
            Get-ChildItem -Force -Path $ENV:userprofile\Downloads\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
            robocopy "$ENV:userprofile\Downloads" "$ENV:userprofile\OneDrive - SAP SE\$folder\Downloads" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyDownloads.log 
        }
        H
        {
            Get-ChildItem -Force -Path $ENV:userprofile\Music\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
            robocopy "$ENV:userprofile\Music" "$ENV:userprofile\OneDrive - SAP SE\$folder\Music" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyMusic.log 
        }
        I
        {
            Get-ChildItem -Force -Path $ENV:userprofile\Videos\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
            robocopy "$ENV:userprofile\Videos" "$ENV:userprofile\OneDrive - SAP SE\$folder\Videos" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyVideo.log 
        }
        J
        {
            Get-ChildItem -Force -Path "$ENV:userprofile\AppData\Local\Google\Chrome\User Data\Default" -Recurse -ErrorAction SilentlyContinue | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
            Stop-Process -processname Chrome -ErrorAction SilentlyContinue
            Stop-Process -processname iexplore -ErrorAction SilentlyContinue
            robocopy "$ENV:userprofile\AppData\Local\Google\Chrome\User Data\Default" "$ENV:userprofile\OneDrive - SAP SE\$folder\AppData\Local\Google\Chrome\User Data\Default" /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyChrome.log 
		    Remove-Item -Path "$ENV:userprofile\OneDrive - SAP SE\$folder\AppData\Local\Google\Chrome\User Data\Default" -Exclude Bookmarks -Force -Recurse -ErrorAction SilentlyContinue
        }
        K
        {
            If ($FFPathResult -eq $True) {Get-ChildItem -Force -Path $FFPath | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append}
            Stop-Process -processname Firefox -ErrorAction SilentlyContinue
            del -path "$env:Userprofile\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache2\entries\" -force -recurse
            del -path "$env:Userprofile\AppData\Local\Mozilla\Firefox\Profiles\*.default\thumbnails\" -force -recurse
            robocopy $FFPath "$ENV:userprofile\OneDrive - SAP SE\$folder\AppData\Roaming\Mozilla\Firefox\Profiles" /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-ODDataCopyFirefox.log 
			Remove-Item -Path "$ENV:userprofile\OneDrive - SAP SE\$folder\AppData\Roaming\Mozilla\Firefox\Profiles" -Exclude places.sqlite -Force -Recurse -ErrorAction SilentlyContinue
        }
    }
    
    RoboLogGen

    Get-ChildItem "$ENV:userprofile\OneDrive - SAP SE\$folder" -Recurse | rename-item -newname { $_.name -replace '#','' } -ErrorAction SilentlyContinue
    Get-ChildItem "$ENV:userprofile\OneDrive - SAP SE\$folder" -Recurse | rename-item -newname { $_.name -replace '%','' } -ErrorAction SilentlyContinue
    Get-ChildItem "$ENV:userprofile\OneDrive - SAP SE\$folder" -Recurse | rename-item -newname { $_.name -replace '.pst', '.pstbackup' } -ErrorAction SilentlyContinue

    pause
    break
}
}

function LocalMenusub1 {
    $LocalMenusub1 = 'X'
        while($LocalMenusub1 -ne ''){
        Stop-Process -processname Outlook -ErrorAction SilentlyContinue
        Stop-Process -processname Chrome -ErrorAction SilentlyContinue
        Stop-Process -processname Firefox -ErrorAction SilentlyContinue
        Stop-Process -processname iexplore -ErrorAction SilentlyContinue
        md "C:\Temp\$ENV:Username\" -ErrorAction SilentlyContinue
        $ReferenceFilePath = "C:\Temp\$ENV:Username\FileStructureEval.txt"
        $FFPathResult = (Test-Path "$ENV:userprofile\AppData\Roaming\Mozilla\Firefox\Profiles\*.default")
		$FFPath = (Resolve-Path "$ENV:userprofile\AppData\Roaming\Mozilla\Firefox\Profiles\*.default" -ErrorAction SilentlyContinue)
        $SourcePath="C:\Temp\$ENV:Username\" #robocopy log file

        $drive = Read-Host -Prompt "Enter a drive letter (please include a : - e.g. 'D:')"

        Write-Host ""
        Write-Host "A: Pinned Taskbar Items and Mapped Network drives"
        Write-Host "B: Sticky Notes"
        Write-Host "C: SAPGUI Settings"
        Write-Host "D: Desktop"
        Write-Host "E: Documents"
        Write-Host "F: Favorites"
        Write-Host "G: Downloads"
        Write-Host "H: Music"
        Write-Host "I: Videos"
        Write-Host "J: Chrome Bookmarks"
        Write-Host "K: Firefox Bookmarks"
        Write-Host ""
        
        $choice = Read-Host "Enter the combination of sections you want to copy"
        
        $ok = $choice -match '^[abcdefghijklmnopqrstuvwxyz]+$'
        
        if (-not $ok) {write-host "Invalid selection"}
    
    switch -RegEx ($choice) 
    {
        A
        {
			reg export HKCU\Network "$drive\$ENV:username\MappedDrives.reg"
		    reg export HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband "$drive\$ENV:username\PinnedTaskbarItems.reg"          
        }
        B
        {
            Stop-Process -processname "Microsoft.StickyNotes" -ErrorAction SilentlyContinue
            Get-ChildItem -Force -Path $ENV:userprofile\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
            robocopy "$ENV:userprofile\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState" "$drive\$ENV:username\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyStickyNotes.log
        }
        C
        {
            Get-ChildItem -Force -Path $ENV:userprofile\AppData\Roaming\SAP\Common\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
            robocopy "$ENV:userprofile\AppData\Roaming\SAP\Common" "$drive\$ENV:username\AppData\Roaming\SAP\Common" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyCommon.log 
        }
        D
        {
            Get-ChildItem -Force -Path $ENV:userprofile\Desktop\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
            robocopy "$ENV:userprofile\Desktop" "$drive\$ENV:username\Desktop" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyDesktop.log
        }
        E
        {
            Stop-Process -processname Outlook -ErrorAction SilentlyContinue
            Get-ChildItem -Force -Path $ENV:userprofile\Documents\ -Recurse -ErrorAction SilentlyContinue | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
            robocopy "$ENV:userprofile\Documents" "$drive\$ENV:username\Documents" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyDocuments.log 
        }
        F
        {
            Get-ChildItem -Force -Path $ENV:userprofile\Favorites\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
            robocopy "$ENV:userprofile\Favorites" "$drive\$ENV:username\Favorites" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyFavorites.log
        }
        G
        {
            Get-ChildItem -Force -Path $ENV:userprofile\Downloads\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
            robocopy "$ENV:userprofile\Downloads" "$drive\$ENV:username\Downloads" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyDownloads.log 
        }
        H
        {
            Get-ChildItem -Force -Path $ENV:userprofile\Music\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
            robocopy "$ENV:userprofile\Music" "$drive\$ENV:username\Music" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyMusic.log 
        }
        I
        {
            Get-ChildItem -Force -Path $ENV:userprofile\Videos\ -Recurse | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
            robocopy "$ENV:userprofile\Videos" "$drive\$ENV:username\Videos" /E /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyVideo.log 
        }
        J
        {
            Get-ChildItem -Force -Path "$ENV:userprofile\AppData\Local\Google\Chrome\User Data\Default" -Recurse -ErrorAction SilentlyContinue | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append -ErrorAction SilentlyContinue
            Stop-Process -processname Chrome -ErrorAction SilentlyContinue
            Stop-Process -processname iexplore -ErrorAction SilentlyContinue
            robocopy "$ENV:userprofile\AppData\Local\Google\Chrome\User Data\Default" "$drive\$ENV:username\AppData\Local\Google\Chrome\User Data\Default" /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyChrome.log 
		    Remove-Item -Path "$drive\$ENV:username\AppData\Local\Google\Chrome\User Data\Default" -Exclude Bookmarks -Force -Recurse -ErrorAction SilentlyContinue
        }
        K
        {
            If ($FFPathResult -eq $True) {Get-ChildItem -Force -Path $FFPath | Group-Object "FullName" | Select-Object "Name" | Out-File $ReferenceFilePath -Append}
            Stop-Process -processname Firefox -ErrorAction SilentlyContinue
            del -path "$env:Userprofile\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache2\entries\" -force -recurse
            del -path "$env:Userprofile\AppData\Local\Mozilla\Firefox\Profiles\*.default\thumbnails\" -force -recurse
            robocopy $FFPath "$drive\$ENV:username\AppData\Roaming\Mozilla\Firefox\Profiles" /J /W:1 /R:50 /V /NP /FP /NS /LOG:C:\Temp\$ENV:Username\$ENV:COMPUTERNAME-LocalDataCopyFirefox.log 
			Remove-Item -Path "$drive\$ENV:username\AppData\Roaming\Mozilla\Firefox\Profiles" -Exclude places.sqlite -Force -Recurse -ErrorAction SilentlyContinue
        }
    }
    
    RoboLogGen

    Get-ChildItem "$drive\$ENV:username" -Recurse | rename-item -newname { $_.name -replace '#','' } -ErrorAction SilentlyContinue
    Get-ChildItem "$drive\$ENV:username" -Recurse | rename-item -newname { $_.name -replace '%','' } -ErrorAction SilentlyContinue
    Get-ChildItem "$drive\$ENV:username" -Recurse | rename-item -newname { $_.name -replace '.pst', '.pstbackup' } -ErrorAction SilentlyContinue

    pause
    break
}
}

function subMenu3 {
    $subMenu3 = 'X'
    while($subMenu3 -ne ''){
        Clear-Host
        Write-Host "Links"
        Write-Host
        Write-Host "1. Direct Access Status Tool"
        Write-Host "2. BIOS Password Set Tool"
        Write-Host "3. Skype Mobile Access"
        Write-Host "4. BYOD Form"

        $subMenu3 = Read-Host "`nSelection (leave blank to return to the previous menu)"
        # Option 1
        if($subMenu3 -eq 1){
                $Browser=new-object -com internetexplorer.application
                $Browser.navigate2("https://managedirectaccess.wdf.global.corp.sap/")
                $Browser.visible=$true
        }
        # Option 2
        if($subMenu3 -eq 2){
                $Browser=new-object -com internetexplorer.application
                $Browser.navigate2("https://biosprotector.wdf.global.corp.sap/sapprestart/")
                $Browser.visible=$true
        }
        # Option 3
        if($subMenu3 -eq 3){
                $Browser=new-object -com internetexplorer.application
                $Browser.navigate2("https://ucselfservice.wdf.sap.corp/Home/Overview")
                $Browser.visible=$true
        }
        # Option 4
        if($subMenu3 -eq 4){
                $Browser=new-object -com internetexplorer.application
                $Browser.navigate2("http://mobilepolicy.mo.sap.corp:3377/")
                $Browser.visible=$true
        }
    }
}

mainMenu
presentationsettings /stop
stop-process -Id $PID