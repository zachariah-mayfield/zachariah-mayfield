CLS

$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SOFTWARE\",[Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::ChangePermissions)
$acl = $key.GetAccessControl()
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ("xxx\Administrators","FullControl","Allow")
$acl.SetAccessRule($rule)
$key.SetAccessControl($acl)

$rule1 = New-Object System.Security.AccessControl.RegistryAccessRule ("xxx\Administrators","FullControl","Allow")
$rule2 = New-Object System.Security.AccessControl.RegistryAccessRule ("xxx\Administrators","FullControl","ObjectInherit,ContainerInherit","None","Allow")
