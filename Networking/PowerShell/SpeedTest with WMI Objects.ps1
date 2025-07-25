
$_stFailureIndicator = 0

$_avgDownload = 0

Clear-Content C:\Performance.log

try{

    # Creates the file path if it does not exist.
    $NewPath = "C:\xxxx"
    IF (-not(Test-Path -path $NewPath)) {
        New-Item $NewPath -type directory -ErrorAction SilentlyContinue | Out-Null
    } 

    $downloadPaths = "1_5mb", "2_5mb", "5mb", "10mb", "20mb", "25mb", "40mb", "50mb", "75mb", "100mb"
    [System.Collections.ArrayList]$downloadTimes = @()
    [System.Collections.ArrayList]$downloadSize = @()

    $index = 0
    $startTime
    For ($startTime = Get-Date; ((Get-Date)-$startTime).TotalSeconds -le 15 -and $index -lt 10; $index++) {
        $downStart = Get-Date
        Invoke-WebRequest https://xxx/$($downloadPaths[$index]) -OutFile "C:\xxxx\$($downloadPaths[$index])"
        $downloadTimes.Add(((Get-Date)-$downStart).TotalSeconds)
        $downloadSize.Add((Get-Item -Path C:\xxxx\$($downloadPaths[$index])).Length/1024/1024)
        

    }
    $downloadTime = ((Get-Date)-$startTime).TotalSeconds
    $logTime = (Get-Date).ToString()
    $logLine =  "$logTime [INFO] - Download process took $downloadTime seconds"
    $logLine | Out-File C:\xxxx\Performance.log -Append

    $sum = 0
    For ($i=0; $i -lt $downloadTimes.Count; $i++) {
        $sum = $sum + ($downloadSize[$i] / $downloadTimes[$i] * 8)
    }
    $_avgDownload = $sum / $downloadTimes.Count

}
Catch{
    $logTime = (Get-Date).ToString()
    $logLine =  "$logTime [ERROR] - Download process failed"
    $logLine | Out-File C:\Performance.log -Append
    Write-Host "FAILED"
    $_stFailureIndicator = 1
    # Add a WMI object to say it failed
} #end the script if any of the downloads failed



$_avgUpload = 0
try{
    $uploadPaths = Get-ChildItem C:\*mb | Sort-Object -Property Length 
    [System.Collections.ArrayList]$uploadSize = @()
    [System.Collections.ArrayList]$uploadTimes = @()

    $index = 0
    For ($startTime = Get-Date; ((Get-Date)-$startTime).TotalSeconds -le 15 -and $index -lt $uploadPaths.Count; $index++) {
        $downStart = Get-Date
        $url = "http://xxxxx/$env:COMPUTERNAME/$($uploadPaths[$index].Name).txt"
        Invoke-RestMethod -Uri $url -Method Put -InFile $uploadPaths[$index].FullName
        $uploadSize.Add($uploadPaths[$index].Length/1024/1024)
        $uploadTimes.Add(((Get-Date)-$downStart).TotalSeconds)
    }
    $uploadTime = ((Get-Date)-$startTime).TotalSeconds
    $logTime = (Get-Date).ToString()
    $logLine =  "$logTime [INFO] - Upload process took $uploadTime seconds"
    $logLine | Out-File C:\Performance.log -Append

    $sum = 0
    For ($i=0; $i -lt $uploadTimes.Count; $i++) {
        $sum = $sum + ($uploadSize[$i] / $uploadTimes[$i] * 8)
    }
    $_avgUpload = $sum / $uploadTimes.Count
}
Catch{
    $logTime = (Get-Date).ToString()
    $logLine =  "$logTime [ERROR] - Upload process failed"
    $logLine | Out-File C:\Performance.log -Append
    Write-Host "FAILED"
    $_stFailureIndicator = 1
    # Add a WMI object to say it failed
} #end the script if any of the uploads failed



$logTime = (Get-Date).ToString()
$logLine =  "$logTime [INFO] - Upload=${_avgUpload} mbps"
$logLine | Out-File C:\Performance.log -Append

$logTime = (Get-Date).ToString()
$logLine =  "$logTime [INFO] - Download=${_avgDownload} mbps"
$logLine | Out-File C:\Performance.log -Append

Write-Host "Download=${_avgDownload}";
Write-Host "Upload=${_avgUpload}";


$Namespace = "xxxxxMonitoring"
$Class = "Networkxxxxx"

# Check if the namespace exists - if it doesn't, create it.
If (Get-WmiObject -Namespace "root\cimv2" -Class "__NAMESPACE" | Where-Object {$_.Name -eq $Namespace})
{
    WRITE-HOST "The root\cimv2\$Namespace WMI namespace exists!"
}
Else
{
    WRITE-HOST "The root\cimv2\$Namespace WMI namespace does not exist."
    $wmi= [wmiclass]"root\cimv2:__Namespace" 
    $newNamespace = $wmi.createInstance() 
    $newNamespace.name = $Namespace 
    $newNamespace.put() 
}
# 



# WMI Class
If (Get-WmiObject -List -Namespace "root\cimv2\$Namespace" | Where-Object {$_.Name -eq $Class})
{
    WRITE-HOST "The " $Class " WMI class exists."
    # The class exists, Let's clean it up.
    $GetExistingInstances = Get-WmiObject -Namespace "root\cimv2\$Namespace" -Class $Class
    If ($GetExistingInstances -eq $Null) 
    {
        WRITE-HOST "There are no instances (left) in the WMI class."         
    }
    Else
    {
       # 
       #
       WRITE-HOST "There are instances found in this WMI class - cleaning them up."
       Remove-WMIObject -Namespace "root\cimv2\$Namespace" -Class $Class  
    }
}


# 
WRITE-HOST "Now creating the " $Class " WMI class with our variables."
$_subClass = New-Object System.Management.ManagementClass ("root\cimv2\$Namespace", [String]::Empty, $null); 
$_subClass["__CLASS"] = $Class; 
$_subClass.Qualifiers.Add("Static", $true)
$_subClass.Properties.Add("Name", [System.Management.CimType]::String, $false)
$_subClass.Properties["Name"].Qualifiers.Add("Key", $true) #A key qualifier must be defined to execute 'Put' command.
$_subClass.Properties.Add("Upload", [System.Management.CimType]::Real64, $false)
$_subClass.Properties.Add("Download", [System.Management.CimType]::Real64, $false)
$_subClass.Properties.Add("SpeedTestFail", [System.Management.CimType]::Real64, $false)
$_subClass.Put()

# 

$keyvalue = "Bandwidth"
$Filter = 'Name= "' + $keyvalue + '"'
$Inst = Get-WmiObject -Class $Class -Filter $Filter -Namespace root\cimv2\$Namespace
$Inst | Remove-WMIObject

# 
Write-Host $_stFailureIndicator
$WMIURL = 'root\cimv2\'+$Namespace+':'+$Class
$PushDataToWMI = ([wmiclass]$WMIURL).CreateInstance()
$PushDataToWMI.Name = $keyvalue
$PushDataToWMI.Upload = $_avgUpload
$PushDataToWMI.Download = $_avgDownload
$PushDataToWMI.SpeedTestFail = $_stFailureIndicator
$PushDataToWMI.Put()

