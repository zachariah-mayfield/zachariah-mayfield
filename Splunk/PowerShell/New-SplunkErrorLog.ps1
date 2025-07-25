CLS

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
        $token = "Splunk token"
        $server = "Splunk Server Name"
        $port = xxxx
        $url = "http://${server}:$port/services/collector/event"
        $header = @{Authorization = "Splunk $token"}
    }
END {
        Invoke-RestMethod -Method Post -Uri $url -Headers $header -Body $JsonEvent
}
}# 

Function Get-Corp_Credentials {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
        [Parameter(Mandatory=$true)]
        [String]$UserName,
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$AES_FilePath,
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$Password_FilePath,
        [Switch]$DecryptPassword
    )
    Begin {}
    Process {
        IF ($DecryptPassword) {
            $Password = Get-Content $Password_FilePath | ConvertTo-SecureString -Key (Get-Content $AES_FilePath)
            $Decrypt_Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
            [pscustomobject]@{
                Password = $Decrypt_Password
            }
        }
        Else {
            # This will retrieve these credentials.
            $EncryptedPassword = Get-Content $Password_FilePath | ConvertTo-SecureString -Key (Get-Content $AES_FilePath)

            # This will store the UserName and Password in the $Credential variable.
            $Credential = New-Object System.Management.Automation.PsCredential($UserName,$EncryptedPassword)
            $Credential
        }
    }
    End {}
}


Function DownLoad_AZ_Files {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
        [Parameter()]
        [System.IO.FileInfo]$Destination,
        [Parameter()]
        [String]$Blob,
        [Parameter()]
        [String]$Container,
        [Parameter()]
        [System.Management.Automation.PSCredential]$Credential
    )
Begin {
    $FormatEnumerationLimit="0"
    # This will allow a pop up window to enter the users credentials to log into Azure.
    Connect-AzAccount -Credential $Credential -ErrorAction Stop  
    # This will set the Default Actionable Scubdcription Name 
    Set-AzContext -Subscription "Subscription ID" -Tenant "Tenant ID" -ErrorAction Stop  
    # This will set the Default Actionable Storage account Name: "" under the Resource Group Name  - so that it can be wworked with.
    Set-AzCurrentStorageAccount -ResourceGroupName "Resource Group Name" -AccountName "AccountName" -ErrorAction Stop  
}
Process {
    # This will gather all of the files under the -Container $Container | 
    # Then it will set them all to the $BlockBlobs Varriable and download |
    # it to the $Destination in Resource Group  Storage account |
    # Name: "" It will also force overwrite any file there with the same name.
    $Todays_Date = (Get-Date -Format "yyyyMMdd")
    $BLOB_X = ($Blob_1 + $Todays_Date + "*" + ".csv")
    $BlockBlobs = ((Get-AzStorageBlob -Container $Container -ErrorAction Stop) | where {$_.Name -like $BLOB_X -and $_.Name -notlike "*diff.csv"}).Name
    Get-AzStorageBlobContent -Container $Container -Destination $Destination -Blob $BlockBlobs -Force -ErrorAction Stop
}# END Process
END{}# END END
}# END Function

