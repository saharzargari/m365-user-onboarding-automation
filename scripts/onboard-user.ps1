$csvPath = "..\data\new_users.csv"
$logFolder = "..\logs"
$logFile = Join-Path $logFolder "onboarding-log.txt"
$existingUsers = @()
function Write-Log {
   param ([string]$Message)
   $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
   Add-Content -Path $logFile -Value "[$timestamp] $Message"
}
function Generate-Password {
   $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%"
   $password = -join ((1..12) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
   return $password
}
function Generate-UPN {
   param ($FirstName, $LastName)
   $upn = ($FirstName.Substring(0,1) + $LastName).ToLower() + "@contoso.com"
   return $upn
}
function Is-Duplicate {
   param ($upn)
   if ($existingUsers -contains $upn) {
       return $true
   }
   return $false
}
if (!(Test-Path $logFolder)) {
   New-Item -ItemType Directory -Path $logFolder | Out-Null
}
$users = Import-Csv $csvPath
foreach ($user in $users) {
   $upn = Generate-UPN -FirstName $user.FirstName -LastName $user.LastName
   Write-Host "Processing $($user.FirstName) $($user.LastName)"
   if (Is-Duplicate $upn) {
       Write-Host "Duplicate user detected: $upn"
       Write-Log "FAILED - Duplicate user: $upn"
       continue
   }
   $password = Generate-Password
   $existingUsers += $upn
   Write-Host "Generated UPN: $upn"
   Write-Host "Generated Password: $password"
   Write-Log "SUCCESS - Created $upn | Dept=$($user.Department) | Group=$($user.GroupName)"
   Write-Host "----------------------------------------"
}
Write-Host "Processing complete. Check logs."