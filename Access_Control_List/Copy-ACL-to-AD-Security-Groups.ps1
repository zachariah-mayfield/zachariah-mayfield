Clear-Host

# Import-Module -Name ActiveDirectory

$Location = "AD:\OU=ServerName, OU=Clusters, OU=Servers, DC=xxx, DC=AD, DC=Cube"

If ((Get-Location)-ne $Location) {
    Set-Location $Location
}

$ACL = (Get-Acl "CN=ServerName")
$Children = Get-ChildItem | Where-Object {$_.Name -notlike "Name*$ServerName_Group"}

ForEach ($Child in $Children){
    Set-Acl -Path "AD:\$($Child).DistinguishedName" -AclObject $ACL
}
