CLS
Function Get-NetworkSpeed {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param ()
Begin{}#END BEGIN

Process{
try{
    # Creates the file path if it does not exist.
    $NewPath = "C:\SpeedTest"
    IF (-not(Test-Path -path $NewPath)) {
        New-Item $NewPath -type directory -ErrorAction SilentlyContinue | Out-Null
    }


    $downloadPaths = ("1_5mb", "2_5mb") #, "5mb", "10mb", "20mb", "25mb", "40mb", "50mb", "75mb", "100mb"
    [System.Collections.ArrayList]$downloadTimes = @()
    [System.Collections.ArrayList]$downloadSize = @()
    $index = 0


    For ($startTime = Get-Date; ((Get-Date)-$startTime).TotalSeconds -le 15 -and $index -lt 2; $index++) {
        $downStart = Get-Date
        Invoke-WebRequest https://$($downloadPaths[$index]) -OutFile "C:\$($downloadPaths[$index])"
        $downloadTimes.Add(((Get-Date)-$downStart).TotalSeconds) | Out-null
        $downloadSize.Add((Get-Item -Path C:\$($downloadPaths[$index])).Length/1024/1024) | Out-null
    }


    $downloadTime = ((Get-Date)-$startTime).TotalSeconds

    $logTime = (Get-Date).ToString()
    
    $logLine = ("$logTime [INFO] - Download process took  $downloadTime  seconds")
    
    Write-Host -NoNewline $logLine 

    $sum = 0

    For ($i=0; $i -lt $downloadTimes.Count; $i++) {
        $sum = $sum + ($downloadSize[$i] / $downloadTimes[$i] * 8)
    }
    $_avgDownload = $sum / $downloadTimes.Count
}


Catch{
    $logTime = (Get-Date).ToString()
    $logLine =  "$logTime [ERROR] - Download process failed"
    Write-Host $logLine 
    Write-Host "FAILED"
    # Add a WMI object to say it failed
} #end the script if any of the downloads failed


try{
    $uploadPaths = Get-ChildItem C:\*mb | Sort-Object -Property Length 
    [System.Collections.ArrayList]$uploadSize = @()
    [System.Collections.ArrayList]$uploadTimes = @()
    $index = 0


    For ($startTime = Get-Date; ((Get-Date)-$startTime).TotalSeconds -le 15 -and $index -lt $uploadPaths.Count; $index++) {
        $UPStart = Get-Date
        $url = "http://$env:COMPUTERNAME/$($uploadPaths[$index].Name).txt"
        Invoke-RestMethod -Uri $url -Method Put -InFile $uploadPaths[$index].FullName
        $uploadTimes.Add(((Get-Date)-$UPStart).TotalSeconds) | Out-null
        $uploadSize.Add($uploadPaths[$index].Length/1024/1024) | Out-null
    }


    $uploadTime = ((Get-Date)-$startTime).TotalSeconds
    
    $logTime = (Get-Date).ToString()
    
    $logLine =  ("$logTime [INFO] - Upload process took $uploadTime seconds")
    
    Write-Host $logLine 
    
    $sum = 0


    For ($i=0; $i -lt $uploadTimes.Count; $i++) {
        $sum = $sum + ($uploadSize[$i] / $uploadTimes[$i] * 8)
    }
    $_avgUpload = $sum / $uploadTimes.Count
}


Catch{
    $logTime = (Get-Date).ToString()
    $logLine =  "$logTime [ERROR] - Upload process failed"
    Write-Host $logLine 
    Write-Host "FAILED"
    # Add a WMI object to say it failed
} #end the script if any of the uploads failed


$logTime = (Get-Date).ToString()
$logLine =  "$logTime [INFO] - Download=${_avgDownload} mbps"
$logLine 

$logTime = (Get-Date).ToString()
$logLine =  "$logTime [INFO] - Upload=${_avgUpload} mbps"
$logLine 

Write-Host "Download=${_avgDownload}"
Write-Host "Upload=${_avgUpload}"

}#END Process
END {}#END END
}#END Function Get-NetworkSpeed
