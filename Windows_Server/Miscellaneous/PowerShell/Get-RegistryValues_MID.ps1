CLS

$ComputerNames = Get-Content -Path C:\TEST\POS-ServerName-List.txt

# The $Key variable gets the Cyber Ark password from our CyberArk.com account
$CyberArkPassword = & "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=$AppID /p Query="Safe=$Safe;Folder=Root;Object=$Object" /o Password

# The $UserName variable sets the UserName of the PSCredential
$UserName = "Company\pos_mon_service"

# The $Password variable sets the Password of the PSCredential
$Password = ConvertTo-SecureString -String $CyberArkPassword -AsPlainText -Force

# The $Credential variable creates the PSCredential for the CyberArk Account and password
$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $UserName, $Password

ForEach ($Computer in $ComputerNames) {
Try {
# The $Session variable creates the PS Session to the remote computer
$Session = New-PSSession -ComputerName $Computer -Authentication Negotiate -Configuration "ModuleLoad" -SessionOption (
New-PSSessionOption -ApplicationArguments @{"ModuleName"="monitoring"}) -credential $Credential -ErrorAction Stop -ErrorVariable "SessionERROR"

# $Message = ("$Computer" + " " + "$Session.State")

 $Session | select computername, state | Format-Table -AutoSize

 Invoke-Command -Session $Session -Command {Get-RegistryValues} | Out-File C:\TEST\Modified.TXT -Append

}
Catch {

# $SessionERROR

$Message = ("Access Denied") 


$Properties = @{'Location Number'  =   $Computer;
                'Message'          =   $Message;}#END $Properties

$Output = New-Object -TypeName psobject -Property $Properties

Write-Output $Output | Format-Table -Property 'Location Number', 'Message' -AutoSize 

Write-Output $Output | Format-Table -Property 'Location Number', 'Message' -AutoSize | Out-File C:\TEST\AccessDenied.TXT -Append

}

}

GSN | RSN
