Clear-Host
Function Add-AD_Security_Permissions_to_AD_Object {
    [CmdletBinding()]
    Param(
        # Parameter help description
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$CSV_Location
    )
    Begin {
        $WarningPreference = 'SilentlyContinue'
        $FormatEnumerationLimit = "0"
    }
    Process {
        $CSV =Import-Csv -Path $CSV_Location
        $CSV_Row_Number = ($csv).count
        $Values = @(0..$CSV_Row_Number)

        ForEach ($v in $Values) {
            If ($null -ne $CSV[$v].ServiceAccount -and $CSV[$v].ServiceAccount -ne "") {
                $Active_Service_Account = $null
                Try {
                    $Active_Service_Account = ((Get-ADUser $CSV[$v].ServiceAccount -ErrorAction SilentlyContinue | Select-Object SamAccountName).SamAccountName)
                }
                Catch {
                    $Active_Service_Account = $null
                }
                Try {
                    If ($null -ne $CSV[$v].ServiceAccount -and $CSV[$v].ServiceAccount -ne "") {
                        Write-Host -ForegroundColor Yellow ("Setting the New Password: ") $CSV[$v].ServiceAccount
                        Set-ADAccountPassword -Identity $Active_Service_Account -NewPassword (ConvertFrom-SecureString $CSV[$v].Password -AsPlainText -Force) -Reset -Confirm:$false -Verbose
                    }
                    Else {
                        Write-Host -ForegroundColor Red ("Could NOT find Service account: ") $CSV[$v].ServiceAccount
                    }
                }
                Catch {
                    
                }
            }
        }
    }
    End {

    }
}
