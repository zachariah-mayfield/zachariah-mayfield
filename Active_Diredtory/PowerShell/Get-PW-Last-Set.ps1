CLS

Function Get-PWLastSet {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String[]]$UserID 
    )
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}#END BEGIN
Process{
####################################################################################################################################################
####################################################################################################################################################

# Check to see if user account is locked out in AD.
# Check to see if user account is disabled in AD.
# Check to see when the last time the users Password has been reset in AD. 
# Get-ADUser $UserID -Properties * | Select-Object Name,SamAccountName,UserPrincipalName,Enabled,LockedOut,PasswordLastSet

# Check to see if user account is locked out in AD LDS.
# Check to see if user account is disabled in AD LDS.
# Check to see when the last time the users Password has been reset in AD LDS. 

# This is the Server Name and Port number that AD LDS is set up on.
$Server = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:389"

# This is the top tree of the AD LDS Tree.
$SearchBase = "DC=xxxxxx-,DC=com"

# This is AD LDS Attribute name for user account status.
$ADLDSAccountStatus = "Company-UserAccountDisabled"

# This sets the $EpochTimeLastPwd variable to $null
$EpochTimeLastPwd = $null

####################################################################################################################################################
####################################################################################################################################################

ForEach ($User in $UserID) {

Try {

# This gets all of the AD User properties
$UserInfo = Get-ADUser -Server $Server -Identity $User -Properties * -ErrorAction SilentlyContinue -ErrorVariable "GetADUser"

# This sets the $UserName variable to the full name of the $UserID
$Name = ($UserInfo | Select-Object Name).name 

$ADPWLastSet = ($UserInfo | Select-Object PasswordLastSet).PasswordLastSet | Get-Date -UFormat "%m/%d/%Y %r"

}#END Try
Catch {
    Write-Host -ForegroundColor Yellow $GetADUser
    Write-Host -ForegroundColor Yellow "Security Permissions is preventing this script from accessing the information."
}

Try {

# Get attribute for specified user. 
$EpochTimeLastPwd = (Get-ADObject -Server $Server -ErrorAction SilentlyContinue -ErrorVariable "GetADObject" -Filter {
(cn -eq $Name) -and (($ADLDSAccountStatus -notlike '*') -or ($ADLDSAccountStatus -notlike 'TRUE'))
} -SearchBase $SearchBase -Properties pwdLastSet).pwdLastSet 

# Only retrun enabled users
If ($EpochTimeLastPwd -ne $null) { 
    $LPWR = (Get-Date 1/1/1601).AddDays($EpochTimeLastPwd/864000000000) 
    #Write-Output "AD LDS PW LastSet :" $LPWR.DateTime
    $ADLDSPWLastSet = $LPWR.DateTime | Get-Date -UFormat "%m/%d/%Y %r"
}Else {
    Write-Host  -ForegroundColor Yellow "AD LDS User not found."
    Write-Host  -ForegroundColor Yellow "OR"
    Write-Host  -ForegroundColor Yellow "AD LDS User not not enabled."
}
}#END Try
Catch {
    Write-Host -ForegroundColor Yellow $GetADObject
    Write-Host -ForegroundColor Yellow "Security Permissions is preventing this script from accessing the information."
}

    $Properties = @{'Name of User'            = $Name;
                    'SamAccountName'          = $UserInfo.SamAccountName;
                    'User Email Address'      = $UserInfo.UserPrincipalName;
                    'AD Account Enabled'      = $UserInfo.Enabled;
                    'AD Account LockedOut'    = $UserInfo.LockedOut;
                    'AD PW Last Set'          = $ADPWLastSet;
                    'AD LDS PW Last Set'      = $ADLDSPWLastSet}

    $Output = New-Object -TypeName psobject -Property $Properties
    Write-Output $Output
}#END ForEach ($User in $UserID)



####################################################################################################################################################
####################################################################################################################################################

}#END Process
END {}#END END
}# END Function

Get-PWLastSet
