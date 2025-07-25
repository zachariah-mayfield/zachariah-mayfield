Clear-Host

$Identity_Reference = "Domain\Security-Group"
$ActiveDirectory_Rights = "GenericAll"
$AccessControlType = "Allow"
$ObjectType = "00000000-0000-0000-0000-000000000000"
$InheritedObjectType = "00000000-0000-0000-0000-000000000000"

$Computer = "ServerName"
$Path = "AD:\CN=$($Computer). OU=ServerGroup, OU=Clusters, OU=Servers, DC=xxx, DC=xxx, DC=xxx"
$USR = 'CN=OU=ServerGroup, DC=xxx, DC=xxx, DC=xxx'
$User = (Get-ADObject $USR | Get-ADUser)
$ACL = Get-Acl -Path "AD:\CN=$($Computer). OU=ServerGroup, OU=Clusters, OU=Servers, DC=xxx, DC=xxx, DC=xxx"

$ACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
    $User.sid,
    [System.DirectoryServices.ActiveDirectoryRights]::$ActiveDirectory_Rights,
    [System.Security.AccessControl.AccessControlType]::$AccessControlType,
    'XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXX',
    [System.DirectoryServices.ActiveDirectorySecurityInheritance]::All
)

$ACL.AddAccessRule($ACE)
Set-Acl -Path $Path -AclObject $ACL -Verbose
