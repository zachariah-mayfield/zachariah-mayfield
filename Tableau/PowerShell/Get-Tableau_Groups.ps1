Set-ExecutionPolicy RemoteSigned -force

IF (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.Windows.Identity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  $Arguments = "& '" + $myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $Arguments
  Break
}

Start-Transcript -Path "C:\Logs\Tableau_$(Get-Date).log"

$Tableau_API_Token = Get-Tableau_API_Token # Run this function
$Tableau_Site_ID = Get-Tableau_Sites # Run this function and Pipe the return to a Select and select the Tableau Site ID.
$TableauServerName = "Your-Company-Tableau-Server-Name"
$Environment = 'Development'

#region Get-Tableau_Groups
Function Get-Tableau_Groups {
  [CmdletBinding()]
  Param (
    # $Tableau_API_Token
    [Parameter(Mandatory=$true)
    [string]$Tableau_API_Token,
    # $Tableau_Site_ID
    [Parameter(Mandatory=$true)
    [string]$Tableau_Site_ID,
    # $TableauServerName
    [Parameter(Mandatory=$true)
    [string]$TableauServerName,
    # $Environment
    [Parameter(Mandatory=$true)]
    [ValidateSet('Development', 'UAT', 'Production')]
    [string]$Environment,
    # $TableauServerAPI_Version
    [Parameter(Mandatory=$true)
    [string]$TableauServerAPI_Version
  )# END Param
  Begin {
    # Set the Security Protocol Type
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $VerbosePreference = "Continue"
  }# END Begin
  Process {
    Try {
#region Get-Tableau_Groups
      # Headers
      $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
      $Headers.Add("Content-Type", "application/xml")
      $Headers.Add("X-Tableau-Auth", "$($Tableau_API_Token)")
      # Tableau Server API Call
      $Tableau_Groups_URL = "https://$($TableauServerName).$($Environment).Company-Domain.com/api/$($TableauServerAPI_Version)/sites/$($Tableau_Site_ID)/groups"
      $Tableau_Groups = ((Invoke-RestMethod $Tableau_Groups_URL -Method 'GET' -Headers $Headers -Body $Body -ErrorAction Stop).tsResponse.groups.group)
      $Tableau_Groups
#endregion Get-Tableau_Groups
    }# END TRY
    Catch {
      IF ($null -ne $Error[0].Exception.Message) {
        $Error_Exception = ($_.Exception | Select *)
        $Error_Exception
      }# END IF
      $LASTEXITCODE
      Stop-Transcript
      EXIT $LASTEXITCODE
    }# END Catch
  }# END Process
  End {}
}# END Function Get-Tableau_Groups
#endregion Function Get-Tableau_Groups

Stop-Transcript
