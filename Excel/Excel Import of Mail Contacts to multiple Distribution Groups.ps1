CLS

Function Set-Office365Distro {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [ValidateSet("Create","Edit","Delete")]
    [String]$Action,
    [Parameter()]
    [String]$DistroGroup,
    [Parameter()]
    [String]$Email,
    [Parameter()]
    [ValidateSet("AddMember","RemoveMember")]
    [String]$MemberAction,
    [Parameter()] 
    [String[]]$GroupMember,
    [Parameter()]
    [ValidateSet("AddOwner","RemoveOwner")]
    [String]$OwnerAction,
    [Parameter()] 
    [String[]]$Owner,
    [Parameter()]
    [ValidateSet("Yes","No","Null")]
    [String]$AllowOutsideSenders
    )
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
$WarningPreference = 'SilentlyContinue'

}#END BEGIN
Process{

####################################################################################################################################################
####################################################################################################################################################

# Setting the varriables

####################################################################################################################################################
####################################################################################################################################################

# Trimming the White space from the email address
$Email = $Email.Trim()

# Trimming the White space from the DistributionGroup
$DistroGroup = $DistroGroup.Trim()

# Setting the variable for to Check the DistributionGroup for the $Email Param supplied. 
$CheckDG = (Get-DistributionGroup -Identity $Email -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

# Comfirming that the $email supplied is in the correct format
$CheckEmail = ($Email -as [System.Net.Mail.MailAddress]).Address -eq $Email -and $Email -ne $null

####################################################################################################################################################
####################################################################################################################################################

# Checking to make sure the Distribution Group exists.

####################################################################################################################################################
####################################################################################################################################################

If ($CheckDG.PrimarySmtpAddress -notmatch $Email -and $CheckEmail -eq $true) {
    Write-Output ("The Distribution Group: $DistroGroup does NOT exist.")
} Else {
    Write-Output ("The Distribution Group: $DistroGroup exists.")
}

####################################################################################################################################################
####################################################################################################################################################

# This is the Action of the Function

####################################################################################################################################################
####################################################################################################################################################

IF ($Action -eq "Create") {
    Try {
        # If statement to check that the above is true. 
        If ($CheckDG.PrimarySmtpAddress -notmatch $Email -and $CheckEmail -eq $true) {
            Write-Output ("The Action you selected was: `"$Action`" The Distribution Group $DistroGroup Does not exist. This function is now creating the Distro group.")
            New-DistributionGroup -Name $DistroGroup -DisplayName $DistroGroup -Type Security -PrimarySmtpAddress $Email -ErrorAction Stop -WarningAction SilentlyContinue  | Out-Null
        } Else {
            Write-Output ("The Action you selected was: `"$Action`" The Distribution Group $DistroGroup already exists. Please Select the Edit Action.")
            #EXIT
        }
    }
    Catch {
        Write-Output ("Issue Creating Distribution Group $DistroGroup")
        Write-Error -Message $_.Exception.Message
    }
}


IF ($Action -eq "Edit") {
    Try {
        # If statement to check that the above is true. 
        If ($CheckDG.PrimarySmtpAddress -notmatch $Email -and $CheckEmail -eq $true) {
            Write-Output ("The Action you selected was: $Action The Distribution Group $DistroGroup Does not exist. Please Select the Create Action.")
            #EXIT
        } Else {
            Write-Output ("The Action you selected was: $Action The Distribution Group $DistroGroup already exists.")
        }
    }
    Catch {
        Write-Output ("Issue Creating Distribution Group $DistroGroup")
        Write-Error -Message $_.Exception.Message
    }
}


IF ($Action -eq "Delete") {
    Try {
        # If statement to check that the above is true. 
        If ($CheckDG.PrimarySmtpAddress -match $Email -and $CheckEmail -eq $true) {
            Write-Output ("The Action you selected was: $Action The Distribution Group $DistroGroup Does not exist. This function is now creating the Distro group.")
            Remove-DistributionGroup -Identity $Email -BypassSecurityGroupManagerCheck -Confirm:$False -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
        } Else {
            Write-Output ("The Action you selected was: $Action The Distribution Group $DistroGroup Does not exist. Please Select the Create Action.")
            #EXIT
        }
    }
    Catch {
        Write-Output ("Issue Creating Distribution Group $DistroGroup")
        Write-Error -Message $_.Exception.Message
    }
} 

####################################################################################################################################################
####################################################################################################################################################

# Adding Default Owners to the Distribution Group!

####################################################################################################################################################
####################################################################################################################################################

TRY {
    Set-DistributionGroup -Identity $DistroGroup -ManagedBy @{Add="Email"} -BypassSecurityGroupManagerCheck -ErrorAction Stop -WarningAction SilentlyContinue  | Out-Null
    Set-DistributionGroup -Identity $DistroGroup -ManagedBy @{Remove="Email"} -BypassSecurityGroupManagerCheck -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
}
Catch {
    Write-Output ("Issue Adding Default Owners to the Distribution Group $DistroGroup")
    Write-Error -Message $_.Exception.Message
}

####################################################################################################################################################
####################################################################################################################################################

# Adding the Member to the DistributionGroup!

####################################################################################################################################################
####################################################################################################################################################

IF ($MemberAction -eq "AddMember") {
    Try {
        $CheckDistributionGroupMembers = (Get-DistributionGroupMember -Identity $DistroGroup).PrimarySmtpAddress
        $CurrentMembersList = $null

        Foreach ($CheckMember in $CheckDistributionGroupMembers) {

            If ($CheckMember -notmatch "!") {
                [String[]]$CurrentMembersList += (Get-Mailbox -Identity $CheckMember).PrimarySmtpAddress
            }
        }
        }
    Catch {
        Write-Error -Message $_.Exception.Message
    }

    IF ($GroupMember) {
        ForEach ($Name in $GroupMember) {
            Try {
                IF ($Name -in $CurrentMembersList) {
                    Write-Output ("The user: $Name is already a Member in the DistributionGroup: $DistroGroup")
                }
                ElseIf ($Name -notin $CurrentMembersList) {
                    Add-DistributionGroupMember -Identity $DistroGroup -Member $Name -BypassSecurityGroupManagerCheck -ErrorAction Stop -WarningAction SilentlyContinue -Confirm:$False | Out-Null
                    Write-Output ("The user: $Name is now being added to the Distribution Group: $DistroGroup.")   
                }
            }
            Catch {
                Write-Output ("Issue Adding Member: $Name to the Distribution Group: $DistroGroup")
                If ($_.Exception.Message -match "already a member of the group") {
                    Write-Output ("The user: $Name already exists in the Distribution Group: $DistroGroup.")
                }
                Else {
                    Write-Error -Message $_.Exception.Message
                }
            }
        }
    }
}#END IF ($MemberAction -eq "Add")

####################################################################################################################################################
####################################################################################################################################################

# Removing the Member from the DistributionGroup!

####################################################################################################################################################
####################################################################################################################################################

IF ($MemberAction -eq "RemoveMember") {
    Try {
        $CheckDistributionGroupMembers = (Get-DistributionGroupMember -Identity $DistroGroup).PrimarySmtpAddress
        $CurrentMembersList = $null

        Foreach ($CheckMember in $CheckDistributionGroupMembers) {

            If ($CheckMember -notmatch "!") {
                [String[]]$CurrentMembersList += (Get-Mailbox -Identity $CheckMember).PrimarySmtpAddress
            }
        }
        }
    Catch {
        Write-Error -Message $_.Exception.Message
    }

    IF ($GroupMember) {
        ForEach ($Name in $GroupMember) {
            Try {
                IF ($Name -in $CurrentMembersList) {
                    Remove-DistributionGroupMember -Identity $DistroGroup -Member $Name -BypassSecurityGroupManagerCheck -Confirm:$False -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
                    Write-Output ("The user: $Name is now being Removed from the Distribution Group: $DistroGroup.")
                }
                ElseIf ($Name -notin $CurrentMembersList) {
                    Write-Output ("The user: $Name isn't a member of the group of the Distribution Group: $DistroGroup.")  
                }
            }
            Catch {
                Write-Output ("Issue Removing Member $Name from the Distribution Group $DistroGroup")
                If ($_.Exception.Message -match "isn't a member of the group") {
                    Write-Output ("The user: $Name isn't a member of the group of the Distribution Group: $DistroGroup.")
                }
                ELSE {            
                    Write-Error -Message $_.Exception.Message
                }
            }
        }
    }
}#END IF ($MemberAction -eq "Remove")



####################################################################################################################################################
####################################################################################################################################################

#Adding the Owner to the DistributionGroup!

####################################################################################################################################################
####################################################################################################################################################

IF ($OwnerAction -eq "AddOwner") {
    Try {
        $CheckDistributionGroupOwners = (Get-DistributionGroup -Identity $DistroGroup).ManagedBy
        $CurrentOwnersList = $null

        Foreach ($CheckOwner in $CheckDistributionGroupOwners) {

            If ($CheckOwner -notmatch "!") {
                [String[]]$CurrentOwnersList += (Get-Mailbox -Identity $CheckOwner).PrimarySmtpAddress
            }
        }
        }
    Catch {
        Write-Error -Message $_.Exception.Message
    }

    IF ($Owner) {
        ForEach($Name in $Owner) {
            Try {
                IF ($Name -in $CurrentOwnersList) {
                    Write-Output ("The user: $Name is already an owner in the DistributionGroup: $DistroGroup")
                }
                ElseIf ($Name -notin $CurrentOwnersList) {
                    Set-DistributionGroup -Identity $DistroGroup -ManagedBy @{Add="$Name"} -BypassSecurityGroupManagerCheck -ErrorAction Stop -WarningAction SilentlyContinue  | Out-Null
                    Write-Output ("The user: $Name is now being added as an owner of the Distribution Group: $DistroGroup.")    
                }
            }
            Catch {
                Write-Output ("Issue Adding Owner: $Name to the Distribution Group: $DistroGroup")
                Write-Error -Message $_.Exception.Message
            }
        }
    }
}#END IF ($OwnerAction -eq "Add")

####################################################################################################################################################
####################################################################################################################################################

# Removing the owner from the DistributionGroup!

####################################################################################################################################################
####################################################################################################################################################

IF ($OwnerAction -eq "RemoveOwner") {
    Try {
        $CheckDistributionGroupOwners = (Get-DistributionGroup -Identity $DistroGroup).ManagedBy
        $CurrentOwnersList = $null

        Foreach ($CheckOwner in $CheckDistributionGroupOwners) {

            If ($CheckOwner -notmatch "!") {
                [String[]]$CurrentOwnersList += (Get-Mailbox -Identity $CheckOwner).PrimarySmtpAddress
            }
        }
        }
    Catch {
        Write-Error -Message $_.Exception.Message
    }

    IF ($Owner) {
        ForEach($Name in $Owner) {
            Try {
                IF ($Name -in $CurrentOwnersList) {
                    Set-DistributionGroup -Identity $DistroGroup -ManagedBy @{Remove="$Name"} -BypassSecurityGroupManagerCheck -Confirm:$False -ErrorAction Stop -WarningAction SilentlyContinue  | Out-Null
                    Write-Output ("The user $Name is now being removed as an owner of the Distribution Group $DistroGroup.")
                }
                ElseIf ($Name -notin $CurrentOwnersList) {
                    Write-Output ("The user: $Name isn't an owner of the group of the Distribution Group: $DistroGroup.")  
                }
            }
            Catch {
                Write-Output ("Issue Removing Owner: $Name from the Distribution Group: $DistroGroup")
                If ($_.Exception.Message -match "isn't an owner of the group") {
                    Write-Output ("The user: $Name isn't a member of the group of the Distribution Group: $DistroGroup.")
                }
                ELSE {            
                    Write-Error -Message $_.Exception.Message
                }
            }
        }
    }
}#END IF ($OwnerAction -eq "Remove")

####################################################################################################################################################
####################################################################################################################################################

# Allowing Outside Senders to the Distribution Group!

####################################################################################################################################################
####################################################################################################################################################

Try {
    IF ($AllowOutsideSenders -eq "Yes") {
        Set-DistributionGroup -Identity $DistroGroup -RequireSenderAuthenticationEnabled:$false -ErrorAction Stop -WarningAction SilentlyContinue 
        Write-Output ("People outside the organization ARE allowed to send an Email to this group: $DistroGroup")
    }
    ElseIf ($AllowOutsideSenders -eq "No") {
        Set-DistributionGroup -Identity $DistroGroup -RequireSenderAuthenticationEnabled:$true -ErrorAction Stop -WarningAction SilentlyContinue 
        Write-Output ("People outside the organization are NOT allowed to send an Email to this group: $DistroGroup")
    }
    ElseIf ($AllowOutsideSenders -eq "Null") {
        Write-Output ("Allow Outside Senders option has not changed for the Distribution Group: $DistroGroup")
    }
}
Catch {
    Write-Output ("Issue Allowing Outside Senders to the Distribution Group $DistroGroup")
    Write-Error -Message $_.Exception.Message
}

####################################################################################################################################################
####################################################################################################################################################

}#END Process
END {}#END END
}#END

$ParentPath = (Get-ChildItem -Path $MyInvocation.InvocationName).DirectoryName

$Path = "$ParentPath\Center.xlsx"

$Path2 = "$ParentPath\Trans.xlsx"

$Excel = Import-Excel -Path $Path

$Excel2 = Import-Excel -Path $Path2

# This is a PowerShell Dictionary of all of the group members email addresses, that will be added to the distroibution groups.
$Dictionary = @{} 

# This is a PowerShell Dictionary of all the Distribution group names to their abbreaveated name.
$Trans = @{}

# This is a loop for $Excel2 to loop through all of the $trans Dictionary items and set them to the coresponding abbreaveated names.   
ForEach ($Row2 in $Excel2) {

    IF ($Row2.'DC Abbreviation') {
        $Trans.item($Row2.'DC Abbreviation') = $Row2.'DC Name'
    }
}
# This is a loop for $Excel to loop through all of the $Emails in the $Dictionary items and set them to the coresponding $Row abbreaveated names.   
ForEach ($Row in $Excel) {
    
    $Emails = @()

    IF ($Row.'Business Consultant') {
        $BCEmail = (($Row.'Business Consultant') -replace " ",".") + "@Company.com"
        $Emails += ($BCEmail)
    }

    IF ($Row.'Email') {
        $Emails += ($Row.'Email')
    }

    IF ($Row.'Email - Primary') {
        $Emails += ($Row.'Email - Primary')
    }

    IF ($Row.'Distribution Center') {
        $Dictionary.Item($Row.'Distribution Center') += $Emails
    }
}

# This will loop through all of the Distribution Group Names.
ForEach ($DistributionGroup in $Dictionary.Keys) {
    
    # These are all of the group members from the excel list.
    $GroupMember = $Dictionary.Item($DistributionGroup)
    
    # These are all of the translated Distribution Group names from the Abbreviated list.
    $DistroGroup = ("!" + ($Trans.item($DistributionGroup)))
    
    # This sets the distribution group names
    $DistroEmail = (($Trans.item($DistributionGroup) -replace " ","") + "@Company.com")

    # This is a Check to see if the Distribution Group exists
    $CheckDG = ((Get-DistributionGroup -Identity $DistroEmail -ErrorAction SilentlyContinue -WarningAction SilentlyContinue).PrimarySmtpAddress)
    
    IF ($CheckDG) {
        Write-Host -ForegroundColor Cyan ("The Distribution Group: $DistroEmail already exist.")
        
        $RemoveMembers = ((Get-DistributionGroupMember -Identity $DistroEmail).PrimarySmtpAddress) 

        ForEach ($Member in $RemoveMembers) {
            Set-Office365Distro -Action 'Edit' -DistroGroup $DistroGroup -MemberAction 'RemoveMember' -GroupMember $Member -Email $DistroEmail
        }#>

        ForEach ($Member in $GroupMember) {
            Set-Office365Distro -Action 'Edit' -DistroGroup $DistroGroup -MemberAction 'AddMember' -GroupMember $Member -Email $DistroEmail
        }#>
    }
    Else {
        Write-Host -ForegroundColor Yellow ("The Distribution Group: $DistroEmail does NOT exist.")
        Write-Host -ForegroundColor Green ("Creating Distribution Group: $DistroGroup with the email address being $DistroEmail")
        Set-Office365Distro -Action 'Create' -DistroGroup $DistroGroup -Email $DistroEmail -AllowOutsideSenders 'Yes'
        ForEach ($Member in $GroupMember) {
            Set-Office365Distro -Action 'Edit' -DistroGroup $DistroGroup -MemberAction 'AddMember' -GroupMember $Member -Email $DistroEmail
        }
    }
}
