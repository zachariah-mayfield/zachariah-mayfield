CLS



Function Get-Services_Memory_Usage {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
        [Parameter(Mandatory=$true)]
        [String[]]$Services = ("vstsagent.devops.X-3","vstsagent.devops.X-2","vstsagent.devops.X-1","xJobAgent","elasticsearch-service-x64","ReportingServicesService")
    )
    Begin {
    $FormatEnumerationLimit="0"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    }
    Process {
        $TFSProcess_MB=$null
        ForEach ($serviceName in $Services) {
            $TFSProcess=$null
            $varService=$null
            Try {
                $varService=Get-WmiObject Win32_Service -Filter "name = '$serviceName'" -ErrorAction Stop
                $PROCESSPIDs = $varService.ProcessID
                $varProcessMem = Get-WmiObject Win32_Process -Filter "ProcessId = '$PROCESSPIDs'"
            }
            Catch{}
            Try {
                $TFSProcess = (Get-Process -Id $PROCESSPIDs -ErrorAction Stop | Select-Object Name,@{Name='WorkingSet';Expression={($_.WorkingSet/1MB)}}) 
            }
            Catch {}
            If ($TFSProcess -ne $null) {
                $TFSProcess_MB += ($TFSProcess.WorkingSet)
            }
        $OS = Get-Ciminstance Win32_OperatingSystem
        $pctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,2)
        $Percent_Free = ($pctFree)
        $Free_Mem = ($OS.FreePhysicalMemory/1kB)
        $Total_Mem = ($OS.TotalVisibleMemorySize/1KB)
        $Used_Mem = (($OS.TotalVisibleMemorySize-$OS.FreePhysicalMemory)/1KB)
        IF ($varService -ne $null) {
                $Memory_Data = New-Object -TypeName PSObject
                    $Memory_Data | Add-Member -MemberType NoteProperty -Name ”Percent_Free” -Value ($Percent_Free)
                    $Memory_Data | Add-Member -MemberType NoteProperty -Name ”Free_Mem” -Value ($Free_Mem)
                    $Memory_Data | Add-Member -MemberType NoteProperty -Name ”Total_Mem” -Value ($Total_Mem)
                    $Memory_Data | Add-Member -MemberType NoteProperty -Name ”Used_Mem” -Value ($Used_Mem)
                    $Memory_Data | Add-Member -MemberType NoteProperty -Name ”Processes_MB” -Value ($TFSProcess_MB)
            }
        }
        $event = @{event = $Memory_Data; index = 'perf-ps';  host = $env:computername; sourcetype = "test"} | ConvertTo-Json
        $event 
    }
    END{
        
        $token = "token"
        $server = "ServerName"
        $port = 8088
        $url = "http://${server}:$port/services/collector/event"
        $header = @{Authorization = "Splunk $token"}

        Invoke-RestMethod -Method Post -Uri $url -Headers $header -Body $event
        
    }
}#END Function

If ($env:COMPUTERNAME -eq "X1") {Get-Services_Memory_Usage -Services "vstsagent.devops.X-3","vstsagent.devops.X-2","vstsagent.devops.X-1"}
If ($env:COMPUTERNAME -eq "X") {Get-Services_Memory_Usage -Services "xJobAgent"}
If ($env:COMPUTERNAME -eq "XX1") {Get-Services_Memory_Usage -Services "elasticsearch-service-x64"}
If ($env:COMPUTERNAME -eq "X01") {Get-Services_Memory_Usage -Services "ReportingServicesService"}
