CLS

<#
 
.SYNOPSIS
    Function Add-O365MailAttributes
  
.NAME
    Add-O365MailAttributes

.AUTHORS
    Mayfield 

.DESCRIPTION
    This Function is designed to 
  
.EXAMPLE
    Add-O365MailAttributes -Identity "FirstName.LastName" -Attributexx xxxxx

.EXAMPLE
    Add-O365MailAttributes -Identity "FirstName.LastName" -Attributexx xxxxx

.PARAMETER -Identity
    This will 
    
.PARAMETER -Attributexx
    This will 


#>
Function Add-O365MailAttributes {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String]$Identity="",
    [Parameter(ParameterSetName="Attributexx")]
    [ValidateSet("Pxxxxx","xxxxx")]
    [String]$Attributexx
    )
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}#END BEGIN
Process{

$user = Get-ADUser -Identity $Identity -Properties *

$Mail = $user.UserPrincipalName

If ($user.mail -like "*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx") {
    Write-Host $user.CN "already has an xxx.com email account." -ForegroundColor Cyan
}
Else {


$user.mail = $Mail
$user.extensionAttributexx = "xxxxx"
$user.extensionAttributexx = $Attributexx
$user.extensionAttributexx = $null
Set-ADUser -Instance $user 

Write-Host -ForegroundColor Yellow "Adding O365 Attributes..."
Write-Host -ForegroundColor Cyan "Successfully added O365 attributes. Details below:"

Write-host -ForegroundColor Cyan "User Mail is" $user.mail
Write-host -ForegroundColor Cyan "User extensionAttributexx is" $user.extensionAttributexx
Write-host -ForegroundColor Cyan "User extensionAttributexx is" $user.extensionAttributexx
Write-host -ForegroundColor Cyan "User extensionAttributexx is" $user.extensionAttributexx

Write-host -ForegroundColor Cyan "User User Proxy is" $user.proxyaddresses

}

}#END Process
END {}#END END
}# END Function Add-O365MailAttributes



