CLS


Function Add-Office365Shared {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String]$SharedBox,
    [Parameter()]
    [String]$Email,
    [Parameter()]
    [String[]]$SendAsMember,
    [Parameter()]
    [String[]]$FullAccessMember,
    [Parameter()]
    [String]$Department,
    [Parameter()]
    [String]$Company="Company-x",
    [Parameter()]
    [String]$Manager,
    [Parameter()]
    [String]$Title
    )
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1

$WarningPreference = "SilentlyContinue"

}#END BEGIN
Process{


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
        New-Mailbox -Shared:$True -Name $SharedBox -PrimarySmtpAddress $Email -ErrorAction Stop -WarningAction SilentlyContinue
        Write-Output ("The Shared MailBox `"$SharedBox`" Does not exist. This function is now creating the Shared MailBox.")
    } Else {
        Write-Output ("The Shared MailBox `"$SharedBox`" already exists.")
    }
}
Catch {
    Write-Output ("Issue Creating Shared MailBox `"$SharedBox`"")
    Write-Error -Message $_.Exception.Message
}

####################################################################################################################################################
####################################################################################################################################################

# Adding the Full Access Member "office365exchangeadmins@Company.onmicrosoft.com" to the Shared MailBox!

####################################################################################################################################################
####################################################################################################################################################

Try {
    Add-MailboxPermission -Identity $SharedBox -User "office365exchangeadmins@Company.onmicrosoft.com" -AccessRights ‘FullAccess’ -InheritanceType All -Confirm:$False -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
}
Catch {
    Write-Output ("Issue Adding Full Access Member `"office365exchangeadmins@Company.onmicrosoft.com`" to the Shared MailBox `"$SharedBox`"")
    Write-Error -Message $_.Exception.Message
}

####################################################################################################################################################
####################################################################################################################################################

# Adding the Send As Member to the Shared MailBox!

####################################################################################################################################################
####################################################################################################################################################

ForEach($Name in $SendAsMember) {
    Try {
    $CheckSendAsMember = $null
    $CheckSendAsMember = (Get-RecipientPermission -Identity $SharedBox -Trustee $Name).Trustee

    IF ($CheckSendAsMember -in $SendAsMember) {
        Write-Output ("The user: $CheckSendAsMember is already a Send As Member in the Shared MailBox: $SharedBox")
    }
    ElseIf ($CheckSendAsMember -notin $SendAsMember) {
        Add-RecipientPermission -Identity $SharedBox -Trustee $Name -AccessRights 'SendAs' -Confirm:$false -ErrorAction Stop -WarningAction SilentlyContinue | Out-null
        Write-Output ("The user `"$name`" has been added to the Shared MailBox `"$SharedBox`" with `"Send AS`" Permissions")
    }
    }
    Catch {
        Write-Output ("Issue Adding Send As Member $Name to the Shared MailBox `"$SharedBox`"")
        Write-Error -Message $_.Exception.Message
    }
}

####################################################################################################################################################
####################################################################################################################################################

# Adding the Full Access Member to the Shared MailBox!

####################################################################################################################################################
####################################################################################################################################################

ForEach($Name in $FullAccessMember) {
    
    $CheckFullAccessMember = $null
    $CheckFullAccessMember = (Get-MailboxPermission -Identity $SharedBox -User $Name).user
    Try {
    IF ($CheckFullAccessMember -in $FullAccessMember) {
        Write-Output ("The user: $Name is already a Full Access Member in the Shared MailBox: $SharedBox")
    }
    ElseIf ($CheckFullAccessMember -notin $FullAccessMember) {
        Add-MailboxPermission -Identity $SharedBox -User $Name -AccessRights ‘FullAccess’ -InheritanceType All -Confirm:$False -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
        Write-Output ("The user `"$name`" has been added to the Shared MailBox `"$SharedBox`" with `"FullAccess`" Permissions")
    }
    }
    Catch {
        Write-Output ("Issue Adding Full Access Member $Name to the Shared MailBox `"$SharedBox`"")
        Write-Error -Message $_.Exception.Message
    }
}

####################################################################################################################################################
####################################################################################################################################################

# Adding the Department to the Shared MailBox!

####################################################################################################################################################
####################################################################################################################################################

Try {
    IF ($Department){
        Set-User -Identity $SharedBox -Department $Department -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
    }
}
Catch {
    Write-Output ("Issue adding Department $Department to the Shared MailBox `"$SharedBox`"")
    Write-Error -Message $_.Exception.Message
}

####################################################################################################################################################
####################################################################################################################################################

# Adding the Company to the Shared MailBox!

####################################################################################################################################################
####################################################################################################################################################

Try {
    IF ($Company){
        Set-User -Identity $SharedBox -Company $Company -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
    }
}
Catch {
    Write-Output ("Issue adding Company $Company to the Shared MailBox `"$SharedBox`"")
    Write-Error -Message $_.Exception.Message
}

####################################################################################################################################################
####################################################################################################################################################

# Adding the Title to the Shared MailBox!

####################################################################################################################################################
####################################################################################################################################################

Try {
    IF ($Title){
        $FullTitle = "Shared Mailbox - Contact: " + $Title
        Set-User -Identity $SharedBox -Title $FullTitle -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
    }
}
Catch {
    Write-Output ("Issue adding Title $Title to the Shared MailBox `"$SharedBox`"")
    Write-Error -Message $_.Exception.Message
}

####################################################################################################################################################
####################################################################################################################################################

# Adding the Manager to the Shared MailBox!

####################################################################################################################################################
####################################################################################################################################################

Try {
    IF ($Manager) {
        Set-User -Identity $SharedBox -Manager $Manager -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
    }
}
Catch {
    Write-Output ("Issue adding Manager $Manager to the Shared MailBox `"$SharedBox`"")
    Write-Error -Message $_.Exception.Message
}

####################################################################################################################################################
####################################################################################################################################################
}#END Process
END {}#END END
}# END Function Add-Office365Shared

