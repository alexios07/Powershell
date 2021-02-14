$Computernames = Get-content -path C:\list\boardroom_comps.txt
$PsExecPath = 'C:\users\mtran\Documents\Powershell\PSTools\PsExec.exe'

Foreach ($Computername in $Computernames) {

    function Test-PsRemoting { 
        param ( 
            [Parameter(Mandatory = $true)] 
            $computername 
        ) 
         
        try { 
            $errorActionPreference = "Stop" 
            $result = Invoke-Command -ComputerName $computername { 1 } 
        } catch { 
            Write-Verbose $_ 
            return $false 
        } 
         
        ## I’ve never seen this happen, but if you want to be 
        ## thorough…. 
        if ($result -ne 1) { 
            Write-Verbose "Remoting to $computerName returned an unexpected result." 
            return $false 
        } 
        $true 
    } 

    if (Test-PsRemoting $Computername) { 
        Write-Warning "Remoting already enabled on $Computername" 
    } else { 
        Write-Verbose "Attempting to enable remoting on $Computername..." 
        & $PsExecPath "\\$Computername" -s c:\windows\system32\winrm.cmd quickconfig -quiet 2>&1> $null 
        if (!(Test-PsRemoting $Computername)) { 
            Write-Warning "Remoting was attempted but not enabled on $Computername" 
        } else { 
            Write-Verbose "Remoting successfully enabled on $Computername" 
        } 
    } 
} 
