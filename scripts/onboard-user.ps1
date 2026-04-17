$csvPath = "..\data\new_users.csv"
$logFolder = "..\logs"
$logFile = Join-Path $logFolder "onboarding-log.txt"
function Write-Log {
   param (
       [string]$Message
   )
   $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
   Add-Content -Path $logFile -Value "[$timestamp] $Message"
}
function Validate-User {
   param (
       [pscustomobject]$User
   )
   if ([string]::IsNullOrWhiteSpace($User.FirstName) -or
       [string]::IsNullOrWhiteSpace($User.LastName) -or
       [string]::IsNullOrWhiteSpace($User.UserPrincipalName)) {
       return $false
   }
   return $true
}
if (!(Test-Path $logFolder)) {
   New-Item -ItemType Directory -Path $logFolder | Out-Null
}
if (!(Test-Path $csvPath)) {
   Write-Host "CSV file not found: $csvPath"
   exit
}
$users = Import-Csv $csvPath
foreach ($user in $users) {
   Write-Host "Processing user: $($user.DisplayName)"
   if (-not (Validate-User -User $user)) {
       Write-Host "Validation failed for $($user.DisplayName)"
       Write-Log "Validation failed for $($user.DisplayName)"
       continue
   }
   Write-Host "Simulating account creation..."
   Write-Log "Created account for $($user.DisplayName) with UPN $($user.UserPrincipalName)"
   Write-Host "Simulating group assignment..."
   Write-Log "Assigned $($user.DisplayName) to group $($user.GroupName)"
   Write-Host "Simulating department/job title update..."
   Write-Log "Set Department=$($user.Department), JobTitle=$($user.JobTitle) for $($user.DisplayName)"
   Write-Host "Simulating license preparation..."
   Write-Log "Prepared license assignment for $($user.DisplayName), UsageLocation=$($user.UsageLocation)"
   Write-Host "Completed $($user.DisplayName)"
   Write-Host "----------------------------------------"
}
Write-Host "All users processed. Review the logs in $logFile"