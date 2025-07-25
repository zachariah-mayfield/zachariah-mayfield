CLS

Function Get-AllO365ConferenceRooms {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param ()
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
# This sets the warring preference
$WarningPreference = "SilentlyContinue"
}#END BEGIN
Process {
    (Get-Mailbox -RecipientTypeDetails RoomMailbox -ResultSize:Unlimited | Select DisplayName, PrimarySmtpAddress)
}
END {}
}#END Function

Get-AllO365ConferenceRooms | Export-Csv -Path D:\ServiceNow_Data\Office_365\O365ConferenceRooms.CSV -Force -NoTypeInformation
