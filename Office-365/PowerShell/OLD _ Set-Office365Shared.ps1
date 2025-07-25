CLS


Function Set-Office365Shared {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [parameter(mandatory=$false)]
    [ValidateSet("Create","Edit","Delete")]
    [String]$Action,

    [parameter(mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String[]]$SharedBox,

    [parameter(mandatory=$true)]
    [ValidatePattern("^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")] # RegEx Email Validation
    [System.Net.Mail.MailAddress]$Email,

    [Parameter()]
    [ValidateNotNullOrEmpty()] 
    [String[]]$GroupMember,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("AddMember","RemoveMember")]
    [String]$MemberAction,

    [Parameter()]
    [ValidateNotNullOrEmpty()] 
    [String[]]$Owner,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("AddOwner","RemoveOwner")]
    [String]$OwnerAction,

    [Parameter()]
    [ValidateSet("Yes","No","Null")]
    [String]$AllowOutsideSenders
    )
Begin{
#######################################################################################################################################################
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
# This sets the warring preference
$WarningPreference = "SilentlyContinue"

}#END Begin
Process {
# Trimming the White space from the Shared MailBox
$SharedBox = $SharedBox.Trim()

# Setting the variable for to Check the Shared MailBox for the $Email Param supplied. 
$CheckShared = (Get-Mailbox -Identity $Email).PrimarySmtpAddress

Try {
    # If statement to check that the above is true.
    If ($CheckShared -notmatch $Email) {
        # New-Mailbox -Shared:$True -Name $SharedBox -PrimarySmtpAddress $Email -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
        Write-Output ("The Shared MailBox `"$SharedBox`" Does not exist. This function is now creating the Shared MailBox.")
    } Else {
        Write-Output ("The Shared MailBox `"$SharedBox`" already exists.")
    }
}
Catch {
    Write-Output ("Issue Creating Shared MailBox `"$SharedBox`"")
    Write-Error -Message $_.Exception.Message
}



}#END Process
END {<#GSN|RSN#>}
}#END Function

Set-Office365Shared -SharedBox "Test Email Account" -Email "testemailaccount@Company-x.com"