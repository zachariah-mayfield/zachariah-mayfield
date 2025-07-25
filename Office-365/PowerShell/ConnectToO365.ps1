## Import necessary modules
Import-Module MSOnline 
Import-Module ActiveDirectory
Clear-Host # For readability in the console


## Get Connected to MSOL
$User = "xxxxxxxxxxx.onmicrosoft.com"
$Hash = "xxxxxxxx.txt"
[Byte[]]$Key = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
$Pass = Get-Content $Hash | ConvertTo-SecureString -Key $Key
$Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $User, $Pass

Connect-MsolService -Credential $Credential

$O365 = New-PsSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $Credential -AllowRedirection -Authentication Basic
Import-PsSession $O365

xxx New-CsOnlineSession -Credential $credential
Import-PSSession $xxx