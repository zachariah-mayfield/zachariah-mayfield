CLS

#Import-Module -Name "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\CustomErrorHandling\CustomErrorHandling.PSD1" -Force

Function Upload_AZ_Files {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
        [Parameter()]
        [System.IO.FileInfo]$Source_Location,
        [Parameter()]
        [String]$Container,
        [System.Management.Automation.PSCredential]$Credential
    )
Begin {
    $FormatEnumerationLimit="0"
    # This will allow a pop up window to enter the users credentials to log into Azure.
    Connect-AzAccount -Credential $Credential -ErrorAction Stop  
    # This will set the Default Actionable Scubdcription Name
    Set-AzContext -Subscription "Subscription id" -Tenant "Tenant id" -ErrorAction Stop  
    # This will set the Default Actionable Storage account Name
    Set-AzCurrentStorageAccount -ResourceGroupName "Resource Group Name" -AccountName "Account Name" -ErrorAction Stop  
}
Process {
    # This will gather all of the files under the $source Location | 
    # Then it will copy them all the the "sourcefiles" Container in Resource Group
    # It will also force overwrite anyfile there with the same name
    $Todays_Date = (Get-Date -Format "yyyy-MM-dd")
    $Append_Date = ( "_" + $Todays_Date)
    #Get-ChildItem -Path $Source_Location -File -Recurse | Set-AzStorageBlobContent -Container "labtestdata" -Force
    $XFile = (Get-ChildItem -Path $Source_Location -ErrorAction Stop  | Sort LastWriteTime | Select -last 1 ) 
    ForEach ($Source_File in $XFile) {
        [string]$File = ([string]$XFile.FullName)
        [string]$Blob = ([string]$XFile.BaseName +[string]$Append_Date + [string]$XFile.Extension)
        [string]$Blob2 = ([string]$XFile.Name)
        If ($Source_File -notlike "TestsByLab_*") {
            Set-AzStorageBlobContent -Container $Container -File $File -Blob $Blob -BlobType Block -Force -ErrorAction Stop 
        } 
        Else {
            Set-AzStorageBlobContent -Container $Container -File $File -Blob $Blob2 -BlobType Block -Force -ErrorAction Stop 
        }
    }
}
END{}
}#END Function

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
        $EventBase.add("index","xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
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
        $token = "Splunk Token"
        $server = "Splunk Server Name"
        $port = 'Splunk port number'
        $url = "http://${server}:$port/services/collector/event"
        $header = @{Authorization = "Splunk $token"}
    }
END {
        Invoke-RestMethod -Method Post -Uri $url -Headers $header -Body $JsonEvent
}
}# End Function 
