CLS



Function Delete-CMDB {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
        [Parameter(ParameterSetName="Action")]
        [ValidateSet("New","Update","Delete")]
        [String]$Action,
        [String]$ServerName = "xxx",
        [String]$OwnerEmail = "xxx@xxx.com",
        [String[]]$Additional_Contacts = "xxx"
    )

Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}

Process {

######################################################################################################
######################################################################################################

IF ($Action -eq "Delete") {
    Write-Host -ForegroundColor Cyan $Action

    $Group = Get-DistributionGroup -Identity $ServerName

IF ($Group) {
    Remove-DistributionGroup -Identity $ServerName -Confirm:$false -Verbose
} Else {
    Write-Host -ForegroundColor Yellow $ServerName "does not exist."
}

}

######################################################################################################
######################################################################################################

}# END Proccess
END {}
}# END Function 
