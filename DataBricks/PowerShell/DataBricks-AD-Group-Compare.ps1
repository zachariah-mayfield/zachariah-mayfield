Clear-Host
IF ($PSVersionTable.PSVersion.Major -lt '7') {
	Write-Host -ForegroundColor Yellow	'Please update your version of powershell to the latest version.'
    # Install latest version of powershell:
    # https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/PowerShell-7.2.1-win-x64.msi
}
elseif ((Get-Command -Name Get-AzDataLakeGen2Item).Source -notmatch "AZ.Storage") {
	Write-Host -ForegroundColor Yellow	'In order to run this script you will need to install the PowerShell AZ Module. To do so, open PowerShell as an admin and run the following command:' ' Install-Module -Name AZ -Repository 'PSGallery' -Scope 'CurrentUser' -AcceptLicense -Force -Verbose'
}

$DataBricks_Environment = 'Development'

If ($DataBricks_Environment -eq 'Development') {
    $DataBricks_PAT = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $DataBricks_Instance = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
}
elseif ($DataBricks_Environment -eq 'Production') {
    $DataBricks_PAT = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $DataBricks_Instance = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
}

$Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Headers.Add('Authorization', "Bearer $($DataBricks_PAT)")
$Headers.Add('Accept', 'application/json')

$Api_Version = '.azuredatabricks.net/api/2.0/'
$Get_Groups = 'groups/list'

$URL = "https://$($DataBricks_Instance)$($Api_Version)$($Get_Groups)"

$Response = (Invoke-RestMethod -Method Get -Uri $URL -Headers $Headers)

$DB_Groups = ($Response.group_names ) #| Sort-Object

ForEach ($Group in $DB_Groups) {
    try {
        # xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        # (Get-ADGroup -Filter "GroupCategory -eq 'Security'" -SearchBase "OU=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" | Where {$_.ObjectClass -eq "group"}).name | sort
        $DB_Group = (Get-ADGroup -Identity $Group -ErrorAction 'stop')
        Write-Host -ForegroundColor Cyan $DB_Group.Name " exists in on Prem AD."
    }
    catch {
        IF ($_.Exception) {
            Write-Host -ForegroundColor Magenta $Group " does not exist in on Prem AD." #$_.Exception
            try {
                $DB_Group = (Get-AzADGroup -DisplayName $Group -ErrorAction 'stop')
                Write-Host -ForegroundColor Cyan $DB_Group.Name " exists in Azure AD."
            }
            catch {
                IF ($_.Exception) {
                    Write-Host -ForegroundColor Yellow $Group " does not exist in Azure AD." #$_.Exception
                }
            }
        }
    }
}
