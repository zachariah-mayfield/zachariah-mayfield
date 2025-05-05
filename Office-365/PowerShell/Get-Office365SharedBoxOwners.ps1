CLS


Function Get-Office365SharedBoxOwners {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String]$SharedBox = "testemailaccount@Company-x.com"
)
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}#END BEGIN
Process{
####################################################################################################################################################
####################################################################################################################################################

Write-Output "Getting the list of SendAs Owners. . . . . ."

Get-RecipientPermission -Identity $SharedBox | FT -Property Identity,Trustee,AccessRights

Write-Output "Getting the list of FullAccess Owners. . . . ."

Get-MailboxPermission -Identity $SharedBox | FT -Property Identity,User,AccessRights

####################################################################################################################################################
####################################################################################################################################################
}#END Process
END {}#END END
}# END Function Get-Office365SharedBoxOwners

Get-Office365SharedBoxOwners