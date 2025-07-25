<#
 
.SYNOPSIS
    Function Remove-O365MailAttributes
  
.NAME
    Remove-O365MailAttributes

.AUTHORS
    x

.DESCRIPTION
    This Function is designed to 
  
.EXAMPLE
    Remove-O365MailAttributes

.EXAMPLE
    Remove-O365MailAttributes

.PARAMETER -Identity
    This will 
    
.PARAMETER -Attributexx
    This will 


#>

Function Remove-O365MailAttributes {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [String]$Identity=""
    )
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}#END BEGIN
Process{

$user = Get-ADUser -Identity $Identity -Properties *
$Mail = $user.UserPrincipalName


If ($user.mail -like "*@xxxxxx.com") {

$user.mail = $null
$user.extensionAttributexx = $null
$user.extensionAttributexx = $null
$user.proxyaddresses =$null
Set-ADUser -Instance $user 

Write-Host -ForegroundColor Yellow "Removing O365 Attributes..."
Write-Host -ForegroundColor Cyan "Successfully removed O365 attributes. Details below:"

Write-host -ForegroundColor Cyan "User Mail is" $user.mail
Write-host -ForegroundColor Cyan "User extensionAttribute77 is" $user.extensionAttribute77
Write-host -ForegroundColor Cyan "User extensionAttribute88 is" $user.extensionAttribute88
Write-host -ForegroundColor Cyan "User extensionAttribute99 is" $user.extensionAttribute99

Write-host -ForegroundColor Cyan "User User Proxy is" $user.proxyaddresses

}
Else {
Write-Host -ForegroundColor Cyan "Mail Attribute is not an AccessCompany.com email account."
}


}#END Process
END {}#END END
}# END Function Remove-O365MailAttributes

