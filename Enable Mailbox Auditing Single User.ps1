Install-Module PowershellGet -Force
Update-Module PowershellGet
Set-ExecutionPolicy RemoteSigned
Install-Module -Name ExchangeOnlineManagement

Connect-ExchangeOnline

$Mailbox = Read-Host -Prompt "Please Enter the display name of the user you want to enable mailbox auditing"

Set-Mailbox -Identity $Mailbox -AuditEnabled $true -AuditOwner MailboxLogin, HardDelete, SoftDelete, Update, Move -AuditDelegate SendOnBehalf, MoveToDeletedItems, Move -AuditAdmin Copy, MessageBind