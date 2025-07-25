## Import necessary modules
Import-Module MSOnline 
Import-Module ActiveDirectory
Clear-Host # For readability in the console


## Set Needed Variables for Logging
$TimeStamp = Get-Date -format yyyyMMdd
$ActualTime = Get-Date -format "yyyy-MM-dd hh:mm:ss"
$LogFile = "C:\$TimeStamp.log"
$LogContent = @()
$NoChangeCounter = 0


## Start Log
"----------------------------------------------" | Add-Content $LogFile
"$ActualTime Starting..." | Add-Content $LogFile


## Get Connected to MSOL
$User = "O365xxx@Company.onmicrosoft.com"
$Hash = "C:\Hash.txt"
[Byte[]]$Key = (9,8,8,8,6,4,4,3,6,7,3,9,5,9,4,3)
$Pass = Get-Content $Hash | ConvertTo-SecureString -Key $Key
$Credential = New-Object -typename System.Management.xxx.PSCredential -argumentlist $User, $Pass
TRY { Connect-MsolService -Credential $Credential -ErrorAction Stop }
CATCH { 
    "Could not connect to MSOL; Exiting script..." | Add-Content $LogFile
    "$ActualTime Complete." | Add-Content $LogFile
    "`n`n----------------------------------------------`n`n" | Add-Content $LogFile
    Exit 
}


## AD Group names for Office365 Sync
$Group = "O365"             # This group gets ALL OPTIONS


## SkuIDs
$AccountSkuID = "Company:ENTERPRISEPACK"   # E3 SKU
$RemoveSku = "Company:DESKLESSPACK"        # K1 SKU

## Get group members
$members = @()
$members = (Get-ADGroupMember -Identity $Group | % { get-aduser $_ | select userprincipalname } ).UserPrincipalName | Sort


## Ensure E3 exists, and proper options are set
$LicenseOptions = ""
$LicenseOptions = New-MsolLicenseOptions –AccountSkuId $AccountSkuID

# For Each User in the AD Group
foreach ($upn in $members) {

##** EXPERIMENTAL "IF" for User Flags
#$Flag = "C:\xxx$upn.flag"
#IF ( !(Test-Path $Flag) -or ( (Get-ChildItem $Flag).LastWriteTime -lt (Get-Date).AddDays(-1) ) ) {
##** End Experiment
    
    ## Check usage location, and set if not already "US"
    $usageLocation = (Get-MsolUser -User $upn).usagelocation
    IF ( ($usageLocation -eq $null) -or ($usageLocation -ne "US") ) {Set-MsolUser -UserPrincipalName $upn -UsageLocation "US"} 
    
    # Validate that license settings are right for E3
    $LicenseServiceSetup = "Good"
    $License = (Get-MsolUser -UserPrincipalName $upn).Licenses | Where-Object { $_.AccountSkuID -eq $AccountSkuID }
    $License.ServiceStatus | ForEach {
            
        # SWAY
        If ($_.ServicePlan.ServiceName -eq "SWAY" –and $_.ProvisioningStatus -eq "Disabled") { $LicenseServiceSetup = "Bad" }                  #Enable
            
        # YAMMER
        If ($_.ServicePlan.ServiceName -eq "YAMMER_ENTERPRISE" –and $_.ProvisioningStatus -eq "Disabled") { $LicenseServiceSetup = "Bad" }     #Enable
            
        # Azure Rights Management
        If ($_.ServicePlan.ServiceName -eq "RMS_S_ENTERPRISE" –and $_.ProvisioningStatus -eq "Disabled") { $LicenseServiceSetup = "Bad" }      #Enable
            
        #Office Subscription
        If ($_.ServicePlan.ServiceName -eq "OFFICESUBSCRIPTION" –and $_.ProvisioningStatus -eq "Disabled") { $LicenseServiceSetup = "Bad" }    #Enable
            
        # Lync/Skype for Business (MCOSTANDARD)
        If ($_.ServicePlan.ServiceName -eq "MCOSTANDARD" –and $_.ProvisioningStatus -eq "Disabled") { $LicenseServiceSetup = "Bad" }           #Enable
            
        # SHAREPOINTWAC (Office Online) is dependent on SHAREPOINTENTERPRISE (Sharepoint Online)
        If ($_.ServicePlan.ServiceName -eq "SHAREPOINTWAC" –and $_.ProvisioningStatus –eq "Disabled") { $LicenseServiceSetup = "Bad" }         #Enable
            
        # SharePoint Online
        If ($_.ServicePlan.ServiceName -eq "SHAREPOINTENTERPRISE" -and $_.ProvisioningStatus -eq "Disabled") { $LicenseServiceSetup = "Bad" }  #Enable
            
        # Exchange Online
        If ($_.ServicePlan.ServiceName -eq "EXCHANGE_S_ENTERPRISE" -and $_.ProvisioningStatus -eq "Disabled") { $LicenseServiceSetup = "Bad" } #Enable
    }

    # IF the user doesn't have an E3 license, set him/her up with one
    $upnLicenses = (Get-MsolUser -UserPrincipalName $upn).Licenses
    IF ( $upnLicenses.AccountSkuId -notcontains $AccountSkuID ) 
    { 
        Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $AccountSkuID #-RemoveLicenses $RemoveSku
        Set-MsolUserLicense –UserPrincipalName $upn –LicenseOptions $LicenseOptions
        Write-Host "$upn - E3 and all license options added;" -ForegroundColor Green
        $LogContent += "$upn - E3 and all license options added;"
    }
        
    # IF the user does have an E3 license, make sure it has the correct options (E.g. none are set to Bad)
    ELSE
    { 
        IF ($LicenseServiceSetup -eq "Good") 
        {
            Write-Host "$upn - No changes needed;" -ForegroundColor Cyan
            $NoChangeCounter++
            ##** EXPERIMENTAL - If User was already validated, created a success flag
            ##** The success flag omits the user from being checked for a day
            #$ActualTime | Add-Content "C:\xxx$upn.flag"
            ##** END EXPERIMENT
        }

        IF ($LicenseServiceSetup -eq "Bad")
        { 
            Set-MsolUserLicense –UserPrincipalName $upn –LicenseOptions $LicenseOptions
            Write-Host "$upn - E3 already provisioned, but license options were updated;" -ForegroundColor Yellow
            $LogContent += "$upn - E3 already provisioned, but license options were updated;"
        }
    }   
}#}


## Final Output Log C:\Scripts\O365\Logs\
"$NoChangeCounter users with no license changes needed." | Add-Content $LogFile
$LogContent | Add-Content $LogFile
$ActualTime = Get-Date -format "yyyy-MM-dd hh:mm:ss"
"$ActualTime Complete." | Add-Content $LogFile
"`n`n----------------------------------------------`n`n" | Add-Content $LogFile

## Email the $LogContent
[string]$message = $LogContent
$recipients = @("xxx xxx <xxx.xxx@Company.com>", "xxx xxx <xxx.xxx@Company.com>")

IF (($message -ne "") -and ($message -ne $null)) {
    send-mailmessage `
    -from "o365.xxx@Company-x.com" `
    -to $recipients `
    -subject "License Setup Script Results - O365xxx" `
    -body $message `
    -BodyAsHtml `
    -dno onSuccess, onFailure `
    -smtpServer smtp.Company-x.com
}