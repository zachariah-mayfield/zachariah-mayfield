CLS


Function Add-Office365Alias {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [String]$UserName = "xxxxx",
    [String]$NewEmailAlias = "xxxxx"
)

Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}#END BEGIN
Process{
####################################################################################################################################################
####################################################################################################################################################

$EmailAlias = (Get-Mailbox -Identity $UserName).EmailAddresses

$NewEmailAlias = 'SMTP:' + $NewEmailAlias

$NewEmailAliasList = $EmailAlias + $NewEmailAlias 

Set-Mailbox -Identity $UserName -EmailAddresses $NewEmailAliasList

(Get-Mailbox -Identity $UserName).EmailAddresses

####################################################################################################################################################
####################################################################################################################################################
}#END Process
END {}#END END
}# END Function Add-Office365Alias

Add-Office365Alias

