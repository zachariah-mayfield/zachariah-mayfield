Set-ExecutionPolicy RemoteSigned -force

IF (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.Windows.Identity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  $Arguments = "& '" + $myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $Arguments
  Break
}

Start-Transcript -Path "C:\Logs\Tableau_$(Get-Date).log"

$Tableau_API_Token = Get-Tableau_API_Token # Run this function
$Tableau_Site_ID = Get-Tableau_Sites # Run this function and Pipe the return to a Select and select the Tableau Site ID.
$Tableau_Site_Guest_Access_State = $true
$TableauServerName = "Your-Company-Tableau-Server-Name"
$Environment = 'Development'

#region Function Set-Tableau_Guest_Access
Function Set-Tableau_Guest_Access {
  [CmdletBinding()]
  Param (
    # $Tableau_API_Token
    [Parameter(Mandatory=$true)
    [string]$Tableau_API_Token,
    # $Tableau_Site_ID
    [Parameter(Mandatory=$true)
    [string]$Tableau_Site_ID,
    # $Tableau_Site_Guest_Access_State
    [Parameter(Mandatory=$true)
    [bool]$Tableau_Site_Guest_Access_State,
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
#region Set-Tableau_Guest_Access
      # Headers
      $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
      $Headers.Add("Content-Type", "application/xml")
      $Headers.Add("X-Tableau-Auth", "$($Tableau_API_Token)")
      # Body
      $Body = "<tsRequest>
      `n  <site
      `n  <guestAccessEnabled=`"$($Tableau_Site_Guest_Access_State)`" />
      `n</tsRequest>"
      # Tableau Server API Call
      $Set_Tableau_Site_Guest_Access_URL = "https://$($TableauServerName).$($Environment).Company-Domain.com/api/$($TableauServerAPI_Version)/sites/$($Tableau_Site_ID)"
      $Set_Tableau_Site_Guest_Access_URL_Response = ((Invoke-RestMethod $Set_Tableau_Site_Guest_Access_URL -Method 'PUT' -Headers $Headers -Body $Body -ErrorAction Stop).tsResponse.site | ConverTo-Json)
      $Set_Tableau_Site_Guest_Access_URL_Response
#endregion Set-Tableau_Guest_Access
    }# END TRY
    Catch {
      IF ($null -ne $Error[0].Exception.Message) {
        $Error_Exception = $_.Exception.Response.GetResponseStream()
        $ResponseStream_Reader = New-Object System.IO.StreamReader($Error_Exception)
        $ResponseStream_Reader.baseStream.Position = 0
        $ResponseStream_Reader.DiscardBufferedData()
        $ResponseBody = (($ResponseStream_Reader.ReadToEnd() -split '<detail>')[1] -repalce '<detail></error></tsResponse>','')
        return $ResponseBody
      }# END IF
      $LASTEXITCODE
      Stop-Transcript
      EXIT $LASTEXITCODE
    }# END Catch
  }# END Process
  End {}
}# END Function Set-Tableau_Guest_Access
#endregion Function Set-Tableau_Guest_Access

Stop-Transcript
