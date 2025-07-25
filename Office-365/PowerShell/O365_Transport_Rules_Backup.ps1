## Get Connected to MSOL via Hash
Import-Module MSOnline
Import-Module LyncOnlineConnector
$User = "O365SyncAdmin_MS@Company.onmicrosoft.com"
$Hash = "$folder\Hash.txt"
[Byte[]]$Key = (9,8,8,8,6,4,4,3,6,7,3,9,5,9,4,3)
$Pass = Get-Content $Hash | ConvertTo-SecureString -Key $Key
$Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $User, $Pass
Connect-MsolService -Credential $Credential
$O365 = New-PsSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -AllowRedirection -Authentication Basic
Import-PsSession $O365 -AllowClobber


## Delete Old Backups First ##
$limit = (Get-Date).AddDays(-30)
$path = "$folder\Backups"
Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
## End Delete Backups ##


## Log Variables ##
$Date = Get-Date -Format yyyyMMdd_HHmmss
$LogPath = "$folder\Backups\folder_$Date.xml"

## Export Content ##
$File = Export-TransportRuleCollection
Set-Content -Path $LogPath -Value $File.FileData -Encoding Byte