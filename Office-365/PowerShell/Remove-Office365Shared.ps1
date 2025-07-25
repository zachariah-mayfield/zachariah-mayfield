
<#

.SYNOPSIS
    Function Remove-Office365Shared
  
.NAME
    Remove-Office365Shared

.AUTHORS


.DESCRIPTION
    This Function is designed to Remove a members access from a Shared Mailbox.

.EXAMPLE


.PARAMETER SharedBox 
    
.PARAMETER RemoveMember

.NOTE(S) 
   
   Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
   
   https://outlook.office365.com/powershell-liveid/

   Get-MailboxPermission Test-Shared1 | where {$_.User -notlike 'NT AUTHORITY*'} | Format-Table -Auto User,Deny,IsInherited,AccessRights 
#>
Function Remove-Office365Shared {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String]$SharedBox,
    #[Parameter()]
    #[String]$Email,
    [Parameter()]
    [String[]]$RemoveMember
    )
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1

$WarningPreference = "SilentlyContinue"

}#END BEGIN
Process{


# Trimming the White space from the Shared MailBox
$SharedBox = $SharedBox.Trim()

# Setting the variable for to Check the Shared MailBox for the $Email Param supplied. 
$CheckShared = Get-Mailbox -Identity $SharedBox -ErrorAction SilentlyContinue -WarningAction SilentlyContinue


Try {
    # If statement to check that the above is true.
    If ($CheckShared.Name -notmatch $SharedBox) {
        Write-Output ("The Shared MailBox `"$SharedBox`" Does not exist.")
        Exit
    } Else {
        Write-Output ("The Shared MailBox `"$SharedBox`" exists.")
    }
}
Catch {
    Write-Output ("Issue Creating Shared MailBox `"$SharedBox`"")
    Write-Error -Message $_.Exception.Message
}


ForEach($Name in $RemoveMember) {
    Try {
        $CheckFullAccessMember = $null
        $CheckFullAccessMember = (Get-MailboxPermission -Identity $SharedBox -User $Name).user
        IF ($CheckFullAccessMember -in $RemoveMember) {
            Remove-MailboxPermission -Identity $SharedBox -User $Name -AccessRights 'FullAccess' -InheritanceType All -Confirm:$False -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
            Write-Output ("The user `"$Name`" has been removed as a Full Access Member  from the Shared MailBox `"$SharedBox`"")   
        }
        ElseIf ($CheckFullAccessMember -notin $RemoveMember) {
            Write-Output ("The user: $Name is not a Full Access Member in the Shared MailBox: $SharedBox")
        }
    }
    Catch {
        Write-Output ("Issue removing Full Access Member $Name from the Shared MailBox `"$SharedBox`"")
        Write-Error -Message $_.Exception.Message
    }    
}# ForEach($Name in $RemoveMember)

ForEach($Name in $RemoveMember) {
    Try {
        $CheckSendAsMember = $null
        $CheckSendAsMember = (Get-RecipientPermission -Identity $SharedBox -Trustee $Name).Trustee
        IF ($CheckSendAsMember -in $RemoveMember) {
            Remove-RecipientPermission -Identity $SharedBox -Trustee $Name -AccessRights 'SendAs' -Confirm:$false -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
            Write-Output ("The user `"$Name`" has been removed as a Send As Member from the Shared MailBox `"$SharedBox`"")
        }
        ElseIf ($CheckSendAsMember -notin $RemoveMember) {
            Write-Output ("The user: $Name is not a Send As Member in the Shared MailBox: $SharedBox")
        }
    }
    Catch {
        Write-Output ("Issue removing Send As Member $Name from the Shared MailBox `"$SharedBox`"")
        Write-Error -Message $_.Exception.Message
    }    
}# ForEach($Name in $RemoveMember)

####################################################################################################################################################
####################################################################################################################################################

}#END Process
END {}#END END
}# END Function Remove-Office365Shared

