Clear-Host
$startTime = (Get-Date)
$FormatEnumerationLimit=-1
#region Notes

#endregion Notes

IF ($PSVersionTable.PSVersion.Major -lt '7') {
	Write-Host -ForegroundColor Yellow	'Please update your version of powershell to the latest version.'
    # Install latest version of powershell:
    # https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/PowerShell-7.2.1-win-x64.msi
}


# Azure Active Directory -> App registrations -> Select Account -> Application (client) ID
$client_ID = 'XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXX'
# Azure Active Directory -> App registrations -> Select Account -> Directory (tenant) ID
$Tenant_ID = 'XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXX'
# Azure Active Directory -> App registrations -> Select Account -> Certificates & secrets -> Client secrets -> "Secret Value"  ((NOT Secret ID))
$Secret_ID = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'

$Account_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$dnsSuffix = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$grant_type="client_credentials"
$resource="https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

$URI="https://login.microsoftonline.com/$($Tenant_ID)/oauth2/v2.0/token" #using the oauth version 2
$CONTENT_TYPE="application/x-www-form-urlencoded"#,'application/json'

$ACCESS_TOKEN_HEADERS = @{
    "Content-Type"=$CONTENT_TYPE
}

$BODY="grant_type=$($grant_type)&client_id=$($client_ID)&client_secret=$($Secret_ID)&scope=$($resource)"
$ACCESS_TOKEN = (Invoke-RestMethod -method POST -Uri $URI -Headers $ACCESS_TOKEN_HEADERS -Body $BODY).access_token

$DATE = [System.DateTime]::UtcNow.ToString("R")

$HEADERS = @{
    "x-ms-date"=$DATE 
    "x-ms-version"="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" 
    "authorization"="Bearer $ACCESS_TOKEN"
}

$Containers_URL = "https://$($Account_Name).$($dnsSuffix)/?recursive=true&resource=account"

$Containers_Response = (Invoke-RestMethod -Method Get -Uri $Containers_URL -Headers $HEADERS)

$Containers = 'devtest' #$Containers_Response.filesystems.Name

ForEach ($Container in $Containers) {
    
    $Container_URL = "https://$($Account_Name).$($dnsSuffix)/$($Container)?recursive=true&resource=filesystem"
    
    $Container_Response = (Invoke-RestMethod -Method Get -Uri $Container_URL -Headers $HEADERS)

    ForEach ($R in $Container_Response.paths) {
        #$Service_Principal = $null
        $Service_Principal = New-Object PSObject
        #$R.owner = $null
        #$Azure_AD_Users_Response = $null
        If ($R.IsDirectory -eq $true) {
            IF ($R.owner -ne '$superuser') {
                $UH_resource="https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
                $UH_BODY="grant_type=$($grant_type)&client_id=$($client_ID)&client_secret=$($Secret_ID)&scope=$($UH_resource)"
                $UH_ACCESS_TOKEN = (Invoke-RestMethod -method POST -Uri $URI -Headers $ACCESS_TOKEN_HEADERS -Body $UH_BODY).access_token
                $UH_DATE = [System.DateTime]::UtcNow.ToString("R")
                $UH_HEADERS = @{
                    "x-ms-date"=$UH_DATE 
                    "x-ms-version"="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" 
                    "authorization"="Bearer $UH_ACCESS_TOKEN"
                }
                $Azure_AD_Users_URL = "https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/users/$($R.owner)"
                Try {
                    $Service_Principal | add-member Noteproperty Container_Name $Container
                    $Service_Principal | add-member Noteproperty Container_FileSytemName $R.Name
                    
                    $Azure_AD_Users_Response = (Invoke-RestMethod -Method Get -Uri $Azure_AD_Users_URL -Headers $UH_HEADERS)
                    $Service_Principal | add-member Noteproperty Container_FileSytemName_Owner $Azure_AD_Users_Response.DisplayName
                }
                Catch {
                    IF ($_.ErrorDetails.Message -like "*does not exist or one of its queried reference-property objects are not present*") {
                        $Service_Principal | add-member Noteproperty Container_FileSytemName_Owner $R.owner
                    }
                    Else {
                        $_.ErrorDetails
                    }
                }
                $Service_Principal | add-member Noteproperty Container_FileSytemName_Permissions $R.Permissions
            }
            else {
                $Service_Principal | add-member Noteproperty Container_Name $Container
                $Service_Principal | add-member Noteproperty Container_FileSytemName $R.Name 
                $Service_Principal | add-member Noteproperty Container_FileSytemName_Owner $R.owner
                $Service_Principal | add-member Noteproperty Container_FileSytemName_Permissions $R.Permissions    
            }
            $Action = 'getAccessControl'

            $Test_Response = (Invoke-WebRequest -Method Head -Uri "https://$($Account_Name).$($dnsSuffix)/$($Container)/$($R.Name)?action=$($Action)&upn=$($true)" -Headers $HEADERS)
            $CurrentAcl = $Test_Response.Headers["x-ms-acl"]
            $Split_1 = $CurrentAcl -split ","
            ForEach ($User in $Split_1) {
                #$Service_Principal = New-Object PSObject
            
                $UH_resource="https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
                $UH_BODY="grant_type=$($grant_type)&client_id=$($client_ID)&client_secret=$($Secret_ID)&scope=$($UH_resource)"
                $UH_ACCESS_TOKEN = (Invoke-RestMethod -method POST -Uri $URI -Headers $ACCESS_TOKEN_HEADERS -Body $UH_BODY).access_token
                $UH_DATE = [System.DateTime]::UtcNow.ToString("R")
                $UH_HEADERS = @{
                    "x-ms-date"=$UH_DATE 
                    "x-ms-version"="2022-12-12" 
                    "authorization"="Bearer $UH_ACCESS_TOKEN"
                }
            
                If ($User -match '^(user::)') {
                    #$SUserName = ($User -split ":")
                    $User = ($User -split ":")
                    $Service_Principal | add-member Noteproperty ACL_UserType 'OwnerUser' -Force
                    $Service_Principal | add-member Noteproperty ACL_UserName '$superuser' -Force
                    $Service_Principal | add-member Noteproperty ACL_Permissions $User[2] -Force
                    $Service_Principal | add-member Noteproperty ACL_User_DisplayName '$superuser' -Force
                }
                If ($User -match '^(group::)') {
                    #$GUserName = ($User -split ":")
                    $User = ($User -split ":")
                    $Service_Principal | add-member Noteproperty ACL_UserType 'OwnerGroup' -Force
                    $Service_Principal | add-member Noteproperty ACL_UserName '$superuser' -Force
                    $Service_Principal | add-member Noteproperty ACL_Permissions $User[2] -Force
                    $Service_Principal | add-member Noteproperty ACL_User_DisplayName '$superuser' -Force
                }
                If ($User -match '^(default:user::)') {
                    #$DUserName = ($User -replace 'default:','default_') -split ":" 
                    $User = ($User -replace 'default:','default_') -split ":" 
                    $Service_Principal | add-member Noteproperty ACL_UserType 'Default_User' -Force
                    $Service_Principal | add-member Noteproperty ACL_UserName '$superuser' -Force
                    $Service_Principal | add-member Noteproperty ACL_Permissions $User[2] -Force
                    $Service_Principal | add-member Noteproperty ACL_User_DisplayName '$superuser' -Force
                }
                If ($User -match '^(default:group::)') {
                    #$DGUserName = ($User -replace 'default:','default_') -split ":" 
                    $User = ($User -replace 'default:','default_') -split ":"
                    $Service_Principal | add-member Noteproperty ACL_UserType 'Default_Group' -Force
                    $Service_Principal | add-member Noteproperty ACL_UserName '$superuser' -Force
                    $Service_Principal | add-member Noteproperty ACL_Permissions $User[2] -Force
                    $Service_Principal | add-member Noteproperty ACL_User_DisplayName '$superuser' -Force
                }
                IF ($User -match '^(mask::)' -or $User -match '^(other::)') {
                    #$MO_User = ($User -replace 'default:','default_') -split ":"
                    $User = ($User -replace 'default:','default_') -split ":"
                    $Service_Principal | add-member Noteproperty ACL_UserType $User[0] -Force
                    $Service_Principal | add-member Noteproperty ACL_UserName $User[0] -Force
                    $Service_Principal | add-member Noteproperty ACL_Permissions $User[2] -Force
                    $Service_Principal | add-member Noteproperty ACL_User_DisplayName $User[0] -Force
                }
                IF ($User -match '^(default:mask::)' -or $User -match '^(default:other::)') {
                    #$DMO_User = ($User -replace 'default:','default_') -split ":"
                    $User = ($User -replace 'default:','default_') -split ":"
                    $Service_Principal | add-member Noteproperty ACL_UserType $User[0] -Force
                    $Service_Principal | add-member Noteproperty ACL_UserName $User[0] -Force
                    $Service_Principal | add-member Noteproperty ACL_Permissions $User[2] -Force
                    $Service_Principal | add-member Noteproperty ACL_User_DisplayName $User[0] -Force
                }
                IF ($User -match '^(user:)[^:](.*)') {
                    #$A_User = ($User -split ":")
                    $User = ($User -split ":")
                    $Service_Principal | add-member Noteproperty ACL_UserType $User[0] -Force
                    $Service_Principal | add-member Noteproperty ACL_UserName $User[1] -Force
                    $Service_Principal | add-member Noteproperty ACL_Permissions $User[2] -Force
                    Try {
                        $Azure_AD_Users_URL = "https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/v1.0/users/$($User[1])"
                        $Azure_AD_Users_Response = (Invoke-RestMethod -Method Get -Uri $Azure_AD_Users_URL -Headers $UH_HEADERS)
                        $Service_Principal | add-member Noteproperty ACL_User_DisplayName $Azure_AD_Users_Response.displayName -Force
                    }
                    Catch {
                        IF ($_.ErrorDetails.Message -like "*does not exist or one of its queried reference-property objects are not present*") {
                            Try {
                                $Azure_AD_Users_URL = "https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/v1.0/groups/$($User[1])"
                                $Azure_AD_Users_Response = (Invoke-RestMethod -Method Get -Uri $Azure_AD_Users_URL -Headers $UH_HEADERS)
                                $Service_Principal | add-member Noteproperty ACL_User_DisplayName $Azure_AD_Users_Response.displayName -Force
                            }
                            Catch {
                                IF ($_.ErrorDetails.Message -like "*does not exist or one of its queried reference-property objects are not present*") {
                                    Try {
                                        $Azure_AD_Users_URL = "https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/servicePrincipals/$($User[1])"
                                        $Azure_AD_Users_Response = (Invoke-RestMethod -Method Get -Uri $Azure_AD_Users_URL -Headers $UH_HEADERS)
                                        $Service_Principal | add-member Noteproperty ACL_User_DisplayName $Azure_AD_Users_Response.displayName -Force
                                    }
                                    Catch {
                                        IF ($_.ErrorDetails.Message) {
                                            $Service_Principal | add-member Noteproperty ACL_User_DisplayName $User[1] -Force
                                            $_.ErrorDetails.Message
                                        }
                                        Else {
                                            $_.ErrorDetails
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                IF ($User -match '(?<=default:user:)[^:](.*)(?=:)') {
                    #$Default_User = ($User -replace 'default:','default_') -split ":"
                    $User = ($User -replace 'default:','default_') -split ":"
                    $Service_Principal | add-member Noteproperty ACL_UserType $User[0] -Force
                    $Service_Principal | add-member Noteproperty ACL_UserName $User[1] -Force
                    $Service_Principal | add-member Noteproperty ACL_Permissions $User[2] -Force
                    Try {
                        $Azure_AD_Users_URL = "https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/users/$($User[1])"
                        $Azure_AD_Users_Response = (Invoke-RestMethod -Method Get -Uri $Azure_AD_Users_URL -Headers $UH_HEADERS)
                        $Service_Principal | add-member Noteproperty ACL_User_DisplayName $Azure_AD_Users_Response.displayName -Force
                    }
                    Catch {
                        IF ($_.ErrorDetails.Message -like "*does not exist or one of its queried reference-property objects are not present*") {
                            Try {
                                $Azure_AD_Users_URL = "https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/groups/$($User[1])"
                                $Azure_AD_Users_Response = (Invoke-RestMethod -Method Get -Uri $Azure_AD_Users_URL -Headers $UH_HEADERS)
                                $Service_Principal | add-member Noteproperty ACL_User_DisplayName $Azure_AD_Users_Response.displayName -Force
                            }
                            Catch {
                                IF ($_.ErrorDetails.Message -like "*does not exist or one of its queried reference-property objects are not present*") {
                                    Try {
                                        $Azure_AD_Users_URL = "https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/servicePrincipals/$($User[1])"
                                        $Azure_AD_Users_Response = (Invoke-RestMethod -Method Get -Uri $Azure_AD_Users_URL -Headers $UH_HEADERS)
                                        $Service_Principal | add-member Noteproperty ACL_User_DisplayName $Azure_AD_Users_Response.displayName -Force
                                    }
                                    Catch {
                                        IF ($_.ErrorDetails.Message) {
                                            $Service_Principal | add-member Noteproperty ACL_User_DisplayName $User[1] -Force
                                            $_.ErrorDetails.Message
                                        }
                                        Else {
                                            $_.ErrorDetails
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                $Service_Principal | Format-List
            }
        }
    }
}
$endTime = (Get-Date)
Write-Host -ForegroundColor Cyan -BackgroundColor Yellow "Time to Complete ACL Report for Container: $Container  Time: $(($endTime-$startTime).TotalSeconds)"
