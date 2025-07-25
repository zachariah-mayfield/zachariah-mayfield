CLS

<#
.SYNOPSIS
    Function Remove-Office365Shared
  
.NAME
    Remove-Office365Shared

.AUTHORS
    Zack Mayfield 

.DESCRIPTION
    This Function is designed to create a Shared Mail Box and add Members and Owners and assign permissions to the Shared Mail Box.  
  
.EXAMPLE


.PARAMETER
    -SharedBox 

.PARAMETER
    -Owner     

.NOTE(S) 
   
   Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
   
   Get-MailboxPermission Test-Shared1 | where {$_.User -notlike 'NT AUTHORITY*'} | Format-Table -Auto User,Deny,IsInherited,AccessRights 
#>

Function Remove-Office365SharedMailBox {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String]$SharedBox=""
    )
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}#END BEGIN
Process{

####################################################################################################################################################

$Shared = Get-Mailbox -Identity $SharedBox

IF ($Shared) {
    Remove-Mailbox -Identity $SharedBox -Confirm:$false -Force -Verbose
} Else {
    Write-Host -ForegroundColor Yellow $SharedBox "does not exist."
}

####################################################################################################################################################
}#END Process
END {}#END END
}# END Function Remove-Office365SharedMailBox