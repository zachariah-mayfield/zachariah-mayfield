CLS



Function Update-CMDB {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
        [Parameter(ParameterSetName="Action")]
        [ValidateSet("New","Update","Delete")]
        [String]$Action,
        [String]$ServerName = "xxx12",
        [String]$OwnerEmail = "administrator@Companys2.onmicrosoft.com",
        [String[]]$Additional_Contacts = ("x@123.com", "x@678.com", "x@123.com", "x@888.com", "x@678.com")
    )

Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}

Process {

######################################################################################################
######################################################################################################

IF ($Action -eq "Update") {
    
    Write-Host -ForegroundColor Cyan "Action: " $Action
    
    ForEach ($Contact in $Additional_Contacts) {
    
        If (Get-MailContact -Anr $Contact) {
            Write-Host -ForegroundColor Yellow $Contact 'is a already an Office 365 Contact.'
        }
        Else {
            New-MailContact -Name $Contact -ExternalEmailAddress $Contact -Verbose    
        }

        $CheckDG = Get-DistributionGroup -Identity $ServerName -ErrorAction SilentlyContinue

        If ($CheckDG -eq $null) {
            Write-Host -ForegroundColor Cyan "The Distribution Group $ServerName Does not exist."
        }
        Else {
            Write-Host -ForegroundColor Cyan "The Distribution Group $ServerName already exists."
        }

        $CheckDGM1 = Get-DistributionGroupMember -Identity $ServerName ################

        IF ($CheckDGM1 -match $Contact){
            Write-Host -ForegroundColor Cyan $Contact "is already a member of the Distribution Group" $ServerName
        }
        ELSE {
            Add-DistributionGroupMember -Identity $ServerName -Member $Contact -BypassSecurityGroupManagerCheck -Verbose -Confirm:$false
        }
    }#END ForEach ($Contact in $Additional_Contacts)

    $CheckDGM2 = Get-DistributionGroupMember -Identity $ServerName

    ForEach ($Contact in $CheckDGM2) {
        IF ($Contact -notin $Additional_Contacts) {
            Write-Host -ForegroundColor Yellow "Removing user: " $Contact
            Remove-DistributionGroupMember -Identity $ServerName -Member $contact.name -BypassSecurityGroupManagerCheck -Confirm:$False -Verbose
        } 
    }

    ForEach ($Contact in $Additional_Contacts) {
        IF ($Contact -notin $CheckDGM2.name) {
            Write-Host -ForegroundColor Green "Adding user: " $Contact
            Add-DistributionGroupMember -Identity $ServerName -Member $Contact -BypassSecurityGroupManagerCheck -Verbose -Confirm:$false 
        }
    }

}

######################################################################################################
######################################################################################################

}# END Proccess
END {}
}# END Function Update-CMDB 
