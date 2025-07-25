Set-ExecutionPolicy RemoteSigned -force

IF (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.Windows.Identity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  $Arguments = "& '" + $myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $Arguments
  Break
}

Start-Transcript -Path "C:\Logs\Tableau_$(Get-Date).log"

$Tableau_API_UserName = CyberArk_UserName
$Tableau_API_Password = CyberArk_Password
$TableauServerName = "Your-Company-Tableau-Server-Name"
$Environment = 'Development'

#region Get-Tableau_Sites
Function Get-Tableau_Sites {
  [CmdletBinding()]
  Param (
    # $Tableau_API_Token
    [Parameter(Mandatory=$true)
    [string]$Tableau_API_Token,
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
#region Get Tableau Sites
      # Headers
      $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
      $Headers.Add("Content-Type", "application/xml")
      $Headers.Add("X-Tableau-Auth", "$($Tableau_API_Token)")
      # Tableau Server API Call
      $Tableau_Sites_URL = "https://$($TableauServerName).$($Environment).Company-Domain.com/api/$($TableauServerAPI_Version)/sites"
      $Tableau_Sites = ((Invoke-RestMethod $Tableau_Sites_URL -Method 'GET' -Headers $Headers -Body $Body -ErrorAction Stop).tsResponse.Sites.site)
      $Tableau_Sites
#endregion Get Tableau Sites
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
}# END Function Get-Tableau_Sites
#endregion Function Get-Tableau_Sites

Stop-Transcript
