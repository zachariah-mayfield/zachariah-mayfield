
Function Get-CMD_ProcessOutput {
  Param (
    [Parameter(Mandatory=$true)]$FileName,$Args
  )
  $Process = New-Object System.Diagnostics.Process
  $Process.StartInfo.UseShellExecute = $false
  $Process.StartInfo.RedirectStandardOutput = $true
  $Process.StartInfo.RedirectStandardError = $true
  $Process.StartInfo.FileName = $FileName
  IF ($Args) {
    $Process.StartInfo.Arguments = $Args
  }
  $Out = $Process.Start()
  $StandardError = $Process.StandardError.ReadToEnd()
  $StandardOutput = $Process.StandardOutput.ReadToEnd()
  $Output = New-Object PSObject
  $Output | Add-Member -type NoteProperty -name StandardError -Value $StandardError
  $Output | Add-Member -type NoteProperty -name StandardOutput -Value $StandardOutput
  return $Output
}

# Run Tableau Backup

$TSM-FileName = "C:\Program Files\Tableau\Tableau Server\<version>\bin\tsm.cmd"

$TSM_Maintenance_Clanup_Arguments = "maintenance clanup -1 -t -r -q -ic --logfiles-retention 7 --http-requests-table-retention 60"
$TSM_Settings_Export_Arguments = "settings export -output-config-file C:\Tableau\Backup\"$env:Hostname"_SettingsConfigBackup_"$Get-Date".json"
$TSM_Maintenance_Backup = "maintenance backup --file C:\Tableau\Backup\"$env:Hostname"_RepositoryFileStoreBackup_"$Get-Date"

Get-CMD_ProcessOutput $TSM-FileName -FileName -Args $TSM_Maintenance_Clanup_Arguments

Get-CMD_ProcessOutput $TSM-FileName -FileName -Args $TSM_Settings_Export_Arguments

Get-CMD_ProcessOutput $TSM-FileName -FileName -Args $TSM_Maintenance_Backup
