$credential = Get-Credential
Connect-MsolService -Credential $credential
$customers = Get-MsolPartnerContract -All
Write-Host "Found $($customers.Count) customers for this Partner."
 
foreach ($customer in $customers) {


    $InitialDomain = Get-MsolDomain -TenantId $customer.TenantId | Where-Object {$_.IsInitial -eq $true}

    Write-Host "Enabling External Calendar Sharing Policy for $($Customer.Name)"

    $DelegatedOrgURL = "https://outlook.office365.com/powershell-liveid?DelegatedOrg=" + $InitialDomain.Name
    $session = New-PSSession -ConnectionUri $DelegatedOrgURL -Credential $credential -Authentication Basic -ConfigurationName Microsoft.Exchange -AllowRedirection
    Import-PSSession $session -CommandName Get-SharingPolicy, Set-SharingPolicy  -AllowClobber
    Enable-OrganizationCustomization

    $existingsetting = Get-SharingPolicy -Identity "Default Sharing Policy"

    if($existingsetting){


    Set-SharingPolicy -Identity "Default Sharing Policy" -Domains "Anonymous: CalendarSharingFreeBusySimple"
    Write-Host "Policy set for $($customer.Name)"

    }
    Remove-PSSession $session

}