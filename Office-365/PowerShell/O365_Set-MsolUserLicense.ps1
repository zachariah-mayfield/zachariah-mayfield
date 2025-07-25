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
$Credential = Get-Credential

## connect to exchange online
$o365 = New-PsSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credential -AllowRedirection -Authentication Basic
Import-PsSession $o365 -AllowClobber

TRY { Connect-MsolService -Credential $Credential -ErrorAction Stop }
CATCH { 
    "Could not connect to MSOL; Exiting script..." | Add-Content $LogFile
    "$ActualTime Complete." | Add-Content $LogFile
    "`n`n----------------------------------------------`n`n" | Add-Content $LogFile
    Exit 
}



## AD Group names for Office365 Sync
$Group = "O365_x"             # This group gets ALL OPTIONS


## SkuIDs
$AccountSkuID = "Company:x"   # ExchangeOnline


## Get group members
#$members = @()
#$members = (Get-ADGroupMember -Identity $Group | % { get-aduser $_ | select userprincipalname } ).UserPrincipalName | Sort


## Ensure E3 exists, and proper options are set
$LicenseOptions = ""
$LicenseOptions = New-MsolLicenseOptions –AccountSkuId $AccountSkuID


# For Each User in the AD Group
foreach ($upn in $members)
{    
    Write-Host "Working on $upn"
    
    ## Check usage location, and set if not already "US"
    $usageLocation = (Get-MsolUser -UserPrincipalName $upn).usagelocation
    IF ( ($usageLocation -eq $null) -or ($usageLocation -ne "US") ) 
    {
        Set-MsolUser -UserPrincipalName $upn -UsageLocation "US"
    } 
    
    # Validate that license settings are right for ExchangeOnline
    $LicenseServiceSetup = "Good"
    $License = (Get-MsolUser -UserPrincipalName $upn).Licenses | Where-Object { $_.AccountSkuID -eq $AccountSkuID }
    $License.ServiceStatus | ForEach {             
        # Exchange Online
        If ($_.ServicePlan.ServiceName -eq "EXCHANGE_S_ENTERPRISE" -and $_.ProvisioningStatus -ne "Success") { $LicenseServiceSetup = "Bad" } #Enable  
    }

    # IF the user doesn't have an ExchangeOnline license, set him/her up with one
    $upnLicenses = (Get-MsolUser -UserPrincipalName $upn).Licenses
    IF ( $upnLicenses.AccountSkuId -notcontains $AccountSkuID ) 
    { 
        Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $AccountSkuID #-RemoveLicenses $RemoveSku
        Set-MsolUserLicense –UserPrincipalName $upn –LicenseOptions $LicenseOptions
        Write-Host "$upn - ExchangeOnline license added;" -ForegroundColor Green
        $LogContent += "$upn - ExchangeOnline license added;"
    }
        
    # IF the user does have an ExchangeOnline license, make sure it has the correct options (E.g. none are set to Bad)
    ELSE
    { 
        IF ($LicenseServiceSetup -eq "Good") 
        {
            Write-Host "$upn - No changes needed;" -ForegroundColor Cyan
            $NoChangeCounter++
        }

        IF ($LicenseServiceSetup -eq "Bad")
        { 
            Set-MsolUserLicense –UserPrincipalName $upn –LicenseOptions $LicenseOptions
            Write-Host "$upn - ExchangeOnline already provisioned, but license options were updated;" -ForegroundColor Yellow
            $LogContent += "$upn - ExchangeOnline already provisioned, but license options were updated;"
        }
    }   
}


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
    -subject "License Setup Script Results - O365_x" `
    -body $message `
    -BodyAsHtml `
    -dno onSuccess, onFailure `
    -smtpServer smtp.Company-x.com
}