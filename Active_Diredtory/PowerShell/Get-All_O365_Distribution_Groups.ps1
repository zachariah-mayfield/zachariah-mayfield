CLS

Function Get-AllO365DistributionGroups {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param ()
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
# This sets the warring preference
$WarningPreference = "SilentlyContinue"
}#END BEGIN
Process {
((Get-DistributionGroup -Filter {(name -like "*") -and (HiddenFromAddressListsEnabled -eq $false)} -ResultSize Unlimited) | 
    Where {$_.PrimarySmtpAddress -notmatch "UserName@Company.com" -and
    $_.PrimarySmtpAddress -notmatch "UserName@Company.com" -and 
    $_.PrimarySmtpAddress -notmatch "UserName@Company.com" -and
    $_.PrimarySmtpAddress -notmatch "UserName@Company.com"} | 
    Select DisplayName, PrimarySmtpAddress)
}
END {}
}#END Function Get-AllO365DistributionGroups

Get-AllO365DistributionGroups | Export-Csv -Path D:\Folder\O365DistributionGroups.CSV -Force -NoTypeInformation
