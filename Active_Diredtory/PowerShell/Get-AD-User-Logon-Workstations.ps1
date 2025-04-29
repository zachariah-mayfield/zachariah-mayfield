CLS

$ServiceAccounts = (Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $false} `
–Properties "SamAccountName" -SearchBase "OU=ServiceAccounts,OU=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx,OU=Enterprise Services").SamAccountName

Function Get-ADUserLogonWorkstations {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String[]]$SamAccountName
    )
    Begin {
    $FormatEnumerationLimit="0"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    }
    Process {
        ForEach ($User in $SamAccountName) {
            $LogonWorkstations = (Get-ADUser -Identity $User -Properties LogonWorkstations | select -ExpandProperty LogonWorkstations)
            IF ($LogonWorkstations -notmatch "null"){
                $Object = New-Object -TypeName PSObject
                $Object | Add-Member -MemberType NoteProperty -Name ”SamAccountName” -Value ($User)
                $Object | Add-Member -MemberType NoteProperty -Name ”LogonWorkstations” -Value ($LogonWorkstations)
                $event = @{event = $Object; index = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';  host = $env:computername; sourcetype = "test"} | ConvertTo-Json
                $event
                $token = "Splunk Token goes here"
                $server = "Aplunk Server name goes here"
                $port = 'Splunk Server port goes here'
                $url = "http://${server}:$port/services/collector/event"
                $header = @{Authorization = "Splunk $token"}

                Invoke-RestMethod -Method Post -Uri $url -Headers $header -Body $event
            }
        }
    }
    END{}
}#END Function

Get-ADUserLogonWorkstations -SamAccountName $ServiceAccounts
