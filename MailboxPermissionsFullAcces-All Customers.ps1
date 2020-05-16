$credential = Get-Credential
Connect-MsolService -Credential $credential
$customers = Get-MsolPartnerContract -All

 
Write-Output "Found $($customers.Count) customers for $((Get-MsolCompanyInformation).displayname)."
  
foreach ($customer in $customers) {
    $InitialDomain = Get-MsolDomain -TenantId $customer.TenantId | Where-Object {$_.IsInitial -eq $true}
            
    Write-Output "Checking Mailbox Access Permissions for $($Customer.Name)"
    $DelegatedOrgURL = "https://outlook.office365.com/powershell-liveid?DelegatedOrg=" + $InitialDomain.Name
    $session = New-PSSession -ConnectionUri $DelegatedOrgURL -Credential $credential -Authentication Basic -ConfigurationName Microsoft.Exchange -AllowRedirection
    Import-PSSession $session -CommandName Get-Mailbox, Get-MailboxPermission -AllowClobber
      
    
 
    Write-Output "Getting Full Access Permissions"

    Get-Mailbox | Get-MailboxPermission | where {$_.user -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false} | Format-Table Identity, User, IsInherited, AccessRights
    Remove-PSSession $session
       
 
}