﻿#Connect to Office365 Partner Tenancy
$Cred = Get-Credential
Connect-MsolService -Credential $Cred
#Get list of Tennant ID's
$Tenant = Get-MsolPartnerContract
foreach ($ID in $Tenant) {Set-MsolCompanySettings -TenantId $ID.TenantID -SelfServePasswordResetEnabled $true
Get-MsolCompanyInformation -TenantId $ID.TenantId | Select DisplayName, SelfServePasswordResetEnabled}