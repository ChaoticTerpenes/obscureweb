Add-MpPreference -ExclusionPath 'C:\'
Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
New-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" -Name "PrivacyConsentStatus" -Value 1 -PropertyType DWORD -Force 
New-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" -Name "SkipMachineOOBE" -Value 1 -PropertyType DWORD -Force 
New-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" -Name "ProtectYourPC" -Value 3 -PropertyType DWORD -Force 
New-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" -Name "SkipUserOOBE" -Value 1 -PropertyType DWORD -Force 
netsh firewall set opmode disable

Out-File -FilePath C:\Windows\Temp\debloat.ps1 -Encoding UTF8 -InputObject ("& ([scriptblock]::Create((irm 'https://raw.githubusercontent.com/Raphire/Win11Debloat/master/Get.ps1'))) -RunDefaults -ShowHiddenFolders -Silent")

Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value "127.0.0.4 attack.dvwa`r`n127.0.0.3 attack.goat`r`n127.0.0.2 attack.juice`r`n127.0.0.5 attack.vpn" -Force
netsh interface portproxy add v4tov4 listenport=80 listenaddress=127.0.0.2 connectport=3000 connectaddress=10.1.0.52
netsh interface portproxy add v4tov4 listenport=80 listenaddress=127.0.0.3 connectport=8080 connectaddress=10.1.0.52
netsh interface portproxy add v4tov4 listenport=80 listenaddress=127.0.0.4 connectport=80 connectaddress=10.1.0.52
netsh interface portproxy add v4tov4 listenport=80 listenaddress=127.0.0.5 connectport=80 connectaddress=10.1.0.20
choco install -y powershell
curl.exe -L -o C:\Windows\Temp\kali.appx https://aka.ms/wsl-kali-linux-new
curl.exe -L -o C:\Windows\Temp\vcxsrv.exe https://downloads.sourceforge.net/project/vcxsrv/vcxsrv/1.20.14.0/vcxsrv-64.1.20.14.0.installer.exe
choco install -y autoit

Out-File -FilePath C:\Windows\Temp\wslinstall.ps1 -Encoding UTF8 -InputObject ("
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart | out-null;
Start-Job -Name Debloat -ScriptBlock {C:\Windows\Temp\debloat.ps1};
Start-Sleep 5;
wsl --update | out-null;
Start-Sleep 5;
Start-Job -Name AddAppx -ScriptBlock {C:\Windows\Temp\wslinstall2.ps1} | Wait-Job;
Start-Job -Name KaliInstall -ScriptBlock {C:\Windows\Temp\wslinstall3.ps1} | Wait-Job;
Start-Job -Name KaliAddUsers -ScriptBlock {C:\Windows\Temp\wslinstall4.ps1};
Start-Job -Name WSLStartup -ScriptBlock {C:\Windows\Temp\wslinstall5.ps1};
Start-Sleep 20;
iex 'cmd /c start powershell -windowstyle minimized -noexit -Command ''kali run ''''sudo apt install -y kali-win-kex;exit''''''';
kali;
")

#Start-Job -Name KaliKex -ScriptBlock {C:\Windows\Temp\wslinstall5.ps1} | Wait-Job;
Out-File -FilePath C:\Windows\Temp\wslinstall2.ps1 -Encoding UTF8 -InputObject ("
Add-AppxPackage C:\Windows\Temp\kali.appx
")

Out-File -FilePath C:\Windows\Temp\wslinstall3.ps1 -Encoding UTF8 -InputObject ("
Start-Sleep 2;
kali install --root;
Start-Sleep 2;
wsl --shell-type login -e apt update
")

Out-File -FilePath C:\Windows\Temp\wslinstall4.ps1 -Encoding UTF8 -InputObject ("
kali run 'adduser --quiet --disabled-password --shell /bin/bash --home /home/ansible --gecos '''' ansible';
kali run 'echo ansible:ansible | chpasswd';
kali run 'adduser --quiet --disabled-password --shell /bin/bash --home /home/kali --gecos '''' kali';
kali run 'echo kali:kali | chpasswd';
kali run 'echo ''kali ALL=(ALL) NOPASSWD: ALL'' | sudo EDITOR=''tee -a'' visudo';
kali run 'echo ''ansible ALL=(ALL) NOPASSWD: ALL'' | sudo EDITOR=''tee -a'' visudo';
kali config --default-user kali;
New-Item -Path C:\Windows\Temp\run_complete.txt -ItemType File -Force;
")

Out-File -FilePath C:\Windows\Temp\wslinstall5.ps1 -Encoding UTF8 -InputObject ("
`$action = New-ScheduledTaskAction -Execute 'powershell' -Argument '-enc QwA6AFwAVwBpAG4AZABvAHcAcwBcAFQAZQBtAHAAXAB3AHMAbAByAHUAbgAuAHAAcwAxAA==';
`$trigger = New-ScheduledTaskTrigger -AtLogon;
`$principal = New-ScheduledTaskPrincipal -UserID '$env:computername\$env:username' -LogonType Interactive -RunLevel Highest;
`$settings = New-ScheduledTaskSettingsSet;
Register-ScheduledTask -TaskName 'WSL' -Action `$action -Trigger `$trigger -Settings `$settings -Principal `$principal;
")

New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "wslinstall" -Value "powershell -noexit -enc QwA6AFwAVwBpAG4AZABvAHcAcwBcAFQAZQBtAHAAXAB3AHMAbABpAG4AcwB0AGEAbABsAC4AcABzADEA" -PropertyType string -Force

Out-File -FilePath C:\Windows\Temp\wslrun.ps1 -Encoding UTF8 -InputObject ("
iex 'cmd /c start powershell -noexit -Command ''Start-Process powershell.exe -ArgumentList ''''-Exec Bypass'''', ''''-noexit'''', ''''& { while (!(Test-Path -Path ''''''''C:\Windows\Temp\run_complete.txt'''''''')) { Write-Host ''''''''Please wait while Kali loads...''''''''; Start-Sleep -Seconds 20 } ; & kali }'''' -Wait -NoNewWindow'''
")

Shutdown -r -t 15