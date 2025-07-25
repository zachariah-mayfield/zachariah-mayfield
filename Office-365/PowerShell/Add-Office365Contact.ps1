CLS

Function Add-Office365Contact {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [String]$CSVLocation = "C:\Contacts.csv"
)

Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}#END BEGIN
Process{
####################################################################################################################################################
####################################################################################################################################################

$EmailList = @(
Import-Csv $CSVLocation|
ForEach-Object {
$ExternalEmailAddress = ($_."additional_contacts")
$ExternalEmailAddress = $ExternalEmailAddress.TrimEnd(",")
$ExternalEmailAddress = $ExternalEmailAddress.Split(",")
$ExternalEmailAddress = $ExternalEmailAddress.Trim()
$ExternalEmailAddress
}
)

ForEach ($Email in $EmailList) {
    If (Get-MailContact -Anr $Email) {
        Write-Host -ForegroundColor Yellow $Email 'is a already an Office 365 Contact.'
    }
    Else {
        New-MailContact -Name $Email -ExternalEmailAddress $Email -Verbose    
    }
}

####################################################################################################################################################
####################################################################################################################################################
}#END Process
END {}#END END
}# END Function 



