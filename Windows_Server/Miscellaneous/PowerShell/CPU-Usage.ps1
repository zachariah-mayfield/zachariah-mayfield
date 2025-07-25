CLS



$proc_pid = (get-process "BESClient").Id[0]


$cpu_cores = (Get-WMIObject Win32_ComputerSystem).NumberOfLogicalProcessors


$proc_path = ((Get-Counter "\Process(*)\ID Process" -ErrorAction SilentlyContinue).CounterSamples | ? {$_.RawValue -eq $proc_pid}).Path


$prod_percentage_cpu = [Math]::Round(((Get-Counter ($proc_path -replace "\\id process$","\% Processor Time")).CounterSamples.CookedValue) / $cpu_cores)

$prod_percentage_cpu

##################################################################################################################################################################
##################################################################################################################################################################
##################################################################################################################################################################
##################################################################################################################################################################

(Get-Counter '\Process(*)\% Processor Time' -ErrorAction SilentlyContinue).Countersamples | where {$_.InstanceName -ne "_total" -and $_.InstanceName -ne "idle"} |
Sort cookedvalue -Desc | Select -First 10 instancename, @{Name='CPU %';Expr={[Math]::Round($_.CookedValue)}}


(Get-Counter '\Process(*)\% Processor Time' -ErrorAction SilentlyContinue).Countersamples | where {$_.InstanceName -eq "idle"} | 
Select instancename, @{Name='CPU %';Expr={[Math]::Round($_.CookedValue)}}

(Get-Counter '\Process(*)\% Processor Time' -ErrorAction SilentlyContinue).Countersamples | where {$_.InstanceName -eq "_total"} | 
Select instancename, @{Name='CPU %';Expr={[Math]::Round($_.CookedValue)}}

##################################################################################################################################################################
##################################################################################################################################################################
##################################################################################################################################################################
##################################################################################################################################################################

CLS

Function Get-XXX_Services_CPU_Usage {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
        [Parameter(Mandatory=$true)]
        [String[]]$Services = ("XXX.devops.XXX-XXX-XXX-3","XXX.devops.XXX-XXX-XXX-2","XXX.devops.XXX-XXX-XXX-1","XXXJobAgent","XXX-service-x64","ReportingServicesService")
    )
    Begin {
    $FormatEnumerationLimit="0"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    }
    Process {
        $XXXProcess_MB=$null
        ForEach ($serviceName in $Services) {
            $XXXProcess=$null
            $varService=$null
            Try {
                $varService=Get-WmiObject Win32_Service -Filter "name = '$serviceName'" -ErrorAction Stop
                $PROCESSPID = $varService.ProcessID
                $varProcessMem = Get-WmiObject Win32_Process -Filter "ProcessId = '$PROCESSPIDs'"
            }
            Catch{}
            Try {
                $XXXProcess = (Get-Process -Id $PROCESSPID -ErrorAction Stop)
                 }
            Catch {}
            If ($XXXProcess -ne $null) {
                $XXXProcess_MB += ($XXXProcess)
            }
             IF ($varService -ne $null) {
                $Memory_Data = New-Object -TypeName PSObject
                    $CPU_Data | Add-Member -MemberType NoteProperty -Name ”Percent_Free” -Value ($Percent_Free)
                    $CPU_Data | Add-Member -MemberType NoteProperty -Name ”Free_Mem” -Value ($Free_Mem)
                    $CPU_Data | Add-Member -MemberType NoteProperty -Name ”Total_Mem” -Value ($Total_Mem)
                    $CPU_Data | Add-Member -MemberType NoteProperty -Name ”Used_Mem” -Value ($Used_Mem)
                    $CPU_Data | Add-Member -MemberType NoteProperty -Name ”Processes_MB” -Value ($XXXProcess_MB)
            }
        }

        $event = @{event = $CPU_Data; index = 'perf-ps';  host = $env:computername; sourcetype = "test"} | ConvertTo-Json
        $event 
    }
    END{
        
        $token = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        $server = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        $port = 1111
        $url = "http://${server}:$port/services/collector/event"
        $header = @{Authorization = "Splunk $token"}

        Invoke-RestMethod -Method Post -Uri $url -Headers $header -Body $event
        
    }
}#END Function

If ($env:COMPUTERNAME -eq "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx") {Get-XXX_Services_Mem_Usage -Services "XXX.devops.XXX-XXX-XXX-3","XXX.devops.XXX-XXX-XXX-2","XXX.devops.XXX-XXX-XXX-1"}
If ($env:COMPUTERNAME -eq "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx") {Get-XXX_Services_Mem_Usage -Services "XXXJobAgent"}
If ($env:COMPUTERNAME -eq "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx") {Get-XXX_Services_Mem_Usage -Services "XXX-service-x64"}
If ($env:COMPUTERNAME -eq "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx") {Get-XXX_Services_Mem_Usage -Services "ReportingServicesService"}

##################################################################################################################################################################
##################################################################################################################################################################
##################################################################################################################################################################
##################################################################################################################################################################
