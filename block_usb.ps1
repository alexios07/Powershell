New-Item 'HKLM:\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}' -Force

New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}' -Name Deny_Read -PropertyType DWord -Value 1 -Force | Out-Null
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}' -Name Deny_Write -PropertyType DWord -Value 1 -Force | Out-Null
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}' -Name Deny_Execute -PropertyType DWord -Value 1 -Force | Out-Null