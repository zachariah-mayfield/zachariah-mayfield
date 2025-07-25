Function Remove-ADUserToSecurityGroup {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String[]]$UserName,
    [Parameter()]
    [String[]]$SecurityGroupNumber,
    [Parameter(ParameterSetName="SecurityGroupRole")]
    [ValidateSet("admin","xxx","xxx","xxxx","xxx-xxx","support","xxx-admin")]
    [String]$SecurityGroupRole,
    [System.Management.Automation.PSCredential]$Credential
    )
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}#END BEGIN
Process{

ForEach ($User in $UserName) {

ForEach ($GroupNumber in $SecurityGroupNumber) {

Try {

$Server = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:389"

$SecurityGroupName = "xxxxxxxx" + "-" + $GroupNumber + "-" + $SecurityGroupRole

# Check if $SecurityGroup exists
$GroupCheck = Get-ADGroup -Identity $SecurityGroupName -ErrorAction Stop -ErrorVariable "SecurityGroupError" -Server $Server

# Check if $User exists
$UserCheck = Get-ADUser -Identity $User -ErrorAction Stop -ErrorVariable "UserError" -Server $Server

IF ($GroupCheck -and $UserCheck) {

# Check $SecurityGroup Group Membership of $User
$GroupMember = (Get-ADGroupMember -Identity $SecurityGroupName -Server $Server | select SamAccountName).SamAccountName

IF ($GroupMember -like $User) {
    Write-Host -ForegroundColor Cyan $User "is a member of the group:" $SecurityGroupName
    Remove-ADGroupMember -Identity $SecurityGroupName -Members $User -Verbose -ErrorAction Stop -ErrorVariable "SecurityGroupRemovalError" -Confirm:$false -Server $Server -Credential $Credential
} ELSE {
    Write-Host -ForegroundColor Yellow "$User is not a member of the $SecurityGroupName group."
}

}#END IF ($GroupCheck -and $UserCheck)


}#END Try

Catch {

Write-Host -ForegroundColor Yellow "ERROR :"

$SecurityGroupError

$UserError

$SecurityGroupRemovalError

}

}#END Foreach ($GroupNumber in $SecurityGroupNumber) 

}#END ForEach ($User in $UserName)


}#END Process
END {}#END END
}# END Function
