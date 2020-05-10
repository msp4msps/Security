Connect-MsolService
$admins = Import-csv C:\temp\MFAEnabledAdmins.csv
 
foreach($admin in $admins){
    Write-Host "Blocking $($admin.userprincipalname)"
    Set-Msoluser -tenantid $admin.tenantid -userprincipalname $admin.userprincipalname -blockcredential $true
}