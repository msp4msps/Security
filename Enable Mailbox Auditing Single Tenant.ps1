Install-Module PowershellGet -Force
Update-Module PowershellGet
Set-ExecutionPolicy RemoteSigned
Install-Module -Name ExchangeOnlineManagement

Connect-ExchangeOnline

Get-Mailbox -ResultSize Unlimited -Filter{RecipientTypeDetails -eq "UserMailbox"} | Set-Mailbox -AuditEnabled$true -AuditOwner MailboxLogin, HardDelete, SoftDelete, Update, Move -AuditDelegate SendOnBehalf, MoveToDeletedItems, Move -AuditAdmin Copy, MessageBind