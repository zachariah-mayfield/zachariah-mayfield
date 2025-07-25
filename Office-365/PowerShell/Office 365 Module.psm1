


Function Add-Office365Shared {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String]$SharedBox="",
    [Parameter()]
    [String]$Email="",
    [Parameter()]
    [String[]]$SendAsMember="",
    [Parameter()]
    [String[]]$FullAccessMember="",
    <#[Parameter()]
    [String]$Department="",#>
    [Parameter()]
    [String]$Company="xxxxx",
    <#[Parameter()]
    [String]$Manager="",#>
    [Parameter()]
    [String]$Title=""
    )
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}#END BEGIN
Process{
####################################################################################################################################################
####################################################################################################################################################

$Email = $Email.Trim()

$SharedBox = $SharedBox.Trim()

$CheckShared = Get-Mailbox -Identity $Email -ErrorAction SilentlyContinue

$CheckEmail = ($Email -as [System.Net.Mail.MailAddress]).Address -eq $Email -and $Email -ne $null

If ($CheckShared -eq $null -and $CheckEmail -eq $true) {
    Write-Host -ForegroundColor Cyan "The Shared MailBox `"$SharedBox`" Does not exist. This function is now creating the Shared MailBox."
    New-Mailbox -Shared:$True -Name $SharedBox -PrimarySmtpAddress $Email | Out-Null
    #(Get-Mailbox -Identity $SharedBox).PrimarySmtpAddress | select -Property Address, Local, Domain
} Else {
    Write-Host -ForegroundColor Cyan "The Shared MailBox `"$SharedBox`" already exists."
}
####################################################################################################################################################
####################################################################################################################################################
ForEach($Name in $FullAccessMember) {
Add-MailboxPermission -Identity $SharedBox -User $Name -AccessRights ‘FullAccess’ -InheritanceType All -Confirm:$False | Out-Null
Write-Host -ForegroundColor Cyan "The user `"$name`" has been added to the Shared MailBox `"$SharedBox`" with `"FullAccess`" Permissions"
}
Add-MailboxPermission -Identity $SharedBox -User "xxxxx.com" -AccessRights ‘FullAccess’ -InheritanceType All -Confirm:$False | Out-Null
####################################################################################################################################################
####################################################################################################################################################
ForEach($Name in $SendAsMember) {
Add-RecipientPermission -Identity $SharedBox -Trustee $Name -AccessRights 'SendAs' -Confirm:$false -ErrorAction SilentlyContinue
Write-Host -ForegroundColor Cyan "The user `"$name`" has been added to the Shared MailBox `"$SharedBox`" with `"Send AS`" Permissions"
}
####################################################################################################################################################
####################################################################################################################################################

IF ($Company){
    Set-User -Identity $SharedBox -Company $Company | Out-Null
}
IF ($Title){
    $FullTitle = "Shared Mailbox - Contact: " + $Title
    Set-User -Identity $SharedBox -Title $FullTitle | Out-Null
}

####################################################################################################################################################
####################################################################################################################################################
}#END Process
END {}#END END
}# END Function Add-Office365Shared

Function Remove-Office365Shared {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String]$SharedBox="",
    [Parameter()]
    [String[]]$RemoveMember=""
    )
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}#END BEGIN
Process{
####################################################################################################################################################
####################################################################################################################################################

$SharedBox = $SharedBox.Trim()

ForEach($Name in $RemoveMember) {
Remove-MailboxPermission -Identity $SharedBox -User $Name -AccessRights 'FullAccess' -InheritanceType All -Confirm:$False | Out-Null
Remove-RecipientPermission -Identity $SharedBox -Trustee $Name -AccessRights 'SendAs' -Confirm:$false -ErrorAction SilentlyContinue
Write-Host -ForegroundColor Cyan "The user `"$Name`" has been removed from the Shared MailBox `"$SharedBox`"" 
####################################################################################################################################################
####################################################################################################################################################
}# ForEach($Name in $RemoveMember)

}#END Process
END {}#END END
}# END Function Remove-Office365Shared

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
    [String[]]$Owner="",
    [Parameter()]
    [Switch]$AllowOutsideSenders
    )
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}#END BEGIN
Process{
####################################################################################################################################################
####################################################################################################################################################

$Email = $Email.Trim()

$DistroGroup = $DistroGroup.Trim()

$CheckDG = Get-DistributionGroup -Identity $Email -ErrorAction SilentlyContinue

$CheckEmail = ($Email -as [System.Net.Mail.MailAddress]).Address -eq $Email -and $Email -ne $null

If ($CheckDG -eq $null -and $CheckEmail -eq $true) {
    Write-Host -ForegroundColor Cyan "The Distribution Group $DistroGroup Does not exist. This function is now creating the Distro group."
    New-DistributionGroup -Name $DistroGroup -DisplayName $DistroGroup -Type Security -PrimarySmtpAddress $Email | Out-Null
} Else {
    Write-Host -ForegroundColor Cyan "The Distribution Group $DistroGroup already exists."
}
####################################################################################################################################################
####################################################################################################################################################
IF ($GroupMember) {
ForEach($Name in $GroupMember) { 
Add-DistributionGroupMember -Identity $DistroGroup -Member $Name -BypassSecurityGroupManagerCheck -ErrorAction SilentlyContinue | Out-Null
Write-Host -ForegroundColor Cyan "The user $Name is now being added to the Distribution Group $DistroGroup."
}
}
####################################################################################################################################################
####################################################################################################################################################
IF ($Owner) {
ForEach($Name in $Owner) {
Set-DistributionGroup -Identity $DistroGroup -ManagedBy @{Add="$Name"} -BypassSecurityGroupManagerCheck -ErrorAction SilentlyContinue | Out-Null
Write-Host -ForegroundColor Cyan "The user $Name is now being added as an owner of the Distribution Group $DistroGroup."
}
Set-DistributionGroup -Identity $DistroGroup -ManagedBy @{Add="xxxxx.com"} -BypassSecurityGroupManagerCheck -ErrorAction SilentlyContinue | Out-Null
Set-DistributionGroup -Identity $DistroGroup -ManagedBy @{Remove="xxxxx.com"} -BypassSecurityGroupManagerCheck -ErrorAction SilentlyContinue
Write-Host -ForegroundColor Cyan "The user xxxxx.com is being removed as an owner or the Distribution Group $DistroGroup "
}
####################################################################################################################################################
####################################################################################################################################################
IF ($AllowOutsideSenders) {
Set-DistributionGroup -Identity $DistroGroup -RequireSenderAuthenticationEnabled:$false
Write-Host -ForegroundColor Cyan "People outside the organization is now allowed to send to this group: " $DistroGroup
}
####################################################################################################################################################
####################################################################################################################################################
}#END Process
END {}#END END
}# END Function Add-Office365Distro


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


$DistroGroup = $DistroGroup.Trim()


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



Function Add-Office365Resource  {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter(ParameterSetName="Action")]
    [ValidateSet("New","Update")]
    [String]$Action = "Update",
    [Parameter()]
    [String]$RoomName="xxxxx",
    [Parameter()]
    [String]$DisplayName="xxxxx",
    [Parameter()]
    [int]$Capacity="10",
    [Parameter()]
    [String]$Phone="xxxxx",
    [Parameter()]
    [String]$AutoResponseMessage='xxxxx.',
    [Parameter()]
    [String]$Notes="This is a Note XXX",
    [Parameter()]
    [String]$RoomRegion="Deck",
    [Parameter()]
    [String[]]$AdminMember = "xxxxx.com",
    [Parameter()]
    [ValidateSet("Create","Add","Remove")]
    [String]$AdminAction = "Add",
    [Parameter()]
    [ValidateSet("Add","Remove")]
    [String]$BookInAction = "Add",
    [Parameter()]
    [String[]]$BookInPolicyResourceDelegate = ("xxxxx.com","xxxxx.com","xxxxx.com","xxxxx.com"),
    [Parameter()]
    [String[]]$RequestInPolicyResourceDelegate = "xxxxx.com",#
    [Parameter()]
    [String[]]$RequestOutOfPolicyResourceDelegate = "xxxxx.com"#
)

Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
$WarningPreference = 'SilentlyContinue'
}#END BEGIN
Process{
####################################################################################################################################################
####################################################################################################################################################
# Create a new conference room mailbox with the default settings we specify
# grant any specified members access

$Domain = "@xxxxx"

$Room = Get-Mailbox -Identity $RoomName -ErrorAction 'SilentlyContinue'

$RoomEmail = ($RoomName.Replace(' ','')+$Domain -as [System.Net.Mail.MailAddress]).Address

IF ($Action -eq "New") {

    IF ($Room){
        Write-Host -ForegroundColor Yellow $RoomName "already exists." 
        Write-Host -ForegroundColor Yellow "Use the Edit section of the form, if you need to make changes to an existing conference room." 
        EXIT
    } Else {
        New-Mailbox -Name $RoomName -DisplayName $DisplayName -PrimarySmtpAddress $RoomEmail -Room:$true -TargetAllMDBs:$false -Confirm:$false -WarningAction 'SilentlyContinue' -ErrorAction 'SilentlyContinue' -verbose
        Set-CalendarProcessing -Identity $RoomName -AllBookInPolicy:$true -AutomateProcessing 'AutoAccept' -AllRequestInPolicy:$false -Confirm:$false -WarningAction 'SilentlyContinue' -ErrorAction 'SilentlyContinue' -verbose
        sleep -Seconds 5
    }

}#END IF ($Action -eq "New")

IF ($Action -eq "Update") {

    IF ($Room){
        Write-Host -ForegroundColor Green $RoomName "exists." 

        $EmailAlias = (Get-Mailbox -Identity $RoomName).EmailAddresses

        $NewEmailAlias = 'SMTP:' + $DisplayName + $Domain

        IF ($NewEmailAlias -in $EmailAlias) {
            
            Write-Output "The value $NewEmailAlias is already present in the collection."
        
        } Else {
            Write-Output "The value $NewEmailAlias is NOT present in the collection."

            $NewEmailAliasList = $EmailAlias + $NewEmailAlias 

            TRY {
                Set-Mailbox -Identity $RoomName -DisplayName $DisplayName -EmailAddresses $NewEmailAliasList -ErrorAction 'Stop' -Force
            }
            Catch {
                Write-Output "The value $DisplayName is already present in the collection."
            }

        }

        (Get-Mailbox -Identity $RoomName).EmailAddresses
    } Else {

        Write-Host -ForegroundColor Yellow $RoomName "Does Not exist." 

    }

}#END IF ($Action -eq "Update") 

$ExchangeAdmins = (Get-DistributionGroup -Identity 'xxxxx').WindowsEmailAddress

$RoomandGroupAdmin = (Get-DistributionGroup -Identity 'xxxxx').WindowsEmailAddress

$CrestronRV = (Get-Mailbox -Identity 'xxxxx').WindowsEmailAddress

ForEach ($Member in $AdminMember){
    IF ($Member -ne $null) {
        IF ($AdminAction -eq "Add") {
            # Full Access permission 
            $WindowsEmailAddress = $Member
            Add-MailboxPermission -Identity $RoomName -User $WindowsEmailAddress -AccessRights 'FullAccess' -InheritanceType 'All' -Confirm:$false -Verbose -WarningAction 'SilentlyContinue'
        }
        IF ($AdminAction -eq "Remove") {
            # Full Access permission 
            $WindowsEmailAddress = $Member
            Remove-MailboxPermission -Identity $RoomName -User $WindowsEmailAddress -AccessRights 'FullAccess' -InheritanceType 'All' -Confirm:$false -Verbose -WarningAction 'SilentlyContinue'
        }    
    }
}

# Full Access permission 
Add-MailboxPermission -Identity $RoomName -User $ExchangeAdmins -AccessRights 'FullAccess' -InheritanceType 'All' -Confirm:$false -Verbose -WarningAction 'SilentlyContinue'

# Full Access permission 
Add-MailboxPermission -Identity $RoomName -User $RoomandGroupAdmin -AccessRights 'FullAccess' -InheritanceType 'All' -Confirm:$false -Verbose -WarningAction 'SilentlyContinue'

# Full Access permission 
Add-MailboxPermission -Identity $RoomName -User $CrestronRV -AccessRights 'FullAccess' -InheritanceType 'All' -Confirm:$false -Verbose -WarningAction 'SilentlyContinue'

# ADD Default Send As permission
Add-RecipientPermission -Identity $RoomName -Trustee $CrestronRV -AccessRights 'SendAs' -Confirm:$false -Verbose -WarningAction 'SilentlyContinue'

# Sets Booking requests to: Accept or decline booking requests automatically.
# Automatically process even invitations and cancellations.
Set-CalendarProcessing -Identity $RoomName -AutomateProcessing 'AutoAccept' -Confirm:$false -WarningAction 'SilentlyContinue' -Verbose

# Turn off reminders
Set-MailboxCalendarConfiguration -Identity $RoomName -RemindersEnabled:$false -Verbose

# Maximum number of days in advance resources can be booked
Set-CalendarProcessing -Identity $RoomName -BookingWindowInDays 460 -Verbose

# The below changes the setting to Selected bubble.
# Always decline if the end date is beyond the limit.
Set-CalendarProcessing -Identity $RoomName -EnforceSchedulingHorizon:$true -Confirm:$false -Verbose

# The below changes the setting to De-Selected bubble.
# Limit event duration
Set-CalendarProcessing -Identity $RoomName -MaximumDurationInMinutes:$false -Confirm:$false -Verbose

# Sets the Maximum allowed minutes
Set-CalendarProcessing -Identity $RoomName -MaximumDurationInMinutes "1440" -Confirm:$false -Verbose

# The below changes the setting De-selected bubble.
# Allow scheduling only suring working hours.
Set-CalendarProcessing -Identity $RoomName -ScheduleOnlyDuringWorkHours:$false -Confirm:$false -Verbose

# Allow Repeating Meetings
Set-CalendarProcessing -Identity $RoomName -AllowRecurringMeetings:$true -Confirm:$false -Verbose

# The below changes the setting De-selected bubble.
# Allow confilicts
Set-CalendarProcessing -Identity $RoomName -AllowConflicts:$false -Confirm:$false -Verbose

# Allow up to this number of individual conflicts
Set-CalendarProcessing -Identity $RoomName -MaximumConflictInstances 100 -Verbose

# Allow up to this percentage of individual conflicts
Set-CalendarProcessing -Identity $RoomName -ConflictPercentageAllowed 50 -Verbose

# Allow Add Additional text to be included in responses to event invitations
Set-CalendarProcessing -Identity $RoomName -AddAdditionalResponse:$true -Verbose

# Text to be included in responses to event invitations
Set-CalendarProcessing -Identity $RoomName -AdditionalResponse $AutoResponseMessage -Verbose

####################################################################################################################################################
####################################################################################################################################################
####################################################################################################################################################
####################################################################################################################################################

IF ($BookInPolicyResourceDelegate -eq $null) {

# The below changes the setting to the selected EVERYONE bubble.
# These people can schedule automatically if the resource is available.
Set-CalendarProcessing -Identity $RoomName -AllBookInPolicy:$true -Confirm:$false -Verbose

} ELSE {

####################################################################################################################################################
####################################################################################################################################################
####################################################################################################################################################
####################################################################################################################################################

# ADDing a $BookInPolicyResourceDelegate

IF ($BookInAction -eq "Add") {

$CurrentBookInUsers = (Get-CalendarProcessing -Identity $RoomName).BookInPolicy

ForEach ($BookIn in $BookInPolicyResourceDelegate) {

    $NewBookInUsers = (Get-Mailbox -Identity $BookIn).LegacyExchangeDN

    IF ($NewBookInUsers -notin $CurrentBookInUsers) { 
        Write-Host -ForegroundColor Green "No Match"
        $CurrentBookInUsers.Add($NewBookInUsers) 
    } ELSE {
        Write-Host -ForegroundColor Red "Match"
    }
}

Set-CalendarProcessing -Identity $RoomName -AllBookInPolicy:$false -BookInPolicy $CurrentBookInUsers -Confirm:$false -Verbose -ErrorAction 'SilentlyContinue' -WarningAction 'SilentlyContinue'

$CurrentBookInUsers = (Get-CalendarProcessing -Identity $RoomName).BookInPolicy
$CurrentBookInUsers

####################################################################################################################################################
####################################################################################################################################################

}

####################################################################################################################################################
####################################################################################################################################################

# Removing a $BookInPolicyResourceDelegate

IF ($BookInAction -eq "Remove") {

$CurrentBookInUsers = (Get-CalendarProcessing -Identity $RoomName).BookInPolicy

ForEach ($BookIn in $BookInPolicyResourceDelegate) {

    $CurrentBookInUsers
    $RemoveUsers = (Get-Mailbox -Identity $BookIn).LegacyExchangeDN
    
    IF ($RemoveUsers -in $CurrentBookInUsers) { 
        Write-Host -ForegroundColor Green "Match"
        $CurrentBookInUsers.Remove($RemoveUsers)
    } ELSE {
        Write-Host -ForegroundColor Red "NO Match"
    }
}

Set-CalendarProcessing -Identity $RoomName -AllBookInPolicy:$false -BookInPolicy $CurrentBookInUsers -Confirm:$false -Verbose -ErrorAction 'SilentlyContinue' -WarningAction 'SilentlyContinue'

$CurrentBookInUsers = (Get-CalendarProcessing -Identity $RoomName).BookInPolicy
$CurrentBookInUsers

####################################################################################################################################################
####################################################################################################################################################

}

####################################################################################################################################################
####################################################################################################################################################

}

####################################################################################################################################################
####################################################################################################################################################

IF ($RequestInPolicyResourceDelegate -eq $null) {

    # The below changes the setting to the selected EVERYONE bubble.
    # These people can submit a request for owner approval if the resource is available.
    Set-CalendarProcessing -Identity $RoomName -AllRequestInPolicy:$true -Confirm:$false -Verbose

} ELSE {

    # The below changes the setting to the selected "Specific people and groups" bubble.
    # These people can submit a request for owner approval if the resource is available.
    Set-CalendarProcessing -Identity $RoomName -AllRequestInPolicy:$false -RequestInPolicy $RequestInPolicyResourceDelegate -Confirm:$false -Verbose

}

IF ($RequestOutOfPolicyResourceDelegate -eq $null) {

    # The below changes the setting to the selected EVERYONE bubble.
    # These People or Groups can schedule Automatically if the resource is avaliable and can submit a request for owner approval if the resource is unavailable.
    Set-CalendarProcessing -Identity $RoomName -AllRequestOutOfPolicy:$true -Confirm:$false -Verbose

} ELSE {

    # The below changes the setting to the selected "Specific people and groups" bubble.
    # These People or Groups can schedule Automatically if the resource is avaliable and can submit a request for owner approval if the resource is unavailable.
    Set-CalendarProcessing -Identity $RoomName -AllRequestOutOfPolicy:$false -RequestOutOfPolicy $RequestOutOfPolicyResourceDelegate -Confirm:$false -Verbose

}

####################################################################################################################################################
####################################################################################################################################################

# Sets the room capacity to the $Capacity variable.
Set-Mailbox -Identity $RoomName -ResourceCapacity $Capacity -Verbose

# Sets the Location, Phone Number, and Notes for the Conference Room. 
Set-User -Identity $RoomName -Office $RoomRegion -Phone $Phone -Notes $Notes -Confirm:$false -WarningAction 'SilentlyContinue'  -Verbose 

#### Change role for Default User to Reviewer and set the Permission Level to: Free/Busy Time, Subject, Location
Set-MailboxFolderPermission -Identity $RoomName -AccessRights Reviewer -User Default -Confirm:$false -WarningAction 'SilentlyContinue' -Verbose

# Allow end users to search rooms in Outlook through room finder $RoomRegion = Default = Deck... This can be changed.
Add-DistributionGroupMember -Identity $RoomRegion -Member $RoomName -Verbose -Confirm:$false -ErrorAction 'SilentlyContinue'

####################################################################################################################################################
####################################################################################################################################################

}#END Process
END {}#END END
}# END Function 

