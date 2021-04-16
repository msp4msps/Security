Write-Host "Checking for MSOnline module..."

$Module = Get-Module -Name "MSOnline" -ListAvailable

if ($Module -eq $null) {
    
        Write-Host "MSOnline module not found, installing MSOnline"
        Install-Module -name MSOnline
    
    }

Write-Host "Please Enter your Partner Center Global Admin Credentials"

Connect-MSolservice -Credential $credential
$tenants = Get-MsolPartnerContract -All




ForEach($tenant in $tenants){

Write-Host "Disabling Self-Service for $($tenant.Name)" -ForegroundColor Green

Set-MsolCompanySettings -Tenant $tenant.tenantID -AllowAdHocSubscriptions $false


}
