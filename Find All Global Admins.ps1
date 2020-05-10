# This is the username of an Office 365 account with delegated admin permissions
 
$UserName = Read-Host -Prompt "Please enter Partner Center Username"
 
$Cred = get-credential -Credential $UserName
 
#This script is looking for unlicensed Company Administrators. Though you can update the role here to look for another role type.
 
$RoleName = "Company Administrator"
 
Connect-MSOLService -Credential $Cred
 
Import-Module MSOnline
 
$Customers = Get-MsolPartnerContract -All
 
$msolUserResults = @()
 
# This is the path of the exported CSV. You'll need to create a C:\temp folder. You can change this, though you'll need to update the next script with the new path.
 
$msolUserCsv = "C:\temp\AdminUserList.csv"
 
 
ForEach ($Customer in $Customers) {
 
    Write-Host "----------------------------------------------------------"
    Write-Host "Getting Unlicensed Admins for $($Customer.Name)"
    Write-Host " "
 
 
    $CompanyAdminRole = Get-MsolRole | Where-Object{$_.Name -match $RoleName}
    $RoleID = $CompanyAdminRole.ObjectID
    $Admins = Get-MsolRoleMember -TenantId $Customer.TenantId -RoleObjectId $RoleID
 
    foreach ($Admin in $Admins){
         
        if($Admin.EmailAddress -ne $null){
 
            $MsolUserDetails = Get-MsolUser -UserPrincipalName $Admin.EmailAddress -TenantId $Customer.TenantId
 
            $LicenseStatus = $MsolUserDetails.IsLicensed
            $userProperties = @{
 
                TenantId = $Customer.TenantID
                CompanyName = $Customer.Name
                PrimaryDomain = $Customer.DefaultDomainName
                DisplayName = $Admin.DisplayName
                EmailAddress = $Admin.EmailAddress
                IsLicensed = $LicenseStatus
                BlockCredential = $MsolUserDetails.BlockCredential
            }
 
            Write-Host "$($Admin.DisplayName) from $($Customer.Name) is an unlicensed Company Admin"
 
            $msolUserResults += New-Object psobject -Property $userProperties
             
        }
    }
 
    Write-Host " "
 
}
 
$msolUserResults | Select-Object TenantId,CompanyName,PrimaryDomain,DisplayName,EmailAddress,IsLicensed,BlockCredential | Export-Csv -notypeinformation -Path $msolUserCsv
 
Write-Host "Export Complete"