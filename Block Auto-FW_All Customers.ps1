$credential = Get-Credential
Connect-MsolService -Credential $credential
$customers = Get-MsolPartnerContract -All
$TransportRuleName = "Block Auto-Forwarding"
$rejectMessage = "To improve security, auto-forwarding rules to external email addresses have been disabled. Please contact your helpdesk if you want to create an exception"
 
Write-Output "Found $($customers.Count) customers for $((Get-MsolCompanyInformation).displayname)."
  
foreach ($customer in $customers) {
    $InitialDomain = Get-MsolDomain -TenantId $customer.TenantId | Where-Object {$_.IsInitial -eq $true}
            
    Write-Output "Checking transport rule for $($Customer.Name)"
    $DelegatedOrgURL = "https://outlook.office365.com/powershell-liveid?DelegatedOrg=" + $InitialDomain.Name
    $session = New-PSSession -ConnectionUri $DelegatedOrgURL -Credential $credential -Authentication Basic -ConfigurationName Microsoft.Exchange -AllowRedirection
    Import-PSSession $session -CommandName Get-TransportRule, New-TransportRule, Set-TransportRule -AllowClobber
      
    $externalForwardRule = Get-TransportRule | Where-Object {$_.Identity -contains $TransportRuleName}
 
    if (!$externalForwardRule) {
        Write-Output "Rule for Auto-forwarding not found, creating Rule"
        New-TransportRule -name "Block Auto-forwarding" -Priority 1 -SentToScope NotInOrganization -FromScope InOrganization -MessageTypeMatches AutoForward -RejectMessageEnhancedStatusCode 5.7.1 -RejectMessageReasonText $rejectMessage
    }    
    Remove-PSSession $session
}
