CLS


Function Add-Office365Shared {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String]$Identity="",
    [Parameter()]
    [String]$Email="",
    [Parameter()]
    [String[]]$SendAsMember="",
    [Parameter()]
    [String[]]$FullAccessMember="",
    [Parameter()]
    [String]$Department="",
    [Parameter()]
    [String]$Company="",
    [Parameter()]
    [String]$Manager="",
    [Parameter()]
    [String]$Title="",
    [Parameter()]
    [String]$CountryOrRegion ="",
    [Parameter()]
    [String]$City="",
    [Parameter()]
    [String]$StateOrProvince="",
    [Parameter()]
    [String]$PostalCode="",
    [Parameter()]
    [String]$WorkPhone="",
    [Parameter()]
    [String]$MobilePhone="",
    [Parameter()]
    [String]$Fax="",
    [Parameter()]
    [String]$Office="",
    [Parameter()]
    [String]$HomePhone="",
    [Parameter()]
    [String]$WebPage="",
    [Parameter()]
    [String]$Notes="",
    [Parameter()]
    [String]$StreetAddress=""
    )
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}#END BEGIN
Process{
####################################################################################################################################################
####################################################################################################################################################

$Email = $Email.Trim()

$Identity = $Identity.Trim()

$CheckEmail = ($Email -as [System.Net.Mail.MailAddress]).Address -eq $Email -and $Email -ne $null

TRY {
$CheckShared = Get-Mailbox -Identity $Identity -ErrorAction Stop -ErrorVariable "CheckSharedError"
}
Catch {
    $CheckSharedError
}

####################################################################################################################################################
####################################################################################################################################################

TRY {
If ($CheckShared -eq $null -and $CheckEmail -eq $true) {
    Write-Host -ForegroundColor Cyan "The Shared MailBox `"$Identity`" Does not exist. This function is now creating the Shared MailBox."
    New-Mailbox -Shared:$True -Name $Identity -PrimarySmtpAddress $Email -ErrorAction Stop -ErrorVariable "NewMailboxError"
} Else {
    Write-Host -ForegroundColor Cyan "The Shared MailBox `"$Identity`" already exists."
}
}
Catch {
    $NewMailboxError
}

####################################################################################################################################################
####################################################################################################################################################

TRY {
IF ($FullAccessMember) {

ForEach($Name in $FullAccessMember) {
Add-MailboxPermission -Identity $Identity -User $Name -AccessRights ‘FullAccess’ -InheritanceType All -Confirm:$False -ErrorAction Stop -ErrorVariable "AddMailboxPermissionError"
Write-Host -ForegroundColor Cyan "The user `"$Name`" has been added to the Shared MailBox `"$Identity`" with `"FullAccess`" Permissions"
}

}#END IF ($FullAccessMember) 
}
Catch {
    $AddMailboxPermissionError
}

####################################################################################################################################################
####################################################################################################################################################

TRY {
IF ($SendAsMember) {

ForEach($Name in $SendAsMember) {
Add-RecipientPermission -Identity $Identity -Trustee $Name -AccessRights 'SendAs' -Confirm:$False -ErrorAction Stop -ErrorVariable "AddRecipientPermissionError"
Write-Host -ForegroundColor Cyan "The user `"$Name`" has been added to the Shared MailBox `"$Identity`" with `"Send AS`" Permissions"
}

}#END IF ($SendAsMember)
}
Catch {
    $AddRecipientPermissionError
}

####################################################################################################################################################
####################################################################################################################################################


TRY {
IF ($Department){
    Set-User -Identity $Identity -Department $Department -ErrorAction Stop -ErrorVariable "DepartmentError"
}
}
Catch {
    $DepartmentError
}

TRY {
IF ($CountryOrRegion){
    Set-User -Identity $Identity -CountryOrRegion $CountryOrRegion -ErrorAction Stop -ErrorVariable "CountryOrRegionError"
}
}
Catch {
    $CountryOrRegionError
}

TRY {
IF ($City){
    Set-User -Identity $Identity -City $City -ErrorAction Stop -ErrorVariable "CityError"
}
}
Catch {
    $CityError
}

TRY {
IF ($StateOrProvince){
    Set-User -Identity $Identity -StateOrProvince $StateOrProvince -ErrorAction Stop -ErrorVariable "StateOrProvinceError"
}
}
Catch {
    $StateOrProvinceError
}

TRY {
IF ($PostalCode){
    Set-User -Identity $Identity -PostalCode $PostalCode -ErrorAction Stop -ErrorVariable "PostalCodeError"
}
}
Catch {
    $PostalCodeError
}

TRY {
IF ($HomePhone){
    Set-User -Identity $Identity -HomePhone $HomePhone -ErrorAction Stop -ErrorVariable "HomePhoneError"
}
}
Catch {
    $HomePhoneError
}

TRY {
IF ($MobilePhone){
    Set-User -Identity $Identity -MobilePhone $MobilePhone -ErrorAction Stop -ErrorVariable "MobilePhoneError"
}
}
Catch {
    $MobilePhoneError
}

TRY {
IF ($Fax){
    Set-User -Identity $Identity -Fax $Fax -ErrorAction Stop -ErrorVariable "FaxError"
}
}
Catch {
    $FaxError
}

TRY {
IF ($Office){
    Set-User -Identity $Identity -Office $Office -ErrorAction Stop -ErrorVariable "OfficeError"
}
}
Catch {
    $OfficeError
}

TRY {
IF ($WorkPhone){
    Set-User -Identity $Identity -Phone $WorkPhone -ErrorAction Stop -ErrorVariable "WorkPhoneError"
}
}
Catch {
    $WorkPhoneError
}

TRY {
IF ($WebPage){
    Set-User -Identity $Identity -WebPage $WebPage -ErrorAction Stop -ErrorVariable "WebPageError"
}
}
Catch {
    $WebPageError
}

TRY {
IF ($Notes){
    Set-User -Identity $Identity -Notes $Notes -ErrorAction Stop -ErrorVariable "NotesError"
}
}
Catch {
    $NotesError
}

TRY {
IF ($StreetAddress){
    Set-User -Identity $Identity -StreetAddress $StreetAddress -ErrorAction Stop -ErrorVariable "StreetAddressError"
}
}
Catch {
    $StreetAddressError
}

TRY {
IF ($Company){
    Set-User -Identity $Identity -Company $Company -ErrorAction Stop -ErrorVariable "CompanyError"
}
}
Catch {
    $CompanyError
}

TRY {
IF ($Title){
    Set-User -Identity $Identity -Title $Title -ErrorAction Stop -ErrorVariable "TitleError"
}
}
Catch {
    $TitleError
}

TRY {
IF ($Manager) {
    Set-User -Identity $Identity -Manager $Manager -ErrorAction Stop -ErrorVariable "ManagerError"
}
}
Catch {
    $ManagerError
}




####################################################################################################################################################
####################################################################################################################################################
}#END Process
END {}#END END
}# END Function Add-Office365Shared


