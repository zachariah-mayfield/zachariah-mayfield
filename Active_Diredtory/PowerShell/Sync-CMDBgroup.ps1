CLS

IF ($param4 -eq $NULL) { $acontacts = $param3}
ELSE { $acontacts = ($param4) -replace " ",""}

Function Sync-CMDBgroup {

[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
        [Parameter(ParameterSetName="Action")]
        [ValidateSet("New","Update","Delete")]
        [String]$Action=$param1,
        [String]$ServerName=$param2,
        [String]$OwnerEmail=$param3,
        [String[]]$Additional_Contacts=$acontacts.split(";")
    )
Begin{
#$KEY = & "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=$AppID /p Query="Safe=$Safe;Folder=Root;Object=$Object" /o Password
$KEY = 
$User = "O365Sync.ServiceNow@Company.onmicrosoft.com"
$PWord = ConvertTo-SecureString -String $KEY -AsPlainText -Force
$UserCredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord

try {
## Create New PS Session

$msoExchangeURL = "https://outlook.office365.com/powershell-liveid/"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $msoExchangeURL -Credential $UserCredential -Authentication Basic -AllowRedirection
$ImportedSession = Import-PSSession $Session -DisableNameChecking 

}#END TRY
catch{
  Write-Error -Message $_.Exception.Message
}#END CATCH

# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}

Process {

######################################################################################################
######################################################################################################

IF ($Action -eq "New") {

    Write-Host -ForegroundColor Cyan "Action: " $Action
    
    ForEach ($Contact in $Additional_Contacts) {

        $CheckEmail = ($Contact -as [System.Net.Mail.MailAddress]).Address -eq $Contact -and $Contact -ne $null

        IF ($CheckEmail -eq $true) {

            If (Get-MailContact -Anr $Contact) {
                Write-Host -ForegroundColor Yellow $Contact 'is a already an Office 365 Contact.'
            }
            Else {
                New-MailContact -Name $Contact -ExternalEmailAddress $Contact -Verbose -ErrorAction SilentlyContinue   
            }

            $CheckDG = Get-DistributionGroup -Identity $ServerName -ErrorAction SilentlyContinue

            If ($CheckDG -eq $null) {
                Write-Host -ForegroundColor Cyan "The Distribution Group $ServerName Does not exist. This function is now creating the Distro group."
                $Email = ($ServerName + "@Company-x.com")
                New-DistributionGroup -Name $ServerName -DisplayName $ServerName -Type Security -PrimarySmtpAddress $Email -ErrorAction SilentlyContinue | Out-Null
            } Else {
                Write-Host -ForegroundColor Cyan "The Distribution Group $ServerName already exists."
            }

            $Owner = (Get-Mailbox -Identity $OwnerEmail -ErrorAction SilentlyContinue).UserPrincipalName

            Set-DistributionGroup -Identity $ServerName -ManagedBy @{Add="$Owner"} -BypassSecurityGroupManagerCheck -Verbose -ErrorAction SilentlyContinue

            $CheckDGM = Get-DistributionGroupMember -Identity $ServerName -ErrorAction SilentlyContinue

            IF ($CheckDGM -match $Contact){
                Write-Host -ForegroundColor Cyan $Contact "is already a member of the Distribution Group" $ServerName
            } ELSE {
                Add-DistributionGroupMember -Identity $ServerName -Member $Contact -BypassSecurityGroupManagerCheck -Verbose -Confirm:$false -ErrorAction SilentlyContinue
            }
        }#END IF ($CheckEmail -eq $true)
    }#END ForEach ($Contact in $Additional_Contacts)
}#END IF ($Action -eq "New")

IF ($Action -eq "Update") {
    
    Write-Host -ForegroundColor Cyan "Action: " $Action
    
    ForEach ($Contact in $Additional_Contacts) {
        
        $CheckEmail = ($Contact -as [System.Net.Mail.MailAddress]).Address -eq $Contact -and $Contact -ne $null

        IF ($CheckEmail -eq $true) {

            If (Get-MailContact -Anr $Contact) {
                Write-Host -ForegroundColor Yellow $Contact 'is a already an Office 365 Contact.'
            }
            Else {
                New-MailContact -Name $Contact -ExternalEmailAddress $Contact -Verbose -ErrorAction SilentlyContinue  
            }

            $CheckDG = Get-DistributionGroup -Identity $ServerName -ErrorAction SilentlyContinue

            If ($CheckDG -eq $null) {
                Write-Host -ForegroundColor Cyan "The Distribution Group $ServerName Does not exist."
            }
            Else {
                Write-Host -ForegroundColor Cyan "The Distribution Group $ServerName already exists."
            }

            $CheckDGM1 = Get-DistributionGroupMember -Identity $ServerName ################

            IF ($CheckDGM1 -match $Contact){
                Write-Host -ForegroundColor Cyan $Contact "is already a member of the Distribution Group" $ServerName
            }
            ELSE {
                Add-DistributionGroupMember -Identity $ServerName -Member $Contact -BypassSecurityGroupManagerCheck -Verbose -Confirm:$false -ErrorAction SilentlyContinue
            }
        }#END IF ($CheckEmail -eq $true)
    }#END ForEach ($Contact in $Additional_Contacts)

    $CheckDGM2 = Get-DistributionGroupMember -Identity $ServerName -ErrorAction SilentlyContinue

    ForEach ($Contact in $CheckDGM2) {
        IF ($Contact -notin $Additional_Contacts) {
            Write-Host -ForegroundColor Yellow "Removing user: " $Contact
            Remove-DistributionGroupMember -Identity $ServerName -Member $contact.name -BypassSecurityGroupManagerCheck -Confirm:$False -Verbose -ErrorAction SilentlyContinue
        } 
    }

    ForEach ($Contact in $Additional_Contacts) {
        IF ($Contact -notin $CheckDGM2.name) {
            Write-Host -ForegroundColor Green "Adding user: " $Contact
            Add-DistributionGroupMember -Identity $ServerName -Member $Contact -BypassSecurityGroupManagerCheck -Verbose -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

}#END IF ($Action -eq "Update")

IF ($Action -eq "Delete") {
    Write-Host -ForegroundColor Cyan $Action

    $Group = Get-DistributionGroup -Identity $ServerName -ErrorAction SilentlyContinue

IF ($Group) {
    Remove-DistributionGroup -Identity $ServerName -Confirm:$false -Verbose -ErrorAction SilentlyContinue
} Else {
    Write-Host -ForegroundColor Yellow $ServerName "does not exist."
}

}#END IF ($Action -eq "Delete")

IF ($AllowOutsideSenders) {
Set-DistributionGroup -Identity $ServerName -RequireSenderAuthenticationEnabled:$false
Write-Host -ForegroundColor Cyan "People outside the organization are now allowed to send to this group: " $ServerName
}

######################################################################################################
######################################################################################################

}# END Proccess
END {GSN|RSN}
}# END Function Sync-CMDB 

Sync-CMDBgroup
