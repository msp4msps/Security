$credential = Get-Credential
Connect-MsolService -Credential $credential
$customers = Get-MsolPartnerContract -All
$TransportRuleName = "Email Encryption"

 
Write-Output "Found $($customers.Count) customers for $((Get-MsolCompanyInformation).displayname)."
  
foreach ($customer in $customers) {
    $InitialDomain = Get-MsolDomain -TenantId $customer.TenantId | Where-Object {$_.IsInitial -eq $true}
            
    Write-Output "Checking transport rule for $($Customer.Name)"
    $DelegatedOrgURL = "https://outlook.office365.com/powershell-liveid?DelegatedOrg=" + $InitialDomain.Name
    $session = New-PSSession -ConnectionUri $DelegatedOrgURL -Credential $credential -Authentication Basic -ConfigurationName Microsoft.Exchange -AllowRedirection
    Import-PSSession $session -CommandName Get-TransportRule, New-TransportRule, Set-TransportRule -AllowClobber
      
    $EmailEncryptRule = Get-TransportRule | Where-Object {$_.Identity -contains $TransportRuleName}
 
    if (!$EmailEncryptRule) {
        Write-Output "Rule for Encryption not found, creating Rule"
        New-TransportRule -Name "Encrypt Email" -SubjectContainsWords "Secure" -ApplyRightsProtectionTemplate "Encrypt"
    }    
    Remove-PSSession $session
}