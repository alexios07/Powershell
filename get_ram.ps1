$computer=Read-Host -Prompt "Input Computer name"

Get-WmiObject win32_physicalmemory -computername $computer | select-object devicelocator,@{'name'='Size (GB)'; 'Expression'={[math]::truncate($_.capacity / 1GB)}},manufacturer,serialnumber,partnumber
#Get-WmiObject win32_physicalmemory -computername $computer | out-gridview

#export-csv $home\"$computer".csv
