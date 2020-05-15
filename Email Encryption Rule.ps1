Install-Module PowershellGet -Force
Update-Module PowershellGet
Set-ExecutionPolicy RemoteSigned
Install-Module -Name ExchangeOnlineManagement

Connect-ExchangeOnline

New-TransportRule -Name "Encrypt Email" -SubjectContainsWords "Secure" -ApplyRightsProtectionTemplate "Encrypt"
