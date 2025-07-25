CLS

$KEY = & "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=xxxxxxxxxxxxxxx /p Query="Safe=xxxxxxxxxxxxxxx;Folder=Root;Object=xxxxxxxxxxxxxxx" /o Password
$User = "xxxxxxxxxxxxxxx.com"
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

$array_param3=$param3.split(",")

try {
    if ($param5 -eq "Add-O 365Group") {
        Add-Office365Distro -DistroGroup $param1 -Email $param2 -GroupMember $array_param3 -Owner $param4 -AllowOutsideSenders $param6
        Write-Host "Office365 Automation:" $param5 "function executed successfully"
    }
    elseif ($param5 -eq "EditAdd-O365Group") {
        Add-Office365Distro -DistroGroup $param1 -Email $param2 -GroupMember $array_param3 -Owner $param4
        Write-Host "Office365 Automation:" $param5 "function executed successfully"
    }
    elseif ($param5 -eq "EditRemove-O365Group") {
        Remove-Office365Distro -DistroGroup $param1 -Email $param2 -GroupMember $array_param3
        Write-Host "Office365 Automation:" $param5 "function executed successfully"
    }
    else {
        Write-Error -Message "Office365 Automation: Invalid parameters passed to the script!"
    }

}#END TRY
catch{
  Write-Error -Message $_.Exception.Message
}#END CATCH

GSN | RSN