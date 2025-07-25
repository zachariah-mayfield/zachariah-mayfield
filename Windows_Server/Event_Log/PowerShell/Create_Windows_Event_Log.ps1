Set-ExecutionPolicy RemoteSigned -force

IF (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.Windows.Identity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  $Arguments = "& '" + $myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $Arguments
  Break
}

Start-Transcript -Path "C:\Logs\Tableau-Backup_$(Get-Date).log"

$EventLogName = "Application"
$EventSource = "Tableau_Backup"
$Successful_Message = $true or $False # set this to what you want the outcome to be below.

Function New-Windows_Event_Log {
  [CmdletBinding()]
  Param (
    # $EventLogName
    [Parameter(Mandatory=$true)
    [string]$EventLogName,
    # $EventType
    [Parameter(Mandatory=$false)]
    [ValidateSet('Error', 'Information')]
    [string]$EventType,
    # $EventMessage
    [Parameter(Mandatory=$false)
    [string]$EventMessage,
    # $EventSource
    [Parameter(Mandatory=$true)
    [string]$EventSource,
    # $EventID
    [Parameter(Mandatory=$false)
    [string]$EventID
  )
  Begin {
    # Set the Security Protocol Type
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Try {
      Get-EventLog -LogName $EventLogName -Source $EventSource -ErrorAction Stop | Select *
    }# END TRY
    Catch {
      IF ($Error[0].Exception.Message -ne $null -and $Error[0].Exception.Message -eq "No matches found") {
        New-EventLog -LogName $EventLogName -Source $EventSource -ErrorAction SilentlyContinue | Out-Null
      }# END IF
      Else {
        $Error_Exception = ($_.Exception | Select *)
      }# END Else
      Exit
    }# END Catch
  }# END Begin
  Process {
    Try {
      IF ($Successful_Message) {
        $EventID = 7007
        $EventMessage = [Ordered]@{}
        $EventMessage.add( "The Tableau Backup was successful on $(Get-Date)" )
        $EventMessage.add( " BlankLine1",("
"))
        Write-EventLog -LogName $EventLogName -Source $EventSource -EventType $EventType -EventID $EventID -EventMessage $EventMessage.Values -ErrorAction Stop
      }# END IF
      Else {
        $EventID = 9009
        $EventMessage = [Ordered]@{}
        $EventMessage.add( "The Tableau Backup FAILED on $(Get-Date)" )
        $EventMessage.add( " BlankLine1",("
"))
        Write-EventLog -LogName $EventLogName -Source $EventSource -EventType $EventType -EventID $EventID -EventMessage $EventMessage.Values -ErrorAction Stop
      }# END Else
      
    }# END TRY
    Catch {
      IF ($Error[0].Exception.Message -ne $null) {
        $Error_Exception = ($_.Exception | Select *)
      }# END IF
      Exit
    }# END Catch
  }
}# END Function New-Windows_Event_Log

Stop-Transcript
