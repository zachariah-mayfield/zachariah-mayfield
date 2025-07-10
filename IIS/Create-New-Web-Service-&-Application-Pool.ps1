CLS

$New_WebApplication = "xxx"
$WebApplication_Parent = "xxx"
$New_WebApplicationPool = "xxx"
$New_WebApplicationPool_PSPath = "D:\WebServices\xxx"
$New_WebApplicationPool_PSParentPath = "D:\WebServices\xxx\"
$UserName = "xxx"
$PassWord = "xxx"


# Create a New Web Application Pool
New-WebAppPool -Name $New_WebApplicationPool

# Create new folder under the correct Site 
IF ((Test-Path -Path $New_WebApplicationPool_PSPath) -eq $false) {
    New-Item -Path $New_WebApplicationPool_PSParentPath -Name $New_WebApplication -ItemType "Directory"
}
#>

# Create a New-WebVirtualDirectory 
New-WebVirtualDirectory -Name "xxx" -Site "xxx" -Application "xxx" -PhysicalPath "D:\WebServices\xxx" -Force

# This will set the PsPath for when the new webapplication to use when you convert it to a Web Application
$WebApplication_PsPath = (Get-Item "IIS:\Sites\$WebApplication_Parent\$New_WebApplication").pspath

# Convert the folder to an Application
ConvertTo-WebApplication -ApplicationPool $New_WebApplicationPool -PSPath $WebApplication_PsPath

# This will set up the Specific service account User and add the Password.
Set-ItemProperty IIS:\AppPools\$New_WebApplicationPool -name processModel.identityType -Value SpecificUser 

Set-ItemProperty IIS:\AppPools\$New_WebApplicationPool -name processModel.userName -Value $UserName

Set-ItemProperty IIS:\AppPools\$New_WebApplicationPool -name processModel.password -Value $PassWord
