CLS

###########################################################################################################################################
###########################################################################################################################################

# Create a new Conference Room in Office365

# Connect to CyberArk and retreive password
$KEY = & "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=$AppID /p Query="Safe=$Safe;Folder=Root;Object=$Object" /o Password

$User = "O365Sync.ServiceNow@Company.onmicrosoft.com"
$PWord = ConvertTo-SecureString -String $KEY -AsPlainText -Force
$UserCredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord

$URL = "https://outlook.office365.com/powershell-liveid/"

try {
## Create New PS Session
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $URL -Credential $UserCredential -Authentication Basic -AllowRedirection 
    Import-PSSession $Session
}#END TRY
catch{
    Write-Error -Message $_.Exception.Message
}#END CATCH

###########################################################################################################################################
###########################################################################################################################################

[String]$RoomName=""
[int]$Capacity=""
[String]$Phone=""
[String]$AutoResponseMessage=""
[String]$Notes=""
[String]$RoomRegion=""
[String[]]$AdminMember=""

Add-Office365Resource -RoomName $RoomName -Capacity $Capacity -Phone $Phone -AutoResponseMessage $AutoResponseMessage -Notes $Notes -RoomRegion $RoomRegion -AdminMember $AdminMember

<#

if ($RoomName -ne $null) {
    Add-Office365Resource -RoomName $RoomName
    }

elseif ($Capacity -ne $null) {
    Add-Office365Resource -RoomName $RoomName -Capacity $Capacity
    }

elseif ($Phone -ne $null) {
    Add-Office365Resource -RoomName $RoomName -Phone $Phone
    }

elseif ($AutoResponseMessage -ne $null) {
    Add-Office365Resource -RoomName $RoomName -AutoResponseMessage $AutoResponseMessage
    }

elseif ($Notes -ne $null) {
    Add-Office365Resource -RoomName $RoomName -Notes $Notes
    }

elseif ($RoomRegion -ne $null) {
    Add-Office365Resource -RoomName $RoomName -RoomRegion $RoomRegion
    }

elseif ($AdminMember -ne $null) {
    Add-Office365Resource -RoomName $RoomName -AdminMember $AdminMember
    }

else {
    Write-Error -Message "Office365 Automation: Invalid parameters passed to the script!"
}

#>