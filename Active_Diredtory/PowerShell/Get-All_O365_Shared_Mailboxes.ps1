CLS

Function Get-AllO365SharedMailboxes {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param ()
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
# This sets the warring preference
$WarningPreference = "SilentlyContinue"
}#END BEGIN
Process {
    (Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize:Unlimited | Select DisplayName, PrimarySmtpAddress)
}
END {}
}#END Function

Get-AllO365SharedMailboxes | Export-Csv -Path D:\Folder\O365SharedMailboxes.CSV -Force -NoTypeInformation


