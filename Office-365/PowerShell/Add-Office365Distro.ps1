CLS


Function Add-Office365Distro {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter(ParameterSetName="DistroGroup")]
    [String]$DistroGroup="",
    [Parameter()]
    [String]$Email="",
    [Parameter()] 
    [String[]]$GroupMember="",
    [Parameter()] 
    [String[]]$Owner=""
    )
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}#END BEGIN
Process{
####################################################################################################################################################
####################################################################################################################################################
$CheckDG = Get-DistributionGroup -Identity $DistroGroup -ErrorAction SilentlyContinue

$CheckEmail = ($Email -as [System.Net.Mail.MailAddress]).Address -eq $Email -and $Email -ne $null

If ($CheckDG -eq $null -and $CheckEmail -eq $true) {
    Write-Host -ForegroundColor Cyan "The Distribution Group $DistroGroup Does not exist. This fucntion is now creating the Distro group."
    New-DistributionGroup -Name $DistroGroup -DisplayName $DistroGroup -Type Security -PrimarySmtpAddress $Email | Out-Null
} Else {
    Write-Host -ForegroundColor Cyan "The Distribution Group $DistroGroup already exists."
}
####################################################################################################################################################
####################################################################################################################################################
ForEach($Name in $GroupMember) { 
Add-DistributionGroupMember -Identity $DistroGroup -Member $Name -BypassSecurityGroupManagerCheck -ErrorAction SilentlyContinue | Out-Null
Write-Host -ForegroundColor Cyan "The user $Name is now being added to the Distribution Group $DistroGroup."
}
####################################################################################################################################################
####################################################################################################################################################
ForEach($Name in $Owner) {
Set-DistributionGroup -Identity $DistroGroup -ManagedBy @{Add="$Name"} -BypassSecurityGroupManagerCheck -ErrorAction SilentlyContinue | Out-Null
Write-Host -ForegroundColor Cyan "The user $Name is now being added as an owner of the Distribution Group $DistroGroup."
}
Set-DistributionGroup -Identity $DistroGroup -ManagedBy @{Add="xxxxx"} -BypassSecurityGroupManagerCheck -ErrorAction SilentlyContinue | Out-Null
Set-DistributionGroup -Identity $DistroGroup -ManagedBy @{Remove="xxxxx"} -BypassSecurityGroupManagerCheck -ErrorAction SilentlyContinue
Write-Host -ForegroundColor Cyan "The user xxxxx is being removed as an owner or the Distribution Group $DistroGroup "
####################################################################################################################################################
####################################################################################################################################################
}#END Process
END {}#END END
}# END Function Add-Office365Distro

