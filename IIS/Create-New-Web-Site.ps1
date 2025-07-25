CLS

$NewWebSite = "xxTest-Site-01"
$WebParentPath = "D:\WebApps\"
$WebPath = "D:\WebApps\$NewWebSite"

IF ((Test-Path -Path $WebPath) -eq $false) {
    New-Item -Path $WebParentPath -Name $NewWebSite -ItemType "Directory"
}

IF ((Test-Path -Path $WebPath) -eq $true) {
    Write-Host -ForegroundColor Cyan "Path $WebPath exists"
}

IF ((Get-Website -Name $NewWebSite) -eq $null) {
    Write-Host -ForegroundColor Yellow "$NewWebSite does not exist yet."
    New-Website -Name $NewWebSite -ApplicationPool $NewWebSite -PhysicalPath $WebPath -Port 80 -HostHeader $NewWebSite  -SslFlags 1 -Force
}

IF ((Get-Website -Name $NewWebSite) -ne $null -and ((Get-WebBinding -Name $NewWebSite) -eq $null)) {
    Write-Host -ForegroundColor Yellow "WebSite $NewWebSite exists."
    New-WebBinding -Name $NewWebSite -Protocol HTTPS -Port 443 -HostHeader $NewWebSite -SslFlags 1
}

IF ((Get-WebBinding -Name $NewWebSite) -ne $null) {
    Write-Host -ForegroundColor Yellow "WebBindingSite $NewWebSite exists." 
}

#################################################################################################################################################

IF ((Get-WebAppPoolState -Name $NewWebSite -ErrorAction SilentlyContinue) -eq $null) {
    New-WebAppPool -Name $NewWebSite
}

$app_pool_name = "xx-Test-Site-01"

$credentials = (Get-Credential -Message "Please enter the Login credentials including Domain Name").GetNetworkCredential()

$userName = $credentials.Domain + '\' + $credentials.UserName

Set-ItemProperty IIS:\AppPools\$app_pool_name -name processModel.identityType -Value SpecificUser 

Set-ItemProperty IIS:\AppPools\$app_pool_name -name processModel.userName -Value $username

Set-ItemProperty IIS:\AppPools\$app_pool_name -name processModel.password -Value $credentials.Password
