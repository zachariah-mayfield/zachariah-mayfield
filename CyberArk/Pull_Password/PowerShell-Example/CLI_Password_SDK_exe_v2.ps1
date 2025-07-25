CLS

# $Param1 = UserName Parameter Array (Requested for)
$Param1 = "xxx","xxx"

# $Param2 = SecurityGroupRole Parameter String (Role)
$Param2 = "xxx"

# $Param3 = SecurityGroupNumber Parameter Array (Account Number)
$Param3 = "xxx","xxx"

# The $Key variable gets the Cyber Ark password from our CyberArk.com account
$CyberArkPassword = (& "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=$AppID /p Query="Safe=xxx;Folder=Root;Object=xxx" /o Password)

# The $UserName variable sets the UserName of the PSCredential
$UserName = "xxx\xxx@xxx.com"

$Password = "xxx"

# The $Password variable sets the Password of the PSCredential
$Password = ConvertTo-SecureString -String $CyberArkPassword -AsPlainText -Force

# The $Credential variable creates the PSCredential for the CyberArk Account and password
$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $UserName, $Password

Invoke-Command -Command {Add-ADUserToSecurityGroup -UserName $Param1 -SecurityGroupRole $Param2 -SecurityGroupNumber $Param3 -Credential $Credential}
