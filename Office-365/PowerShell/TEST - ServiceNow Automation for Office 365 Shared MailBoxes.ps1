CLS



$FunctionName = "Add-O365SharedMailBox"
$SharedBox = "xxxd03"
$Email = "xxxd03@Company.onmicrosoft.com"
$array_SendAsMember = "Username@Company.onmicrosoft.com"
$array_FullAccessMember = "Username@Company.onmicrosoft.com"
$array_RemoveMember = "Username@Company.onmicrosoft.com"
$Department = "1"
$Company = "2"
$Manager = ""
$Title = "3"

<#
try {
## Create New PS Session

#This is the Site
$msoExchangeURL = "https://outlook.office365.com/powershell-liveid/"

#This connects to Office 365
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $msoExchangeURL -Credential $UserCredential -Authentication Basic -AllowRedirection

#This Imports the PSSession for Office 365
Import-PSSession $Session 

}#END TRY
catch{
  Write-Error -Message $_.Exception.Message
}#END CATCH
#>


TRY{
IF ($FunctionName -eq "Add-O365SharedMailBox") {
    IF ($Manager -eq $null) {
        Write-Host -ForegroundColor Yellow "Manager was null."
        Add-Office365Shared -SharedBox $SharedBox -Email $Email -SendAsMember $array_SendAsMember -FullAccessMember $array_FullAccessMember -Department $Department -Company $Company -Title $Title
    }
Else{    
    Add-Office365Shared -SharedBox $SharedBox -Email $Email -SendAsMember $array_SendAsMember -FullAccessMember $array_FullAccessMember -Department $Department -Company $Company -Manager $Manager -Title $Title
    Write-Host "Office365 Automation:" $FunctionName "function executed successfully"
}
}   
}#END TRY
Catch {
    Write-Host "`n"
    Write-Host -ForegroundColor DarkYellow "Office365 Automation: Powershell Function" $FunctionName "Errors generated" 
    Write-Host -ForegroundColor Yellow "Please investigate source of powershell errors"
    Write-Error -Message $_.Exception.Message
}


TRY{
IF ($FunctionName -eq "Remove-O365SharedMailBox")  {
    Remove-Office365Shared -SharedBox $SharedBox -RemoveMember $array_RemoveMember
    Write-Host "Office365 Automation:" $FunctionName "function executed successfully"
}
}#END TRY
Catch {
    Write-Host "`n"
    Write-Host -ForegroundColor DarkYellow "Office365 Automation: Powershell Function" $FunctionName "Errors generated" 
    Write-Host -ForegroundColor Yellow "Please investigate source of powershell errors"
    Write-Host "Office365 Automation: Invalid parameters passed to the script!"
    Write-Error -Message $_.Exception.Message
}

#Get-PSSession | Remove-PSSession
