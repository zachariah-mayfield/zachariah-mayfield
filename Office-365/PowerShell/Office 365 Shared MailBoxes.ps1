CLS


$KEY = & "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=xxxxxx /p Query="Safe=xxxxxx;Folder=Root;Object=xxxxxx" /o Password
 
$User = "xxxxxx.com"
$PWord = ConvertTo-SecureString -String $KEY -AsPlainText -Force
$UserCredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord

$array_SendAsMember=$Email.split(",")
$array_FullAccessMember=$Email.split(",")
$array_RemoveMember=$Email.split(",")


try {


$msoExchangeURL = "https://outlook.office365.com/powershell-liveid/"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $msoExchangeURL -Credential $UserCredential -Authentication Basic -AllowRedirection
$ImportedSession = Import-PSSession $Session -DisableNameChecking 

}#END TRY
catch{
  Write-Error -Message $_.Exception.Message
}#END CATCH


TRY{
IF ($param4 -eq "Add-O365SharedMailBox") {
    IF ($param6 -eq $null) {
        Add-Office365Shared -SharedBox $param1 -Email $param2 -SendAsMember $array_SendAsMember -FullAccessMember $array_FullAccessMember -Department $param5 -Company $param8 -Title $param7
        Write-Host "Office365 Automation:" $param4 "function executed successfully"
    }
Else{    
    Add-Office365Shared -SharedBox $param1 -Email $param2 -SendAsMember $array_SendAsMember -FullAccessMember $array_FullAccessMember -Department $param5 -Company $param8 -Manager $param6 -Title $param7
    Write-Host "Office365 Automation:" $param4  "function executed successfully"
}
}   
}#END TRY
Catch {
    Write-Host "`n"
    Write-Host -ForegroundColor DarkYellow "Office365 Automation: Powershell Function" $param4 "Errors generated" 
    Write-Host -ForegroundColor Yellow "Please investigate source of powershell errors"
    Write-Error -Message $_.Exception.Message
}

TRY{
IF ($param4 -eq "Remove-O365SharedMailBox")  {
    Remove-Office365Shared -SharedBox $param1 -RemoveMember $array_RemoveMember
    Write-Host "Office365 Automation:" $param4 "function executed successfully"
}
}#END TRY
Catch {
    Write-Host "`n"
    Write-Host -ForegroundColor DarkYellow "Office365 Automation: Powershell Function" $param4 "Errors generated" 
    Write-Host -ForegroundColor Yellow "Please investigate source of powershell errors"
    Write-Host "Office365 Automation: Invalid parameters passed to the script!"
    Write-Error -Message $_.Exception.Message
}

Get-PSSession | Remove-PSSession