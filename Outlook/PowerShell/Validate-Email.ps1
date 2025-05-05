CLS


Function Validate-Email {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [parameter(mandatory=$true)]
    [ValidatePattern("^[a-zA-Z0-9.!£#$%&'^_`{}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$")] # RegEx Email Validation
    [ValidateScript({($Email -as [System.Net.Mail.MailAddress]).Address -eq $Email})]
    [string]$Email
    )
Begin{
#######################################################################################################################################################
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
# This sets the warring preference
$WarningPreference = "SilentlyContinue"
#######################################################################################################################################################
}
Process {

# Setting the variable for to Check the Shared MailBox for the $Email Param supplied. 
$CheckShared = (Get-Mailbox -Identity $Email).PrimarySmtpAddress

IF ($CheckShared -ne $null) {

    Write-Host -ForegroundColor Yellow "$CheckShared is a valid email shared mailbox."

}
Else {

    Write-Host -ForegroundColor Red "$Email is not a valid email shared mailbox."

}

}
END {}

}#END Function Validate-Email

Validate-Email -Email "testemailaccount@Company-x.com"