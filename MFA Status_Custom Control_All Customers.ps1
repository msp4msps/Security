######### Secrets #########
$ApplicationId = 'ApplicationID'
$ApplicationSecret = 'ApplicationSecret'
$TenantID = 'TenantID'
$RefreshToken = 'LongRefreshToken'
$secPas = $ApplicationSecret| ConvertTo-SecureString -AsPlainText -Force


If (Get-Module -ListAvailable -Name "PsWriteHTML") { Import-module PsWriteHTML } Else { install-module PsWriteHTML -Force; import-module PsWriteHTML }
If (Get-Module -ListAvailable -Name "MsOnline") { Import-module "Msonline" } Else { install-module "MsOnline" -Force; import-module "Msonline" }
If (Get-Module -ListAvailable -Name "PartnerCenter") { Import-module "PartnerCenter" } Else { install-module "PartnerCenter" -Force; import-module "PartnerCenter" }


$credential = New-Object System.Management.Automation.PSCredential($ApplicationId, $secPas)
$aadGraphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.windows.net/.default' -ServicePrincipal -Tenant $tenantID 
$graphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.microsoft.com/.default' -ServicePrincipal -Tenant $tenantID 
   
write-host "Creating body to request Graph access for each client." -ForegroundColor Green
$body = @{
    client_id     = $ApplicationId
    client_secret = $ApplicationSecret
    grant_type    = "client_credentials"
    scope         = "https://graph.microsoft.com/.default"

}
   
write-host "Connecting to Partner Center to get all tenants." -ForegroundColor Green
Connect-MsolService -AdGraphAccessToken $aadGraphToken.AccessToken -MsGraphAccessToken $graphToken.AccessToken
$customers = Get-MsolPartnerContract -All
foreach ($Customer in $Customers) {

    $ClientToken = Invoke-RestMethod -Method post -Uri "https://login.microsoftonline.com/$($customer.tenantId)/oauth2/v2.0/token" -Body $body -ErrorAction Stop
    $headers = @{ "Authorization" = "Bearer $($ClientToken.access_token)" }
    $Users = (Invoke-RestMethod -Uri 'https://graph.microsoft.com/v1.0/users?$top=999' -Headers $Headers -Method Get -ContentType "application/json").value | Select-Object DisplayName, proxyaddresses, AssignedLicenses, userprincipalname
    $MFAStatus = Get-MsolUser -all -TenantId $customer.TenantId | Select-Object DisplayName,UserPrincipalName,@{N="MFA Status"; E={if( $_.StrongAuthenticationRequirements.State -ne $null) {$_.StrongAuthenticationRequirements.State} else { "Disabled"}}}
    
 
    write-host "Grabbing Potential Conditional Access MFA Registration for $($Customer.name)" -ForegroundColor Green
    try{
    $uri = "https://graph.microsoft.com/beta/reports/credentialUserRegistrationDetails"
    $MFA2 = (Invoke-RestMethod -Uri $uri -Headers $headers -Method Get).value | Select-Object userPrincipalName, isMfaRegistered, @{N="MFA Registration Status"; E={if( $_.isMfaRegistered -ne $null) {$_.isMfaRegistered } else { "Disabled"}}}
    } catch {
       Write-Host "$($customer.name) does not have Azure AD P1 licensing"
    }

        write-host "Grabbing Conditional Access Policies $($Customer.name)" -ForegroundColor Green
    try{
    $CAPolicy = (Invoke-RestMethod -Uri 'https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies?$count=true' -Headers $Headers -Method Get -ContentType "application/json").value| Select-Object count, grantControls, displayName
    $CAPolicy2 = $CAPolicy.grantControls
    $duoMFA = $CAPolicy2. customAuthenticationFactors
    $customer | Add-Member ConditionalAccessPolicies $CAPolicy.count
    $customer | Add-Member CustomControl $duoMFA
    } catch {
       Write-Host "$($customer.name) does not have Azure AD P1 licensing"
    }
   
    write-host "Grabbing Security Defaults Policy for $($Customer.name)" -ForegroundColor Green
    $uri = "https://graph.microsoft.com/v1.0/policies/identitySecurityDefaultsEnforcementPolicy"
    $Data2 = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get | Select-Object isEnabled
    $customer | Add-Member SecurityDefaultsEnabled $Data2.isEnabled

    $UserObj = foreach ($user in $users) {
        [PSCustomObject]@{
            'Display name'      = $user.displayname
            "Legacy MFA Enabled"       = ($MFAStatus | Where-Object { $_.UserPrincipalName -eq $user.userPrincipalName}).'MFA Status'
            "MFA Registered through Security Defaults or CA Policy" = ($MFA2 | where-object { $_.userPrincipalName -eq $user.userPrincipalName}).'MFA Registration Status'
        }

    }
     $tenantObj= [PSCustomObject]@{
          'Customer Name' = $customer.name
          'Security Defaults Enabled' = $customer.SecurityDefaultsEnabled
          'Conditional Access Policies' = $customer.ConditionalAccessPolicies
      } 
    $conditionalAccessObj = foreach ($policy in $CAPolicy) {
        [PSCustomObject]@{
            'Conditiona  Access Policy' = $policy.displayname

        }  
    $customObj = [PSCustomObject]@{
            'CustomControl'  = $CAPolicy.grantControls.customAuthenticationFactors

        }
}

    New-HTML {
            New-HTMLSection -Invisible {
                New-HTMLSection -HeaderText 'Users' {
                    New-HTMLTable -DataTable $UserObj -EnableScroller -Style display -Buttons excelHtml5, pdfHtml5, copyHtml5, searchPanes

                }
     
            }
            New-HTMLSection -Invisible {
                New-HTMLSection -HeaderText "Tenant Policies" {
                    New-HTMLTable -DataTable $tenantObj -Style display -FixedHeader
                }
                 New-HTMLSection -HeaderText "Conditional Access Policies" {
                    New-HTMLTable -DataTable $conditionalAccessObj  -Style display -FixedHeader
                }
                New-HTMLSection -HeaderText "Custom Control" {
                    New-HTMLTable -DataTable $customObj -Style display -FixedHeader
                }
}

               


     }-FilePath "C:\temp\$($Customer.DefaultDomainName).html" -Online

}