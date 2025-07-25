CLS

<#
.SYNOPSIS
Function 
    Remove-Office365DistroGroup
.DESCRIPTION
This Function is designed to 

.EXAMPLE
    Remove-Office365DistroGroup -DistroGroup "!Payment Management Vendors"
.PARAMETER 

.NOTES
AUTHOR Zack Mayfield

$UserCredential = Get-Credential

$URL = "https://outlook.office365.com/powershell-liveid/"

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $URL -Credential $UserCredential -Authentication Basic -AllowRedirection

Import-PSSession $Session

#>

Function Remove-Office365DistroGroup {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String]$DistroGroup=""
    )

Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}#END BEGIN
Process{
####################################################################################################################################################
####################################################################################################################################################

$Group = Get-DistributionGroup -Identity $DistroGroup

IF ($Group) {
    Remove-DistributionGroup -Identity $DistroGroup -Confirm:$false -Verbose
} Else {
    Write-Host -ForegroundColor Yellow $DistroGroup "does not exist."
}

####################################################################################################################################################
####################################################################################################################################################
}#END Process
END {}#END END
}# END Function Remove-Office365DistroGroup
