Install-Module PowershellGet -Force
Update-Module PowershellGet
Set-ExecutionPolicy RemoteSigned
Install-Module -Name ExchangeOnlineManagement

Connect-ExchangeOnline

Get-Mailbox | Get-MailboxPermission | where {$_.user -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false} | Format-Table Identity, User, IsInherited, AccessRights