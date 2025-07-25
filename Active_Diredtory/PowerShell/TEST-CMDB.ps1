CLS

#This is the new form list from 
[String[]]$Additional_Contacts = ("xxx@123.com", "xxx@678.com", "xxx@555.com")

$ServerName = "xxxxxxx"

#this is the current Distribution list in office 365 
$Checkxxx = Get-DistributionGroupMember -Identity $ServerName

    ForEach ($Contact in $Checkxxx) {
        IF ($Contact -notin $Additional_Contacts) {
            Write-Host -ForegroundColor Yellow "Removing user: " $Contact
            Remove-DistributionGroupMember -Identity $ServerName -Member $contact.name -BypassSecurityGroupManagerCheck -Confirm:$False -Verbose`
        } 
    }


<#

ForEach ($Contact in $Additional_Contacts) {
    IF ($Contact -notin $Checkxxx.name) {
        Write-Host -ForegroundColor Green $Contact "ADD" 
    }

}


#>