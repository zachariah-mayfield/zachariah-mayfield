CLS


[Parameter()]
[String]$SharedBox = "x"
[Parameter()]
[String]$Email = "xxx@Company-x.com"
[Parameter()]
[String[]]$SendAsMember = ("xxx@Company.com","xxxxx@Company.com")
[Parameter()]
[String[]]$FullAccessMember = ("xxx@Company.com","xxxxxxxx@Company.com")
[Parameter()]
[String[]]$RemoveMember = ("xxx@Company.com")

# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1

####################################################################################################################################################
####################################################################################################################################################

# Setting the varriables

####################################################################################################################################################
####################################################################################################################################################

# Trimming the White space from the email address
$Email = $Email.Trim()

# Trimming the White space from the Shared MailBox
$SharedBox = $SharedBox.Trim()

# Setting the variable for to Check the Shared MailBox for the $Email Param supplied. 
$CheckShared = Get-Mailbox -Identity $Email -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

# Comfirming that the $email supplied is in the correct format
$CheckEmail = ($Email -as [System.Net.Mail.MailAddress]).Address -eq $Email -and $Email -ne $null

####################################################################################################################################################
####################################################################################################################################################

# Creating the Shared MailBox if it does not exist!

####################################################################################################################################################
####################################################################################################################################################

Try {
    # If statement to check that the above is true.
    If ($CheckShared.Name -notmatch $SharedBox -and $CheckEmail -eq $true) {
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

####################################################################################################################################################
####################################################################################################################################################

# Removing the Full Access Member from the Shared MailBox!

####################################################################################################################################################
####################################################################################################################################################
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

####################################################################################################################################################
####################################################################################################################################################

# Removing the Send As Member from the Shared MailBox!

####################################################################################################################################################
####################################################################################################################################################
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




