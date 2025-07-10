Clear-Host

$AD_User = 'xxx'
$AD_Object_Path = 'xxx'
$AD_Object_Match_Filter = 'xxx'

Function Add-AD_Security_Permissions_to_AD_Object {
    [CmdletBinding()]
    Param(
        # AD_User help description: This is the Ad_User trhat will be addes to the AD Objects group with full control permissions.
        [Parameter()]
        [String]$AD_User,
        # AD_Object_Path help description: This is the Parent OU of the AD_Object_Match_Filter. EXAMPLE
        # "AD:\CN($AD_Object_Path, OU=xxx, OU=xxx, OU=xxx, OU=xxx, DC=AD, DC=xxx"
        [Parameter()]
        [String]$AD_Object_Path,
        # AD_Object_Match_Filter help description: This is the Filtered child Objects that the AD_User will be added to. EXAMPLE
        # "AD:\CN($Computer), OU=xxx, OU=xxx, OU=xxx, OU=xxx, DC=AD, DC=xxx"
        [Parameter()]
        [String]$AD_Object_Match_Filter
    )
    Begin {
        $Group_Distinguished_Name = (Get-ADOrganizationalUnit -Filter "Name -Like '*$($AD_Object_Path)'").DistinguishedName
        Set-Location -Path "AD:\$Group_Distinguished_Name"
        $Computers = (Get-ChildItem | Where-Object {$_.Name -match $AD_Object_Match_Filter}).Name
    }
    Process {
        Foreach ($Computer in $Computers) {
            $Path = $null
            $Path = "AD:\CN$($Computer).$Group_Distinguished_Name"
            $ACL = Get-Acl -Path $Path
            $ACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
                (Get-ADUser -Identity $AD_User).sid,
                [System.DirectoryServices.ActiveDirectoryRights]::GenericAll, #Full Control
                [System.Security.AccessControl.AccessControlType]::Allow, #Allow or Deny
                [System.DirectoryServices.ActiveDirectorySecurityInheritance]::All
            )
            $ACL.AccessRule($ACE)
            Set-Acl -Path $Path -AclObject $ACL -Verbose
        }
    }
    End {}
}
