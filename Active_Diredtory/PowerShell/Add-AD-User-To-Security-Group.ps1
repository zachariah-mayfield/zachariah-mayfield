Function Add-ADUserToSecurityGroup {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String[]]$UserName,
    [Parameter()]
    [String[]]$SecurityGroupNumber,
    [Parameter(ParameterSetName="SecurityGroupRole")]
    [ValidateSet("xxxxx","xxxxx","xxxxx","xxxxx","xxxxx","xxxxx","xxxxx","xxxxx")]
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

$Server = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:389"

$SecurityGroupName = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" + "-" + $GroupNumber + "-" + $SecurityGroupRole

# Check if $SecurityGroup exists
$GroupCheck = Get-ADGroup -Identity $SecurityGroupName -ErrorAction Stop -ErrorVariable "SecurityGroupError" -Server $Server

# Check if $User exists
$UserCheck = Get-ADUser -Identity $User -ErrorAction Stop -ErrorVariable "UserError" -Server $Server

IF ($GroupCheck -and $UserCheck) {

# Check $SecurityGroup Group Membership of $User
$GroupMember = (Get-ADGroupMember -Identity $SecurityGroupName -Server $Server  | select SamAccountName).SamAccountName

IF ($GroupMember -like $User) {
    Write-Host -ForegroundColor Yellow $User "is already a member of the group:" $SecurityGroupName
} ELSE {
    Write-Host -ForegroundColor Cyan "Adding $User to the $SecurityGroupName group."
    Add-ADGroupMember -Identity $SecurityGroupName -Members $User -Verbose -ErrorAction Stop -ErrorVariable "SecurityGroupAddingError" -server $Server -Credential $Credential 
}

}#END IF ($GroupCheck -and $UserCheck)


}#END Try

Catch {

Write-Host -ForegroundColor Yellow "ERROR :"

$SecurityGroupError

$UserError

$SecurityGroupAddingError

}

}#END Foreach ($GroupNumber in $SecurityGroupNumber) 

}#END ForEach ($User in $UserName)


}#END Process
END {}#END END
}# END Function
