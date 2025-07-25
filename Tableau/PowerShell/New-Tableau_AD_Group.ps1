Set-ExecutionPolicy RemoteSigned -force

IF (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.Windows.Identity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  $Arguments = "& '" + $myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $Arguments
  Break
}

Start-Transcript -Path "C:\Logs\Tableau_$(Get-Date).log"

$Tableau_API_Token = Get-Tableau_API_Token # Run this function
$Tableau_Site_ID = Get-Tableau_Sites # Run this function and Pipe the return to a Select and select the Tableau Site ID.
$Tableau_Group_Namme = "Tableau-Group-Name"
$Tableau_Site_Role = "Tableau-Site-Role"
$TableauServerName = "Your-Company-Tableau-Server-Name"
$Environment = 'Development'

#region Function New-Tableau_AD_Group
Function New-Tableau_AD_Group {
  [CmdletBinding()]
  Param (
    # $Tableau_API_Token
    [Parameter(Mandatory=$true)
    [string]$Tableau_API_Token,
    # $Tableau_Site_ID
    [Parameter(Mandatory=$true)
    [string]$Tableau_Site_ID,
    # $Tableau_Group_Namme
    [Parameter(Mandatory=$true)
    [string]$Tableau_Group_Namme,
    # $Tableau_Site_Role
    [Parameter(Mandatory=$true)
    [string]$Tableau_Site_Role,
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
#region New-Tableau_AD_Group
      # Headers
      $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
      $Headers.Add("Content-Type", "application/xml")
      $Headers.Add("X-Tableau-Auth", "$($Tableau_API_Token)")
      # Body
      $Body = "<tsRequest>
      `n  <group name=`"$($Tableau_Group_Namme)`" >
      `n    <import source=`"ActiveDrirectory`" 
      `n       domainNamme=`"Company-Domain.com`"
      `n        grantLicenseMode=`"onSync`"
      `n        siteRole=`"$($Tableau_Site_Role)`"/>
      `n    </group>
      `n</tsRequest>"
      # Tableau Server API Call
      $Tableau_Groups_URL = "https://$($TableauServerName).$($Environment).Company-Domain.com/api/$($TableauServerAPI_Version)/sites/$($Tableau_Site_ID)/groups"
      $Tableau_Groups = ((Invoke-RestMethod $Tableau_Groups_URL -Method 'POST' -Headers $Headers -Body $Body -ErrorAction Stop).tsResponse.group)
      $Tableau_Groups
#endregion New-Tableau_AD_Group
    }# END TRY
    Catch {
      IF ($Error.exception.message -Like "*(409) Conflict*") {
        Write-Host -ForegroudColor Yellow "Group $($Tableau_Group_Namme) Already exists."
      }# END IF
      elseif ($null -ne $Error[0].Exception.Message) {
        $Error_Exception = ($_.Exception | Select *)
        $Error_Exception
      }
      $LASTEXITCODE
      Stop-Transcript
      EXIT $LASTEXITCODE
    }# END Catch
  }# END Process
  End {}
}# END Function New-Tableau_AD_Group
#endregion Function New-Tableau_AD_Group

Stop-Transcript
