
Function Get-MiniDump {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
    #[ValidateNotNullOrEmpty()]
    [String[]]$ComputerName = $Env:COMPUTERNAME,

    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)] 
    [Switch]$Analyze 
    )
    Process{

ForEach ($Computer in $ComputerName){

######################################################################################################################################################

$MiniDumpPath = "\\$Computer\C$\Windows\Minidump" 

If (Test-Path -Path $MiniDumpPath) {
# Uncomment the part of line below to filter for in the last 30 days. 
    $DMPFileName = (Get-ChildItem -Path $MiniDumpPath -Recurse -Force <#| Where-Object {$_.CreationTime -gt (Get-Date).AddDays(-30)}#>)
    $DName = Foreach ($DMP in $DMPFileName){ $DMP}
    $DCreatedTime = $DMPFileName | Get-Date -UFormat %a-%B-%d-%Y__%r -ErrorAction SilentlyContinue

IF ($DName -ne $null -and $DCreatedTime -ne $null) {

    $Hash = @{
        ServerName = $Computer
        DMPName = $DName
        Created = $DCreatedTime
        }
    
    $Object = New-Object PSObject -Property $Hash  
    $Object

}# END IF ($DName -ne $null -and $DCreatedTime -ne $null)

Else {
    
    $Hash = @{
        ServerName = $Computer
        DMPName = Write-Output "NO Data"
        Created = Write-Output "NO Data"
        }

    $Object = New-Object PSObject -Property $Hash  
    $Object

}# END Else

######################################################################################################################################################

# This sets the variable for the $Source.
$Source = Get-ChildItem "C:\Windows\Minidump*" -Recurse -Force -ErrorAction SilentlyContinue

IF ($Source -ne $null){

# This sets the variable for the $Destination.
$Destination = "C:\All MiniDumps\$Computer\MiniDumps"

# This makes the directory "C:\All MiniDumps\$Computer", and if it already exists it suppress the error.
IF (-not(Test-Path -path $Destination)) {
  New-Item $Destination -type directory -Force -ErrorAction SilentlyContinue | Out-Null
}

# This gets all of the Dump Files from the $source Copies them to the $Destination
Get-ChildItem $Source | ForEach-Object {Copy-Item -Path $Source -Destination $Destination -Force -Recurse -ErrorAction SilentlyContinue} | Out-Null

# This sets the variable for the $TimeStamp
$timeStamp = $(Get-Date -f hh.mm.ss_MM.dd.yy)

# This sets the variable for the $DumpMove
$DumpMove = "C:\All MiniDumps\$Computer\MiniDumpsProcessed\$timeStamp"

# This makes the directory "C:\All MiniDumps\$Computer\MiniDumpsProcessed\$timeStamp", and if it already exists it suppress the error.
IF (-not(Test-Path -path $DumpMove)) {
  New-Item $DumpMove -type directory -Force -ErrorAction SilentlyContinue | Out-Null
}

######################################################################################################################################################

IF ($Analyze) {

# This sets the Alias "KD" to the Executible "KD.EXE" listed in the file path of “C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\kd.exe”.
Set-Alias KD “C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\kd.exe”

# Below are the broken down commands for the WindDebug KD.EXE tool that will run.

# Debug commands are specified here.
# See the Debugging Tools For Windows for more details
# $DeBugCommands Commands are:  
# !analyze -v    Verbose analysis of the crash
# kv             Stacktrace
# !process       Current process and thread at crash
# lmf            List loaded modules and file paths
# q              quit KD (or else KD will keep running)

# $DeBugCommands = “`”!analyze -v; kv; !process; lmf; q`””
$DeBugCommands = “!analyze -v;kv;!process;lmf;q”

# Below runs a Foreach loop to generate the crashdump file.

$CrashDumpFile = "C:\All MiniDumps\$Computer\MiniDumps"

Get-ChildItem $CrashDumpFile -Recurse -Force | 
    ForEach {
         $logfile = "{0}\{1}.log" -f $dumpmove, $_.name

        # Execute KD with commands
        KD -c $DeBugCommands -noshell -logo $logfile -z $_.fullname

        #Screen output
        Add-Content $LogFile (“`n Finished debugging: ” + $_.fullname )
        Add-Content $LogFile (“`n Debug Output to log file: ” + $LogFile)
        Add-Content $LogFile (“`n Processed dump files and log files can be found: ” + $DumpMove)


        Copy-Item -path $_.fullname -destination $DumpMove -Force -ErrorAction SilentlyContinue

}# END If (Test-Path -Path $MiniDumpPath)
}# END IF ($Source -ne $null)
}# END IF ($Analyze)
}# END ForEach #2
}# END ForEach #1 
}# END Proccess
}# END Function Get-MiniDump
