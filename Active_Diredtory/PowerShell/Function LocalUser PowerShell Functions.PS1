# This is the Start of The Functions For Local Users ***********************************************************
Function New-LocalUser 
{ 
  <# 
   .Synopsis 
    This function creates a local user  
   .Description 
    This function creates a local user 
   .Example 
    New-LocalUser -userName "xxxx" -description  ` 
        -password "password" 
    Creates a new local user named xxxx with a description of 
    and a password of password.  
   .Parameter ComputerName 
    The name of the computer upon which to create the user 
   .Parameter UserName 
    The name of the user to create 
   .Parameter password 
    The password for the newly created user 
   .Parameter description 
    The description for the newly created user 
   .Notes 
    NAME:  New-LocalUser 
   .Link 
 #Requires -Version 2.0 
 #> 
 [CmdletBinding()] 
 Param( 
  [Parameter(Position=0, 
      Mandatory=$True, 
      ValueFromPipeline=$True)] 
  [string]$userName, 
  [Parameter(Position=1, 
      Mandatory=$True, 
      ValueFromPipeline=$True)] 
  [string]$password, 
  [string]$computerName = $env:ComputerName, 
  [string]$description = "Created by PowerShell" 
 ) 
 $computer = [ADSI]"WinNT://$computerName" 
 $user = $computer.Create("User", $userName) 
 $user.setpassword($password) 
 $user.put("description",$description)  
 $user.SetInfo() 
} #end function New-LocalUser 
 
Function New-LocalGroup 
{ 
 <# 
   .Synopsis 
    This function creates a local group  
   .Description 
    This function creates a local group 
   .Example 
    New-LocalGroup -GroupName "mygroup" -description  
    Creates a new local group named mygroup with a description of.  
   .Parameter ComputerName 
    The name of the computer upon which to create the group 
   .Parameter GroupName 
    The name of the Group to create 
   .Parameter description 
    The description for the newly created group 
   .Notes 
    NAME:  New-LocalGroup 
   .Link  
 #Requires -Version 2.0 
 #> 
 [CmdletBinding()] 
 Param( 
  [Parameter(Position=0, 
      Mandatory=$True, 
      ValueFromPipeline=$True)] 
  [string]$GroupName, 
  [string]$computerName = $env:ComputerName, 
  [string]$description = "Created by PowerShell" 
 ) 
  
  $adsi = [ADSI]"WinNT://$computerName" 
  $objgroup = $adsi.Create("Group", $groupName) 
  $objgroup.SetInfo() 
  $objgroup.description = $description 
  $objgroup.SetInfo() 
  
} #end function New-LocalGroup 
 
Function Set-LocalGroup 
{ 
  <# 
   .Synopsis 
    This function adds or removes a local user to a local group  
   .Description 
    This function adds or removes a local user to a local group 
   .Example 
    Set-LocalGroup -username "xxxx" -groupname "administrators" -add 
    Assigns the local user xxxx to the local administrators group 
   .Example 
    Set-LocalGroup -username "xxxx" -groupname "administrators" -remove 
    Removes the local user xxxx to the local administrators group 
   .Parameter username 
    The name of the local user 
   .Parameter groupname 
    The name of the local group 
   .Parameter ComputerName 
    The name of the computer 
   .Parameter add 
    causes function to add the user 
   .Parameter remove 
    causes the function to remove the user 
   .Notes 
    NAME:  Set-LocalGroup 
   .Link 
 #Requires -Version 2.0 
 #> 
 [CmdletBinding()] 
 Param( 
  [Parameter(Position=0, 
      Mandatory=$True, 
      ValueFromPipeline=$True)] 
  [string]$userName, 
  [Parameter(Position=1, 
      Mandatory=$True, 
      ValueFromPipeline=$True)] 
  [string]$GroupName, 
  [string]$computerName = $env:ComputerName, 
  [Parameter(ParameterSetName='addUser')] 
  [switch]$add, 
  [Parameter(ParameterSetName='removeuser')] 
  [switch]$remove 
 ) 
 $group = [ADSI]"WinNT://$ComputerName/$GroupName,group" 
 if($add) 
  { 
   $group.add("WinNT://$ComputerName/$UserName") 
  } 
  if($remove) 
   { 
   $group.remove("WinNT://$ComputerName/$UserName") 
   } 
} #end function Set-LocalGroup 
 
Function Set-LocalUserPassword 
{ 
 <# 
   .Synopsis 
    This function changes a local user password  
   .Description 
    This function changes a local user password 
   .Example 
    Set-LocalUserPassword -userName "xxxx" -password "newpassword" 
    Changes a local user named xxxx password to newpassword. 
   .Parameter ComputerName 
    The name of the computer upon which to change the user's password 
   .Parameter UserName 
    The name of the user for which to change the password 
   .Parameter password 
    The new password for the user 
   .Notes 
    NAME:  Set-LocalUserPassword 
   .Link 
 #Requires -Version 2.0 
 #> 
 [CmdletBinding()] 
 Param( 
  [Parameter(Position=0, 
      Mandatory=$True, 
      ValueFromPipeline=$True)] 
  [string]$userName, 
  [Parameter(Position=1, 
      Mandatory=$True, 
      ValueFromPipeline=$True)] 
  [string]$password, 
  [string]$computerName = $env:ComputerName 
 ) 
 $user = [ADSI]"WinNT://$computerName/$username,user" 
 $user.setpassword($password)  
 $user.SetInfo() 
} #end function Set-LocalUserPassword 
 
function Set-LocalUser 
{ 
  <# 
   .Synopsis 
    Enables or disables a local user  
   .Description 
    This function enables or disables a local user 
   .Example 
    Set-LocalUser -userName xxxx -disable 
    Disables a local user account named xxxx 
   .Example 
    Set-LocalUser -userName xxxx -password Password 
    Enables a local user account named xxxx and gives it the password password  
   .Parameter UserName 
    The name of the user to either enable or disable 
   .Parameter Password 
    The password of the user once it is enabled 
   .Parameter Description 
    A description to associate with the user account 
   .Parameter Enable 
    Enables the user account 
   .Parameter Disable 
    Disables the user account 
   .Parameter ComputerName 
    The name of the computer on which to perform the action 
   .Notes 
    NAME:  Set-LocalUser 
   .Link 
 #Requires -Version 2.0 
 #> 
 [CmdletBinding()] 
 Param( 
  [Parameter(Position=0, 
      Mandatory=$True, 
      ValueFromPipeline=$True)] 
  [string]$userName, 
  [Parameter(Position=1, 
      Mandatory=$True, 
      ValueFromPipeline=$True, 
      ParameterSetName='EnableUser')] 
  [string]$password, 
  [Parameter(ParameterSetName='EnableUser')] 
  [switch]$enable, 
  [Parameter(ParameterSetName='DisableUser')] 
  [switch]$disable, 
  [string]$computerName = $env:ComputerName, 
  [string]$description = "modified via powershell" 
 ) 
 $EnableUser = xxx # ADS_USER_FLAG_ENUM enumeration value from SDK 
 $DisableUser = xxxx  # ADS_USER_FLAG_ENUM enumeration value from SDK 
 $User = [ADSI]"WinNT://$computerName/$userName,User" 
  
 if($enable) 
  { 
      $User.setpassword($password) 
      $User.description = $description 
      $User.userflags = $EnableUser 
      $User.setinfo() 
  } #end if enable 
 if($disable) 
  { 
      $User.description = $description 
      $User.userflags = $DisableUser 
      $User.setinfo() 
  } #end if disable 
} #end function Set-LocalUser 
 
Function Remove-LocalUser 
{ 
 <# 
   .Synopsis 
    This function deletes a local user  
   .Description 
    This function deletes a local user 
   .Example 
    Remove-LocalUser -userName "xxxx"  
    Removes a new local user named xxxx.  
   .Parameter ComputerName 
    The name of the computer upon which to delete the user 
   .Parameter UserName 
    The name of the user to delete 
   .Notes 
    NAME:  Remove-LocalUser 
   .Link 
 #Requires -Version 2.0 
 #> 
 [CmdletBinding()] 
 Param( 
  [Parameter(Position=0, 
      Mandatory=$True, 
      ValueFromPipeline=$True)] 
  [string]$userName, 
  [string]$computerName = $env:ComputerName 
 ) 
 $User = [ADSI]"WinNT://$computerName" 
 $user.Delete("User",$userName) 
} #end function Remove-LocalUser 
 
Function Remove-LocalGroup 
{ 
 <# 
   .Synopsis 
    This function deletes a local group  
   .Description 
    This function deletes a local group 
   .Example 
    Remove-LocalGroup -GroupName "mygroup"  
    Creates a new local group named mygroup.  
   .Parameter ComputerName 
    The name of the computer upon which to delete the group 
   .Parameter GroupName 
    The name of the Group to delete 
   .Notes 
    NAME:  Remove-LocalGroup 
   .Link 
 #Requires -Version 2.0 
 #> 
 [CmdletBinding()] 
 Param( 
  [Parameter(Position=0, 
      Mandatory=$True, 
      ValueFromPipeline=$True)] 
  [string]$GroupName, 
  [string]$computerName = $env:ComputerName 
 ) 
 $Group = [ADSI]"WinNT://$computerName" 
 $Group.Delete("Group",$GroupName) 
} #end function Remove-LocalGroup 
