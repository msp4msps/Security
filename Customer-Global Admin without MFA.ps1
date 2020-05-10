Connect-MsolService
 
$customers = Get-MsolPartnerContract
$role = Get-MsolRole | Where-Object {$_.name -contains "Company Administrator"}
foreach($customer in $customers){
     
    $users = Get-MsolUser -TenantId $customer.tenantid
    $admins = Get-MsolRoleMember -TenantId $customer.tenantid -RoleObjectId $role.objectid
 
    foreach($admin in $admins){
        $adminuser = $users | Where-Object {$_.userprincipalname -contains $admin.emailaddress}
        if($adminuser){
            if($adminuser.strongauthenticationrequirements.state -notcontains "Enforced" -and $adminuser.strongauthenticationrequirements.state -notcontains "Enabled"){
                Write-Host "No MFA enabled for $($adminuser.userprincipalname)"
                $adminuser | Add-Member TenantId $customer.tenantid
                $adminuser | Add-Member CustomerName $customer.name
                $adminuser | Select-Object TenantId,CustomerName,DisplayName,UserPrincipalName,islicensed,@{n="MFAStatus";e={$_.strongauthenticationrequirements.state}} | export-csv C:\temp\nonMFAAdmins.csv -NoTypeInformation -Append
 
            }else{
                Write-Host "MFA enabled for $($adminuser.userprincipalname)" -ForegroundColor Green
            }
        }
    }
}