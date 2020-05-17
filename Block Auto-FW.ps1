Install-Module PowershellGet -Force
Update-Module PowershellGet
Set-ExecutionPolicy RemoteSigned
Install-Module -Name ExchangeOnlineManagement

Connect-ExchangeOnline
 
$externalTransportRuleName = "Block Auto-Forwarding"
$rejectMessageText = "To improve security, auto-forwarding rules to external email addresses have been disabled. Please contact your helpdesk if you want to create an exception."
 
$externalForwardRule = Get-TransportRule | Where-Object {$_.Identity -contains $externalTransportRuleName}
 
if (!$externalForwardRule) {
    Write-Output "Rule for Auto-forwarding not found, creating Rule"
    New-TransportRule -name "Block Auto-forwarding" -Priority 1 -SentToScope NotInOrganization -FromScope InOrganization -MessageTypeMatches AutoForward -RejectMessageEnhancedStatusCode 5.7.1 -RejectMessageReasonText $rejectMessageText
}   
