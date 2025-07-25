
Function New-SplunkErrorLog {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
    [String]$Command
    )
    Begin {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    }
    Process {
        # Establish Base Splunk event metadata (index, host and sourcetype)
        $EventBase = @{}
        $EventBase.add("index","perf-ps")
        $EventBase.add("sourcetype","Powershell:Custom:Error")
        $EventBase.add("host",$env:computername)
        Try {
            Invoke-Expression $Command
        }
        Catch {
            IF ($Error[0].Exception.Message -ne $null) {
                # This will select all of the Errors, if any.
                $Error_Exception = ($_.Exception | select * )
                # Event related data goes here, you can add additional fields as necessary
                $EventContent = @{}
                $EventContent.add("Message",$Error_Exception)
            } ELSE {
                # Event related data goes here, you can add additional fields as necessary
                $EventContent = @{}
                $EventContent.add("Message", "PowerShell Command Successful")
            }
        }#END Catch

        #$EventContent.add("FieldName",$FieldContent)
        $EventBase.add("event",$EventContent)
        # Establish Base Splunk event metadata (index, host and sourcetype)
            
        #$JsonEvent
        $JsonEvent = $EventBase | ConvertTo-Json 

        # Send event through HEC
        $token = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        $server = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        $port = 3333
        $url = "http://${server}:$port/services/collector/event"
        $header = @{Authorization = "Splunk $token"}
    }
END {
        Invoke-RestMethod -Method Post -Uri $url -Headers $header -Body $JsonEvent
}
}