CLS

<#
.SYNOPSIS
    Function Remove-Office365Distro
  
.NAME
    Remove-Office365Distro

.AUTHORS

.DESCRIPTION
    This Function is designed to Remove Members and Owners from the specified Distribution group.  
  
.EXAMPLE
    Remove-Office365Distro -DistroGroup "group" -GroupMember "testuser@Companys.com" ,"Administrator@Companys.com" -Owner "testuser@Companys.com", "Administrator@Companys.com"

.EXAMPLE
    Remove-Office365Distro -DistroGroup $param1 -Email $param2 -GroupMember $param3 -Owner $param4

.PARAMETER
    -DistroGroup

.PARAMETER
    -Email     
    
.PARAMETER
    -GroupMember

.PARAMETER
    -Owner     

.NOTE(S) 

  Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
    
#>

Function Remove-Office365Distro {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter(ParameterSetName="DistroGroup")]
    [String]$DistroGroup="" ,
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

$CheckDG = Get-DistributionGroup -Identity $DistroGroup -ErrorAction SilentlyContinue

If ($CheckDG -eq $null) {
    Write-Host -ForegroundColor Cyan "The Distribution Group $DistroGroup Does not exist. This function is now creating the Distribution Group."
    New-DistributionGroup -Name $DistroGroup -DisplayName $DistroGroup -Type Security
} Else {
    Write-Host -ForegroundColor Cyan "The Distribution Group $DistroGroup already exists."
}

####################################################################################################################################################

Write-Host -ForegroundColor Cyan "The Group Member $GroupMember is being removed from the Distribution Group $DistroGroup."
$GroupMember | ForEach { Remove-DistributionGroupMember -Identity $DistroGroup -Member $_ -BypassSecurityGroupManagerCheck -Confirm:$False -ErrorAction SilentlyContinue}

####################################################################################################################################################

$Owner | ForEach { Set-DistributionGroup -Identity $DistroGroup -ManagedBy @{Remove="$_"} -BypassSecurityGroupManagerCheck -ErrorAction SilentlyContinue}
Write-Host -ForegroundColor Cyan "The user $Owner is being removed as an owner or the Distribution Group $DistroGroup "

####################################################################################################################################################
}#END Process
END {}#END END
}# END Function Remove-Office365Distro
