Clear-Host

$TeamCity_Win_Cred_UserName = (Get-StoredCredential -Target 'TeamCity_API_Token' -Type Generic -AsCredentialObject).UserName
$TeamCity_Token = "xxxxxxxxxxxxxxxxxx"
$Token = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $($TeamCity_Win_Cred_UserName), $($TeamCity_Token))))
$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Header = @{authorization = "Basic $Token"}
$Header.Add('Accept','application/json')
$TeamCity_Instance = 'xxxxx.com'

$buildLocator = 'xxxxxxxxxxx'
$Step_Name = 'Log Build to xxxx'

$TeamCity_Builds_URL = "http://$($TeamCity_Instance)/app/rest/buildTypes/$($buildLocator)/steps/"

$Responses_2 = (Invoke-RestMethod -Uri $TeamCity_Builds_URL -Method GET -Headers $Header)

$OG_Build_Step = ($Responses_2.step | Where-Object -Property name -EQ $Step_Name)
###$OG_Build_Step.properties.property | Format-Table -Wrap

$ScriptParameters = (($OG_Build_Step.properties.property | Where-Object -Property name -EQ 'xxxxxxxxxx').value)

$Lines = $ScriptParameters -split '\n'

Foreach ($line in $lines){
    #$line = $line.Replace('-','`-')
    $newS += "$($line) "
}

$New_Build_Step = @{
    'name'='Log Build to xxx';
    'type'='PsGalleryRunner';
}

$property = New-Object System.Collections.ArrayList
$property.Add(@{
'name'='PsGalleryName';
'value'='Powershell-Enterprise';})
$property.Add(@{
'name'='PsGalleryUrl';
'value'='https://xxxx/';})
$property.Add(@{
'name'='ScriptName';
'value'='xxBuildVersionDbLogger';})
$property.Add(@{
'name'='ScriptParameters';
'value' = $newS;})

$Count = $property.Count

$properties = @{
'Count' = $Count;
'property' = $property;
}

$New_Build_Step.Add('properties',$properties)

$New_Build_Step | ConvertTo-Json -Depth 10 | Out-File ".\New_Build_Step.json"

$POST_Data = $($New_Build_Step| ConvertTo-Json -Compress -Depth 100)
$POST_Data 
$Build_Step_Replacement = Invoke-RestMethod -Uri $TeamCity_Builds_URL -Method Post -Body $POST_Data -Headers $Header -ContentType 'application/json'

$Build_Step_Replacement
