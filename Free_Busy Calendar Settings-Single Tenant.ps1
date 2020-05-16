Function Connect-EXOnline {
    $credentials = Get-Credential
    Write-Output "Getting the Exchange Online cmdlets"
    $session = New-PSSession -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
        -ConfigurationName Microsoft.Exchange -Credential $credentials `
        -Authentication Basic -AllowRedirection
    Import-PSSession $session
}
Connect-EXOnline 

Set-SharingPolicy -Identity "Default Sharing Policy" -Domains "Anonymous: CalendarSharingFreeBusySimple"