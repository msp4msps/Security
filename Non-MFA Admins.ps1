Connect-MsolService
$admins = Import-csv C:\temp\nonMFAAdmins.csv
 
$auth = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
$auth.RelyingParty = "*"
$auth.State = "Enabled"
$auth.RememberDevicesNotIssuedBefore = (Get-Date)
 
foreach ($admin in $admins) {
 
    if ($admin.IsLicensed -eq "FALSE") {
        Write-Host "Enabling MFA for $($admin.userprincipalname)" -ForegroundColor Green
        Set-MsolUser -UserPrincipalName $admin.userprincipalname -StrongAuthenticationRequirements $auth -TenantId $admin.tenantid
        $state = (get-msoluser -TenantId $admin.tenantid -UserPrincipalName $admin.UserPrincipalName).StrongAuthenticationRequirements.state
        $admin.MFAStatus = $state
        $admin | export-csv C:\temp\adminMFAStatus.csv -NoTypeInformation -append
    }
    else {
        Write-Host "Not Enabling MFA for $($admin.userprincipalname)" -ForegroundColor Red
        $admin | export-csv C:\temp\MFAEnabledAdmins.csv -Append -NoTypeInformation
    }
}