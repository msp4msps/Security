###CONNECT TO EXCHANGE ONLINE ##########


Install-Module PowershellGet -Force
Update-Module PowershellGet
Set-ExecutionPolicy RemoteSigned
Install-Module -Name ExchangeOnlineManagement

Connect-ExchangeOnline



###BLOCK AUTO FW #######################


$externalTransportRuleName = "Block Auto-Forwarding"
$rejectMessageText = "To improve security, auto-forwarding rules to external email addresses have been disabled. Please contact your helpdesk if you want to create an exception."
 
$externalForwardRule = Get-TransportRule | Where-Object {$_.Identity -contains $externalTransportRuleName}
 
if (!$externalForwardRule) {
    Write-Output "Rule for Auto-forwarding not found, creating Rule"
    New-TransportRule -name "Block Auto-forwarding" -Priority 1 -SentToScope NotInOrganization -FromScope InOrganization -MessageTypeMatches AutoForward -RejectMessageEnhancedStatusCode 5.7.1 -RejectMessageReasonText $rejectMessageText
}   

######Set Up Email Encryption Rule########################

New-TransportRule -Name "Encrypt Email" -SubjectContainsWords "Secure" -ApplyRightsProtectionTemplate "Encrypt"


#################Set FREE/BUSY CALENDAR INFO ########################

Set-SharingPolicy -Identity "Default Sharing Policy" -Domains "Anonymous: CalendarSharingFreeBusySimple"

#######SET OUT BOUND SPAM NOTIFICATIONS ######################

$NotifcationEntity = Read-Host -Prompt "Enter the email of the recipient who will receive the spam notifications"

Set-HostedOutboundSpamFilterPolicy Default -NotifyOutboundSpam $true -NotifyOutboundSpamRecipients $NotifcationEntity

#################SET UP ATP SAFE LINKS AND SAFE ATTACHMENTS #########################################


$DomainName = Read-Host -Prompt "Enter Tenant Domain Name"

$WhiteListURl = Read-Host -Prompt "Enter any URLs you want to whitelist. If you have none, press enter"



New-SafeAttachmentPolicy -Name "Policy 1" -Action Dynamicdelivery -Enable $true -ActionOnError $true
New-SafeAttachmentRule -Name "Safe Attachment Policy" -SafeAttachmentPolicy "Policy 1" -RecipientDomainIs $DomainName


New-SafeLinksPolicy -Name "Policy 1" -DoNotTrackUserClicks $true -EnableForInternalSenders $true -DoNotAllowClickThrough $True -TrackClicks $false -ScanUrls $true -AllowClickThrough $false -DoNotRewriteUrls $WhiteListURl -IsEnabled $true

New-SafeLinksRule -Name "SafeLinksPolicy" -SafeLinksPolicy "Policy 1" -RecipientDomainIs $DomainName -Enabled $true


#########SET UP ANTI-PHISHING POLICY ##########################

$ProtectedUser = Read-Host -Prompt "Type in individuals you want to protect (CEO, CFO, etc) Type their display name and emai in the following format DisplayName;Email ex. Bruce Wayne;bwayne@tminus365.com"
$ExcludedDomains = Read-Host -Prompt "Are there domains you want to whitlist? If y then type their domains with a comma separation. If no, type null"
$ExcludedSenders = Read-Host -Prompt "Are there senders you want to whitlist? If y then type their emails with a comma separation. If no, type null@null.com"



Set-AntiPhishPolicy -Identity "Office365 AntiPhish Default" -EnableOrganizationDomainsProtection $true  -TargetedDomainProtectionAction Quarantine -EnableTargetedUserProtection $true -TargetedUsersToProtect $ProtectedUser -TargetedUserProtectionAction Quarantine -EnableMailboxIntelligence $true -EnableMailboxIntelligenceProtection $true -MailboxIntelligenceProtectionAction Quarantine -EnableSimilarUsersSafetyTips $true -EnableSimilarDomainsSafetyTips $true -EnableUnusualCharactersSafetyTips $true -ExcludedDomains $ExcludedDomains -ExcludedSenders $ExcludedSenders
