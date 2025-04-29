cls

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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

$event = @{event = $Memory_Data; index = 'perf-ps';  host = $env:computername; sourcetype = "test"} | ConvertTo-Json
$event 

$token = "Spunk Token"
$server = "Splunk Server"
$port = "Splunk Port Number"
$url = "http://${server}:$port/services/collector/event"
$header = @{Authorization = "Splunk $token"}

Invoke-RestMethod -Method Post -Uri $url -Headers $header -Body $event
