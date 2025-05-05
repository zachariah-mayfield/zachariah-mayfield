
Param(
  [string]$storenumber,
  [string]$email
)

$storenumber = $storenumber.Trim()
$email = $email.Trim()
$computer = $storenumber + ".pos.Company-x.com"
$current_date = Get-Date -Format "MM-dd-yyyy"
$path = "D:\KEVLAR_$storenumber`_$current_date`_POST.TXT"


#1.Get Meraki Switch Status
try {
$meraki_output = Invoke-Command -Command {D:\python.exe D:\MerakiHealthCheck.py $storenumber}
$meraki_output 
$meraki_output | Out-File $path
} catch {
Write-Output "There was an error executing the command for Meraki Switch Status" | Out-File $path -Append
Write-Error -Message $_.Exception.Message | Out-File $path -Append
}


#2.WAN1 Check Device Status
try {
$wan1_output = Invoke-Command -Command {D:\python.exe D:\WAN1Status.py $storenumber}
$wan1_output 
$wan1_output | Out-File $path -Append
} catch {
Write-Output "There was an error executing the command for Fortigate Router WAN1 Status" | Out-File $path -Append
Write-Error -Message $_.Exception.Message | Out-File $path -Append
}


# Printing Blank Line to make each output more readable
Write-Output "`n"
Write-Output "`n" | Out-File $path -Append


#3.Cradlepoint Check Device Status
try {
$cradelpoint_output = Invoke-Command -Command {D:\python.exe D:\CradlepointStatus.py $storenumber}
$cradelpoint_output 
$cradelpoint_output | Out-File $path -Append
} catch {
Write-Output "There was an error executing the command for Cradlepoint Device Status" | Out-File $path -Append
Write-Error -Message $_.Exception.Message | Out-File $path -Append
}


#4.Check Aerohive NG Device Status
try {
$aerohive_output = Invoke-Command -Command {D:\python.exe D:\AerohiveCheck.py $storenumber}
$aerohive_output 
$aerohive_output | Out-File $path -Append
} catch {
Write-Output "There was an error executing the command for Aerohive AccessPoint Status" | Out-File $path -Append
Write-Error -Message $_.Exception.Message | Out-File $path -Append
}


# Get Service Account Credential and Create PS Session

try {
# The $Key variable gets the Cyber Ark password from our CyberArk.com account
$CyberArkPassword = & "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=$AppID /p Query="Safe=$Safe;Folder=Root;Object=$Object" /o Password

# The $UserName variable sets the UserName of the PSCredential
$UserName = "Company\username"

# The $Password variable sets the Password of the PSCredential
$Password = ConvertTo-SecureString -String $CyberArkPassword -AsPlainText -Force

# The $Credential variable creates the PSCredential for the CyberArk Account and password
$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $UserName, $Password
} catch {
Write-Output "There was an error executing the command to retrieve Cyberark Credentials" | Out-File $path -Append
Write-Error -Message $_.Exception.Message | Out-File $path -Append
}

try {
# Create PS Session
$Session = New-PSSession -ComputerName $computer -Authentication Negotiate -Configuration "ModuleLoad" -SessionOption (
New-PSSessionOption -ApplicationArguments @{"ModuleName"="monitoring"}) -credential $Credential
} catch {
Write-Output "There was an error executing the command to create a PowerShell remote session" | Out-File $path -Append
Write-Error -Message $_.Exception.Message | Out-File $path -Append
}

<#
#5.Check POS Network Health
try {
$network_health_output = Invoke-Command -Session $Session -Command {Get-NetworkHealth}
$network_health_output
$network_health_output | Out-File $path -Append
} catch {
Write-Output "There was an error executing the command for POS Network Health Status"
Write-Error -Message $_.Exception.Message
}
#>

#6.Check Register Nodes
try {
$node_output = Invoke-Command -Session $Session -Command {Get-NodeNumbers}
$node_output 
$node_output | Out-File $path -Append
} catch {
Write-Output "There was an error executing the command for POS Register Node Status" | Out-File $path -Append
Write-Error -Message $_.Exception.Message | Out-File $path -Append
Remove-PSSession $Session
}


#7.Ping BYOD devices
try {
$byod_output = Ping-BYOD $storenumber
$byod_output 
$byod_output | Out-File $path -Append
} catch {
Write-Output "There was an error executing the command for Company Switch Device Status" | Out-File $path -Append
Write-Error -Message $_.Exception.Message | Out-File $path -Append
}


#8.Email POST Kevlar Validation Results
try {
Send-MailMessage -To $email,"Kevlar Validation Script Logs <KevlarValidationScriptLogs@Company-x.com>" -From "Kevlar Admin <kevlar.validation@Company-x.com>" -Subject "POST Kevlar Validation Results for $storenumber" -Body "These are the attached results from the Kevlar POST-Validation Automation for $storenumber" -Attachments $path -SmtpServer "smtp.Company-x.com"
} catch {
Write-Output "There was an error executing the command to send email results of the Kevlar POST Validation.
If you have not reran the validation before, try again to see if email is sent. Otherwise, please proceed with manual validation steps." | Out-File $path -Append
Write-Error -Message $_.Exception.Message | Out-File $path -Append
}


#Remove PS Session
Remove-PSSession $Session