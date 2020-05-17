Install-Module PowershellGet -Force
Update-Module PowershellGet
Set-ExecutionPolicy RemoteSigned
Install-Module -Name ExchangeOnlineManagement

Connect-ExchangeOnline

$NotifcationEntity = Read-Host -Prompt "Enter the email of the recipient who will receive the spam notifications"

Set-HostedOutboundSpamFilterPolicy Default -NotifyOutboundSpam $true -NotifyOutboundSpamRecipients $NotifcationEntity
