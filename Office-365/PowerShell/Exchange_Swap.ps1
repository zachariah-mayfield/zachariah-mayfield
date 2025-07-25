## Get Connected to MSOL via Hash
Import-Module MSOnline
Import-Module LyncOnlineConnector

$User = "username@Company.com"
$Hash = "C:\Folder\Hash.txt"
[Byte[]]$Key = (1234567)
$Pass = Get-Content $Hash | ConvertTo-SecureString -Key $Key
$Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $User, $Pass
Connect-MsolService -Credential $Credential
$O365 = New-PsSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -AllowRedirection -Authentication Basic
Import-PsSession $O365 -AllowClobber
#$SFB = New-CsOnlineSession -Credential $credential
#Import-PSSession $SFB -AllowClobber
#

$Time = Get-Date -Format yyyyMMddHHmmss
$current2 = Get-Mailbox -ResultSize Unlimited | Get-MailboxPermission -User "username@Company.com"
$count = $current.count
$i = 1
"Identity, User, AccessRights" | Add-Content "C:\Folder\_$Time.log" 

foreach ($item in $current){
    Write-Host "Processing $i out of $count"
    $user = $item.Identity

    #$permission = Add-MailboxPermission -Identity $item.Identity -User "username@Company.com" -AccessRights FullAccess -InheritanceType All -AutoMapping $false -Confirm:$false
    
    $permission2 = Remove-MailboxPermission -Identity $item.Identity -User "username@Company.com" -AccessRights SendAs -InheritanceType All -Confirm:$false

    $access = $permission2.User
    $rights = $permission2.AccessRights

    "$user, $access, $rights" | Add-Content "C:\Folder\2_$Time.log" 
    $i++

    
    }

    