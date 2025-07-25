CLS

$OS = Get-Ciminstance Win32_OperatingSystem
$pctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,2)
#$Outlook_Process = (Get-Process -Name OUTLOOK | Select-Object Name,@{Name='WorkingSet';Expression={($_.WorkingSet/1MB)}})

$Percent_Free = ($pctFree)
$Free_Mem = ($OS.FreePhysicalMemory/1kB)
$Total_Mem = ($OS.TotalVisibleMemorySize/1KB)
$Used_Mem = (($OS.TotalVisibleMemorySize-$OS.FreePhysicalMemory)/1KB)
#$Outlook_MB = ($Outlook_Process.WorkingSet)

$Memory_Data = New-Object -TypeName PSObject
    $Memory_Data | Add-Member -MemberType NoteProperty -Name "Host" -Value ($env:computername)
    $Memory_Data | Add-Member -MemberType NoteProperty -Name ”Percent_Free” -Value ($Percent_Free)
    $Memory_Data | Add-Member -MemberType NoteProperty -Name ”Free_Mem” -Value ($Free_Mem)
    $Memory_Data | Add-Member -MemberType NoteProperty -Name ”Total_Mem” -Value ($Total_Mem)
    $Memory_Data | Add-Member -MemberType NoteProperty -Name ”Used_Mem” -Value ($Used_Mem)
    #$Memory_Data | Add-Member -MemberType NoteProperty -Name ”Outlook_MB” -Value ($Outlook_MB)

#$Memory_Data | ConvertTo-Json

$token = "token"
$server = "192.168.1.1"
$port = 8088
$url = "http://${server}:$port/services/collector/event"
$header = @{Authorization = "Splunk $token"}
#$event = @{event = $output} | ConvertTo-Json
$event = @{event = $Memory_Data;  host = $env:computername; sourcetype = "test"} | ConvertTo-Json
Invoke-RestMethod -Method Post -Uri $url -Headers $header -Body $event

##############################################################################################################################

CLS

$OS = Get-Ciminstance Win32_OperatingSystem
$pctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,2)
$Outlook_Process = (Get-Process -Name OUTLOOK | Select-Object Name,@{Name='WorkingSet';Expression={($_.WorkingSet/1MB)}})

$Percent_Free = ($pctFree)
$Free_Mem = [math]::Round(($OS.FreePhysicalMemory/1kB),2)
$Total_Mem = [math]::Round(($OS.TotalVisibleMemorySize/1KB),2)
$Used_Mem = [math]::Round(($OS.TotalVisibleMemorySize/1KB) - ($OS.FreePhysicalMemory/1KB),2)
$Outlook_MB = [math]::Round(($Outlook_Process.WorkingSet),2)

$hash=@{}
$hash.Add("Percent_Free",$Percent_Free)
$hash.Add("Free_Mem",$Free_Mem)
$hash.Add("Total_Mem",$Total_Mem)
$hash.Add("Used_Mem",$Used_Mem)
$hash.Add("Outlook_MB",$Outlook_MB)

$output = $null
$output = ""
$ARRAY = ( $hash.Keys | foreach-object { $output=$output+"$_=""$($hash[$_])"","})
$output.TrimEnd(",")

#curl -k "http://xxx.xxx.amazonaws.com:8088/services/collector" -H "Authorization: Splunk xxx"   -d '{"event": "Hello, world!", "sourcetype": "manual"}'

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$token = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$server = "server.example.com" # Replace with your server address
$port = 8088
$url = "https://${server}:$port/services/collector/event"
$header = @{Authorization = "Splunk $token"}
#$event = @{event = $output} | ConvertTo-Json
$event = @{event = "Hello world!"} | ConvertTo-Json
Invoke-RestMethod -Method Post -Uri $url -Headers $header -Body $event

##############################################################################################################################

cls

$OS = Get-Ciminstance Win32_OperatingSystem
$pctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,2)
$Outlook_Process = (Get-Process -Name OUTLOOK | Select-Object Name,@{Name='WorkingSet';Expression={($_.WorkingSet/1MB)}})

$Percent_Free = ($pctFree)
$Free_Mem = ($OS.FreePhysicalMemory/1kB)
$Total_Mem = ($OS.TotalVisibleMemorySize/1KB)
$Used_Mem = (($OS.TotalVisibleMemorySize-$OS.FreePhysicalMemory)/1KB)
$Outlook_MB = ($Outlook_Process.WorkingSet)

$Memory_Data = New-Object -TypeName PSObject
    $Memory_Data | Add-Member -MemberType NoteProperty -Name ”Percent_Free” -Value ($Percent_Free)
    $Memory_Data | Add-Member -MemberType NoteProperty -Name ”Free_Mem” -Value ($Free_Mem)
    $Memory_Data | Add-Member -MemberType NoteProperty -Name ”Total_Mem” -Value ($Total_Mem)
    $Memory_Data | Add-Member -MemberType NoteProperty -Name ”Used_Mem” -Value ($Used_Mem)
    $Memory_Data | Add-Member -MemberType NoteProperty -Name ”Outlook_MB” -Value ($Outlook_MB)

#$Memory_Data | ConvertTo-Json
$event = @{event = $Memory_Data;  host = $env:computername; sourcetype = "test"} | ConvertTo-Json
$event 


$token = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$server = "server.example.com"
$port = 8088
$url = "http://${server}:$port/services/collector/event"
$header = @{Authorization = "Splunk $token"}
#$event = @{event = $output} | ConvertTo-Json
Invoke-RestMethod -Method Post -Uri $url -Headers $header -Body $event

##############################################################################################################################


CLS

$OS = Get-Ciminstance Win32_OperatingSystem
$pctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,2)
$Outlook_Process = (Get-Process -Name OUTLOOK | Select-Object Name,@{Name='WorkingSet';Expression={($_.WorkingSet/1MB)}})

$Percent_Free = ($pctFree)
$Free_Mem = ($OS.FreePhysicalMemory/1kB)
$Total_Mem = ($OS.TotalVisibleMemorySize/1KB)
$Used_Mem = ($OS.TotalVisibleMemorySize/1KB)
$Outlook_MB = ($Outlook_Process.WorkingSet)

$test=@{}
$test.Add("Percent_Free",$Percent_Free)
$test.Add("Free_Mem",$Free_Mem)
$test.Add("Total_Mem",$Total_Mem)
$test.Add("Used_Mem",$Used_Mem)
$test.Add("Outlook_MB",$Outlook_MB)

$output = $null
$output = ""
$ARRAY = ($test.Keys | foreach-object { $output=$output+"$_=""$($test[$_])"","})
$output.TrimEnd(",")

##############################################################################################################################
