## Get Connected to MSOL via Hash
Import-Module MSOnline
Import-Module LyncOnlineConnector

$User = "admin@Companyt.com"
$Hash = "$PSScriptRoot\Hash.txt"
[Byte[]]$Key = (9,8,8,8,6,4,4,3,6,7,3,9,5,9,4,3)
$Pass = Get-Content $Hash | ConvertTo-SecureString -Key $Key
$Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $User, $Pass
Connect-MsolService -Credential $Credential
$O365 = New-PsSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -AllowRedirection -Authentication Basic
Import-PsSession $O365 -AllowClobber

Clear-Host


$Date = Get-Date -Format yyyyMMddhhmmss
$Log = "$PSScriptRoot\O365\Logs\LastPasswordChange_$Date.csv"


"UPN;DisplayName;LastPasswordChange" | Add-Content $Log


Write-Host "Retrieving Data..." -ForegroundColor Cyan


##Last PasswordChangeForAll
$AllResults = get-msoluser -MaxResults 1000000 | Select UserprincipalName,DisplayName,LastPasswordChangeTimeStamp | Sort -Property LastPasswordChangeTimeStamp
$Results = @()


Foreach ($Result in $Results) {
    $upn = $Result.userprincipalname
    $dn = $Result.displayname
    $lpc = $Result.LastPasswordChangeTimeStamp

    #Write-Host "$upn;$dn;$lpc"
    "$upn;$dn;$lpc" | Add-Content $Log

}