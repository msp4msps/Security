Install-Module PowershellGet -Force
Update-Module PowershellGet
Set-ExecutionPolicy RemoteSigned
Install-Module -Name ExchangeOnlineManagement
Import-Module Msonline


Write-Output "Getting the Exchange Online cmdlets"
Connect-MsolService
Connect-ExchangeOnline





$startDate = (Get-Date).AddDays(-90).ToString('MM/dd/yyyy')
$endDate = (Get-Date).ToString('MM/dd/yyyy')

$allUsers = @()
$allUsers = Get-MsolUser -All -EnabledFilter EnabledOnly | Select UserPrincipalName

$loggedOnUsers = @()
$loggedOnUsers = Search-UnifiedAuditLog -StartDate $startDate -EndDate $endDate -Operations UserLoggedIn, PasswordLogonInitialAuthUsingPassword, UserLoginFailed -ResultSize 5000

$inactiveInLastThreeMonthsUsers = @()
$inactiveInLastThreeMonthsUsers = $allUsers.UserPrincipalName | where {$loggedOnUsers.UserIds -NotContains $_} | Sort-Object

Write-Output "The following users have no logged in for the last 90 days:"
Write-Output $inactiveInLastThreeMonthsUsers