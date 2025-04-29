#Parameters ask for specific information -  API, Server Name, IP address, and Computer name in order to successfully force the upgrade on a particular client machine.
Param(
    [parameter(Mandatory=$true)][string]$apiToken,
	[parameter(Mandatory=$false)][string]$serverName = "serverName",
	[parameter(Mandatory=$true)][string]$ip,
    [parameter(Mandatory=$true)][string]$computerName
    )

#Variables include the API authentication token, the URI, and the script to query a particular list of computers. 
Function StaticVariables
{
    Set-Variable -Name $header -Value "X-Auth-Token" -Scope Script
    Set-Variable -Name $uri -Value "https://$serverName/api/bit9platform/v1" -Scope Script
    Set-Variable -Name $query -Value "/computer?q=deleted:false&q=" -Scope Script
}

#Function to Upgrade Clients based on above information
Function B9UpgradeAgent
{
    if (($ip -eq $null) -and ($computerName -eq $null)){Write-Host "No IP or Computer Name specified. Exiting..."}
    elseif (($ip -ne $null) -and ($computerName -ne $null)){Write-Host "Both IP or Computer Name specified. Exiting..."}
    if ($ip -ne $null){$host = $uri + $query + "ipAddress:" + $ip}
    if ($computerName -ne $null){$host = $uri + $query + "name:" + $computerName}
    $computers = Invoke-RestMethod -Headers @{$header=$apiToken} -Method Get -Uri "$host"
	foreach ( $computer in $computers ) 
    {
        $computer.forceUpgrade = "True"
		$json = $computer | ConvertTo-Json
        $update = Invoke-RestMethod -Headers @{$h=$apiToken} -Method Post -ContentType "application/json" -Uri "$uri" -Body $json
    }
}
StaticVariables
B9UpgradeAgent
