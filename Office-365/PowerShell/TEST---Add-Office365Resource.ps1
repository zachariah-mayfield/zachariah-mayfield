CLS

    [Parameter(ParameterSetName="Action")]
    [ValidateSet("New","Update")]
    [String]$Action
    [Parameter()]
    [String]$RoomName
    [Parameter()]
    [String]$DisplayName
    [Parameter()]
    [int]$Capacity
    [Parameter()]
    [String]$Phone
    [Parameter()]
    [String]$AutoResponseMessage='This space is available for all users to reserve. If you have any questions related to this meeting space, please contact xxx@Company-x.com. If you have additional setup requests, please fill out our Meetings & Events Form.'
    [Parameter()]
    [String]$Notes
    [Parameter()]
    [String]$RoomRegion
    [Parameter()]
    [String[]]$AdminMember
    [Parameter()]
    [ValidateSet("Individual","Group","All")]
    [String]$SelectedMember
    [Parameter()]
    [ValidateSet("Add","Remove")]
    [String]$AdminAction
    [Parameter()]
    [ValidateSet("Add","Remove")]
    [String]$BookInAction
    [Parameter()]
    [String[]]$BookInPolicyResourceDelegate
    [Parameter()]
    [String[]]$RequestInPolicyResourceDelegate
    [Parameter()]
    [String[]]$RequestOutOfPolicyResourceDelegate


# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
$WarningPreference = 'SilentlyContinue'

####################################################################################################################################################
####################################################################################################################################################
# Create a new conference room mailbox with the default settings we specify
# grant any specified members access

$Domain = "@Company-x.com"

$Room = Get-Mailbox -Identity $RoomName -ErrorAction 'SilentlyContinue'

$RoomEmail = ($RoomName.Replace(' ','')+$Domain -as [System.Net.Mail.MailAddress]).Address

IF ($Action -eq "New") {

    IF ($Room){
        Write-Output "$RoomName already exists." 
        Write-Output "Use the Edit section of the form, if you need to make changes to an existing conference room." 
        EXIT
    } Else {
        
        Write-Output "Creating New conference room..."
        
        New-Mailbox -Name $RoomName -DisplayName $DisplayName -PrimarySmtpAddress $RoomEmail -Room:$true -TargetAllMDBs:$false -Confirm:$false -WarningAction 'SilentlyContinue' -ErrorAction 'SilentlyContinue' | Out-Null
        Set-CalendarProcessing -Identity $RoomName -AllBookInPolicy:$true -AutomateProcessing 'AutoAccept' -AllRequestInPolicy:$false -Confirm:$false -WarningAction 'SilentlyContinue' -ErrorAction 'SilentlyContinue' | Out-Null
        sleep -Seconds 5
    }

}#END IF ($Action -eq "New")

IF ($Action -eq "Update") {

    IF ($Room){
        Write-Host -ForegroundColor Green $RoomName "exists." 

        $EmailAlias = (Get-Mailbox -Identity $RoomName).EmailAddresses

        $NewEmailAlias = ('SMTP:' + $DisplayName + $Domain) -replace " ", ""

        IF ($NewEmailAlias -in $EmailAlias) {
            
            Write-Output "The value $NewEmailAlias is already present in the collection."
        
        } Else {
            Write-Output "The value $NewEmailAlias is NOT present in the collection."

            $NewEmailAliasList = $EmailAlias + $NewEmailAlias 

            TRY {
                
                Write-Output "Changing the Display name, if the display name is different than the original"

                Set-Mailbox -Identity $RoomName -DisplayName $DisplayName -EmailAddresses $NewEmailAliasList -ErrorAction 'Stop' -Force
            }
            Catch {
                Write-Output "The value $DisplayName is already present in the collection."
            }

        }

        #(Get-Mailbox -Identity $RoomName).EmailAddresses
    } Else {

        Write-Host -ForegroundColor Yellow $RoomName "Does Not exist." 

    }

}#END IF ($Action -eq "Update") 

$ExchangeAdmins = (Get-DistributionGroup -Identity '!Office 365 Exchange Admins').WindowsEmailAddress

$RoomandGroupAdmin = (Get-DistributionGroup -Identity '!Office 365 Room and Group Admins').WindowsEmailAddress

$Username = (Get-Mailbox -Identity 'Username').WindowsEmailAddress

$CalendarSupport = (Get-DistributionGroup '!Outlook Calendar Support').WindowsEmailAddress

ForEach ($Member in $AdminMember){
    IF ($Member -ne "") {
        IF ($AdminAction -eq "Add") {
            # Full Access permission 
            $WindowsEmailAddress = $Member
            Write-Output "Adding new admin members:  $WindowsEmailAddress"
            Add-MailboxPermission -Identity $RoomName -User $WindowsEmailAddress -AccessRights 'FullAccess' -InheritanceType 'All' -Confirm:$false -WarningAction 'SilentlyContinue' | Out-null
        }
        IF ($AdminAction -eq "Remove") {
            # Full Access permission 
            $WindowsEmailAddress = $Member
            Write-Output "Removing admin members:  $WindowsEmailAddress"
            Remove-MailboxPermission -Identity $RoomName -User $WindowsEmailAddress -AccessRights 'FullAccess' -InheritanceType 'All' -Confirm:$false -WarningAction 'SilentlyContinue' | Out-null
        }    
    }
}

# Full Access permission 
Write-Output "Default Full Access permission has been granted for: $CalendarSupport"
Add-MailboxPermission -Identity $RoomName -User $CalendarSupport -AccessRights 'FullAccess' -InheritanceType 'All' -Confirm:$false -WarningAction 'SilentlyContinue' | Out-null

# Full Access permission 
Write-Output "Default Full Access permission has been granted for: $ExchangeAdmins"
Add-MailboxPermission -Identity $RoomName -User $ExchangeAdmins -AccessRights 'FullAccess' -InheritanceType 'All' -Confirm:$false -WarningAction 'SilentlyContinue' | Out-null

# Full Access permission
Write-Output "Default Full Access permission has been granted for: $RoomandGroupAdmin"
Add-MailboxPermission -Identity $RoomName -User $RoomandGroupAdmin -AccessRights 'FullAccess' -InheritanceType 'All' -Confirm:$false -WarningAction 'SilentlyContinue' | Out-null

# Full Access permission
Write-Output "Default Full Access permission has been granted for: $Username "
Add-MailboxPermission -Identity $RoomName -User $Username -AccessRights 'FullAccess' -InheritanceType 'All' -Confirm:$false -WarningAction 'SilentlyContinue' | Out-null

# Add Default Send As permission
Write-Output "Default Send As permission has been granted for: $Username"
Add-RecipientPermission -Identity $RoomName -Trustee $Username -AccessRights 'SendAs' -Confirm:$false -WarningAction 'SilentlyContinue' | Out-null

# Sets Booking requests to: Accept or decline booking requests automatically.
# Automatically process event invitations and cancellations.
Write-Output "Setting the conference room to Automatically process event invitations and cancellations."
Set-CalendarProcessing -Identity $RoomName -AutomateProcessing 'AutoAccept' -Confirm:$false -WarningAction 'SilentlyContinue'

# Turn off reminders
Write-Output "Setting the conference room to Turn off reminders"
Set-MailboxCalendarConfiguration -Identity $RoomName -RemindersEnabled:$false

# Maximum number of days in advance resources can be booked
Write-Output "Setting the conference room Maximum number of days in advance resources can be booked is set to 460"
Set-CalendarProcessing -Identity $RoomName -BookingWindowInDays 460

# The below changes the setting to Selected bubble.
# Always decline if the end date is beyond the limit.
Write-Output "Setting the conference room to Always decline if the end date is beyond the limit."
Set-CalendarProcessing -Identity $RoomName -EnforceSchedulingHorizon:$true -Confirm:$false

# The below changes the setting to De-Selected bubble.
# Limit event duration
Write-Output "Setting the conference room to Limit event duration"
Set-CalendarProcessing -Identity $RoomName -MaximumDurationInMinutes:$false -Confirm:$false

# Sets the Maximum allowed minutes
Write-Output "Setting the conference room to the Maximum allowed minutes of 1440"
Set-CalendarProcessing -Identity $RoomName -MaximumDurationInMinutes "1440" -Confirm:$false

# The below changes the setting De-selected bubble.
# Allow scheduling only suring working hours.
Write-Output "Setting the conference room to Allow scheduling only suring working hours."
Set-CalendarProcessing -Identity $RoomName -ScheduleOnlyDuringWorkHours:$false -Confirm:$false

# Allow Repeating Meetings
Write-Output "Setting the conference room to Allow Repeating Meetings"
Set-CalendarProcessing -Identity $RoomName -AllowRecurringMeetings:$true -Confirm:$false

# The below changes the setting De-selected bubble.
# Allow confilicts
Write-Output "Setting the conference room to not Allow confilicts"
Set-CalendarProcessing -Identity $RoomName -AllowConflicts:$false -Confirm:$false

# Allow up to this number of individual conflicts
Write-Output "Setting the conference room to Allow up to 100 individual conflicts"
Set-CalendarProcessing -Identity $RoomName -MaximumConflictInstances 100

# Allow up to this percentage of individual conflicts
Write-Output "Setting the conference room to Allow up to 50 percent of individual conflicts"
Set-CalendarProcessing -Identity $RoomName -ConflictPercentageAllowed 50

# Allow Add Additional text to be included in responses to event invitations
Write-Output "Setting the conference room to Allow Add Additional text to be included in responses to event invitations"
Set-CalendarProcessing -Identity $RoomName -AddAdditionalResponse:$true

# Allow to show subject and organizer in conference room meetings
Write-Output "Setting the conference room to Allow to show subject and organizer in conference room meetings"
Set-CalendarProcessing -Identity $RoomName -AddOrganizerToSubject $true -DeleteComments $false -DeleteSubject $false
####################################################################################################################################################
####################################################################################################################################################

# ADDing a $BookInPolicyResourceDelegate

IF ($BookInAction -eq "Add" -and $SelectedMember -eq "All") {
# The below changes the setting to the selected EVERYONE bubble.
Write-Output "Book In Policy Resource Delegate setting to the selected EVERYONE bubble."
# These people can schedule automatically if the resource is available.
Set-CalendarProcessing -Identity $RoomName -AllBookInPolicy:$true -Confirm:$false

}
ELSEIF ($BookInAction -eq "Add") {

$CurrentBookInUsers = (Get-CalendarProcessing -Identity $RoomName).BookInPolicy

ForEach ($BookIn in $BookInPolicyResourceDelegate) {

    IF ($SelectedMember -eq "Individual") {
    $NewBookInUsers  = (Get-Mailbox -Identity $BookIn).LegacyExchangeDN
    }
    IF ($SelectedMember -eq "Group") {
    $NewBookInUsers  = (Get-DistributionGroup -Identity $BookIn).LegacyExchangeDN
    }

    IF ($NewBookInUsers -notin $CurrentBookInUsers) { 
        Write-Output "Adding New Book In Users: " $NewBookInUsers
        $CurrentBookInUsers.Add($NewBookInUsers) 
    } ELSE {
        #Write-Host -ForegroundColor Red "Match"
    }
}

Set-CalendarProcessing -Identity $RoomName -AllBookInPolicy:$false -AllRequestInPolicy:$false -BookInPolicy $CurrentBookInUsers -Confirm:$false -ErrorAction 'SilentlyContinue' -WarningAction 'SilentlyContinue'

$CurrentBookInUsers = (Get-CalendarProcessing -Identity $RoomName).BookInPolicy

}

####################################################################################################################################################
####################################################################################################################################################

# Removing a $BookInPolicyResourceDelegate

IF ($BookInAction -eq "Remove") {

$CurrentBookInUsers = (Get-CalendarProcessing -Identity $RoomName).BookInPolicy

ForEach ($BookIn in $BookInPolicyResourceDelegate) {

    $CurrentBookInUsers

    IF ($SelectedMember -eq "Individual") {
    $RemoveUsers = (Get-Mailbox -Identity $BookIn).LegacyExchangeDN
    }
    IF ($SelectedMember -eq "Group") {
    $RemoveUsers = (Get-DistributionGroup -Identity $BookIn).LegacyExchangeDN
    }

    IF ($RemoveUsers -in $CurrentBookInUsers) { 
        Write-Output "Removing Book In Users: $NewBookInUsers"
        $CurrentBookInUsers.Remove($RemoveUsers)
    } ELSE {
        #Write-Host -ForegroundColor Red "NO Match"
    }
}

Set-CalendarProcessing -Identity $RoomName -AllBookInPolicy:$false -BookInPolicy $CurrentBookInUsers -Confirm:$false -ErrorAction 'SilentlyContinue' -WarningAction 'SilentlyContinue'

$CurrentBookInUsers = (Get-CalendarProcessing -Identity $RoomName).BookInPolicy

}


#}

####################################################################################################################################################
####################################################################################################################################################

IF ($RequestInPolicyResourceDelegate -eq "") {

    # The below changes the setting to the selected EVERYONE bubble.
    # These people can submit a request for owner approval if the resource is available.
    Set-CalendarProcessing -Identity $RoomName -AllRequestInPolicy:$true -Confirm:$false

} ELSE {

    # The below changes the setting to the selected "Specific people and groups" bubble.
    # These people can submit a request for owner approval if the resource is available.
    Set-CalendarProcessing -Identity $RoomName -AllRequestInPolicy:$false -RequestInPolicy $RequestInPolicyResourceDelegate -Confirm:$false

}

IF ($RequestOutOfPolicyResourceDelegate -eq "") {

    # The below changes the setting to the selected EVERYONE bubble.
    # These People or Groups can schedule Automatically if the resource is avaliable and can submit a request for owner approval if the resource is unavailable.
    Set-CalendarProcessing -Identity $RoomName -AllRequestOutOfPolicy:$true -Confirm:$false

} ELSE {

    # The below changes the setting to the selected "Specific people and groups" bubble.
    # These People or Groups can schedule Automatically if the resource is avaliable and can submit a request for owner approval if the resource is unavailable.
    Set-CalendarProcessing -Identity $RoomName -AllRequestOutOfPolicy:$false -RequestOutOfPolicy $RequestOutOfPolicyResourceDelegate -Confirm:$false

}

####################################################################################################################################################
####################################################################################################################################################

IF ($AutoResponseMessage -ne "") {
# Text to be included in responses to event invitations
Write-Output "Setting the conference room Auto Response to be included in event invitations"
Set-CalendarProcessing -Identity $RoomName -AdditionalResponse $AutoResponseMessage
}
IF ($Capacity -ne "") {
# Sets the room capacity to the $Capacity variable.
Write-Output "Setting the conference room, room capacity to $Capacity"
Set-Mailbox -Identity $RoomName -ResourceCapacity $Capacity
}
IF ($RoomRegion -ne "") {
# Sets the Location for the Conference Room. 
Write-Output "Setting the conference room RoomRegion to  $RoomRegion"
Set-User -Identity $RoomName -Office $RoomRegion -Confirm:$false -WarningAction 'SilentlyContinue'
}
IF ($Phone -ne "") {
# Sets the Phone Number for the Conference Room. 
Write-Output "Setting the conference room Phone Number to  $Phone"
Set-User -Identity $RoomName -Phone $Phone -Confirm:$false -WarningAction 'SilentlyContinue'
}
IF ($Notes -ne "") {
# Sets the Notes for the Conference Room. 
Write-Output "Setting the conference room Notes to  $Notes"
Set-User -Identity $RoomName -Notes $Notes -Confirm:$false -WarningAction 'SilentlyContinue'
}

#### Change role for Default User to Reviewer and set the Permission Level to: Free/Busy Time, Subject, Location
Write-Output "Setting the conference room to Change role for Default User to Reviewer and set the Permission Level to: Free/Busy Time, Subject, Location"
Set-MailboxFolderPermission -Identity $RoomName -AccessRights Reviewer -User Default -Confirm:$false -WarningAction 'SilentlyContinue'

# Allow end users to search rooms in Outlook through room finder $RoomRegion = Default = Deck... This can be changed.
Write-Output "Setting the conference room to Allow end users to search rooms in Outlook through room finder $RoomRegion"
Add-DistributionGroupMember -Identity $RoomRegion -Member $RoomName -Confirm:$false -ErrorAction 'SilentlyContinue'

####################################################################################################################################################
####################################################################################################################################################
