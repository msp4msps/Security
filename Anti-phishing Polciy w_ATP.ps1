Install-Module PowershellGet -Force
Update-Module PowershellGet
Set-ExecutionPolicy RemoteSigned
Install-Module -Name ExchangeOnlineManagement

Connect-ExchangeOnline


$ProtectedUser = Read-Host -Prompt "Type in individuals you want to protect (CEO, CFO, etc) Type their display name and emai in the following format DisplayName;Email ex. Bruce Wayne;bwayne@tminus365.com"
$ExcludedDomains = Read-Host -Prompt "Are there domains you want to whitlist? If y then type their domains with a comma separation. If no, type null"
$ExcludedSenders = Read-Host -Prompt "Are there senders you want to whitlist? If y then type their emails with a comma separation. If no, type null@null.com"



Set-AntiPhishPolicy -Identity "Office365 AntiPhish Default" -EnableOrganizationDomainsProtection $true  -TargetedDomainProtectionAction Quarantine -EnableTargetedUserProtection $true -TargetedUsersToProtect $ProtectedUser -TargetedUserProtectionAction Quarantine -EnableMailboxIntelligence $true -EnableMailboxIntelligenceProtection $true -MailboxIntelligenceProtectionAction Quarantine -EnableSimilarUsersSafetyTips $true -EnableSimilarDomainsSafetyTips $true -EnableUnusualCharactersSafetyTips $true -ExcludedDomains $ExcludedDomains -ExcludedSenders $ExcludedSenders