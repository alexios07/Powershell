$computer=Read-Host -Prompt "Input Computer name"

Get-WmiObject win32_physicalmemory -computername $computer | select-object devicelocator,@{'name'='Size (GB)'; 'Expression'={[math]::truncate($_.capacity / 1GB)}},manufacturer,serialnumber,partnumber
#Get-WmiObject win32_physicalmemory -computername $computer | out-gridview

#export-csv $home\"$computer".csv

#add thêm một dòng để test thử xem nếu change 1 file ở branch dev thì trên repo thế nào?