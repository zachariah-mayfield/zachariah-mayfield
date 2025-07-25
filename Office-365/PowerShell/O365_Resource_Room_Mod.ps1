## Get Connected to MSOL via Hash
Import-Module MSOnline
Import-Module LyncOnlineConnector

## Check Session Count Before Creating New One ##
$SessionsCount = (Get-PSSession | Where-Object {$_.ComputerName -like "outlook.office365.com"}).Count
If ($SessionsCount -ge 2) { Remove-PSSession -ComputerName "outlook.office365.com" }

$User = "xxx@Company.onmicrosoft.com"
$Hash = "$PSSCRIPTROOT\Hash.txt"
[Byte[]]$Key = (9,8,8,8,6,4,4,3,6,7,3,9,5,9,4,3)
$Pass = Get-Content $Hash | ConvertTo-SecureString -Key $Key
$Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $User, $Pass
Connect-MsolService -Credential $Credential
$O365 = New-PsSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -AllowRedirection -Authentication Basic -Name "AutomatedSessionResourceRoom"
Import-PsSession $O365 -AllowClobber

$StartTime = Get-Date

## Search for all Rooms and set values
$Resources = Get-MailBox -resultsize unlimited -Filter 'ResourceType -eq "Room" -or ResourceType -eq "Equipment"'
$n = $Resources.count  
$i = 1

Foreach ($resource in $Resources) {
    $percent = ($i / $n * 100)
    Write-Progress -Activity "Updates in Progress" -Status "$percent% Complete" -PercentComplete $percent;
    #Write-Host $resource.DisplayName -ForegroundColor Gray
    $p = Get-CalendarProcessing -Identity $resource.samaccountname
    IF ($p.DeleteSubject -ne $false -or $p.AddOrganizerToSubject -ne $false -or $p.AllRequestOutOfPolicy -ne $false -or $p.AddNewRequestsTentatively -ne $false) {
        Write-Host ($resource.DisplayName +"`t"+ $resource.Name) -ForegroundColor Cyan
        Set-CalendarProcessing -Identity $resource.samaccountname -DeleteSubject $False -AddOrganizerToSubject $False -AllRequestOutOfPolicy $False -AddNewRequestsTentatively $False
    }
    $i++
}


### END PSSESSION ###
Remove-PSSession -Name "AutomatedSessionResourceRoom"

$EndTime = Get-Date

Write-Host "$StartTime`t$EndTime"