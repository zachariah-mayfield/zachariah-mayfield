#  Tableau_backup
#
#############################################################################################################################################################
# If process is not launched with "Run As Administrator" this will open a new Admin powershell
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {   
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}

#############################################################################################################################################################

# Set the executionpolicy
Write-Output "Setting Execution Policy"
IF ((Get-ExecutionPolicy) -ne "RemoteSigned") {Set-ExecutionPolicy RemoteSigned -force}
# Change to local path, some commands do not work with network locations
cd ~

#############################################################################################################################################################

$TSM = ((Get-Command tsm).Source)
$Date = Get-Date -Format "yyyMMddHHmmss"
$Tabcluster = ((($env:COMPUTERNAME).Substring(9)).remove(4).toupper() + '_')
$Environment = (($env:COMPUTERNAME).Substring(2)).remove(3)

#############################################################################################################################################################

IF ( -not (Test-Path -Path 'C:\logs' -PathType Container)) {
    Try {
        New-Item -Path "C:\" -Name "logs" -ItemType "directory" -ErrorAction Stop | Out-Null
    }
    Catch {
        IF ($Error[0].Exception.Message -ne $null) {
        # This will select all of the Errors, if any.
        $Error_Exception = ($_.Exception | select * )
        $Error_Exception
        }
        Exit
    }
}

#############################################################################################################################################################

$Transcript_File = "$($tabcluster)Tableau_backup$($Date).log"

#############################################################################################################################################################

Try {
    New-Item -Path 'C:\logs\' -Name $Transcript_File -ItemType 'file' -ErrorAction Stop | Out-Null
}
Catch {
    IF ($Error[0].Exception.Message -ne $null) {
        # This will select all of the Errors, if any.
        $Error_Exception = ($_.Exception | select * )
        $Error_Exception
    }
    Exit
}

#############################################################################################################################################################

Start-Transcript -Path "C:\logs\$($Transcript_File)"

#############################################################################################################################################################

function Get-ProcessOutput {
    Param (
        [Parameter(Mandatory=$true)]$FileName,$Args
    )
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo.UseShellExecute = $false
    $process.StartInfo.RedirectStandardOutput = $true
    $process.StartInfo.RedirectStandardError = $true
    $process.StartInfo.FileName = $FileName
    IF ($Args) { $process.StartInfo.Arguments = $Args }
    $out = $process.Start()
    
    $StandardError = $process.StandardError.ReadToEnd() 
    $StandardOutput = $process.StandardOutput.ReadToEnd()
    
    $output = New-Object PSObject
    $output | Add-Member -type NoteProperty -name StandardOutput -Value $StandardOutput
    $output | Add-Member -type NoteProperty -name StandardError -Value $StandardError
    return $output
}

#############################################################################################################################################################

function Run-TSM {
    [CmdletBinding()]
    Param(
        # TSM Parameters
        [Parameter(Mandatory=$true)]
        [ValidateSet('maintenance cleanup -all', 'settings export --output-config-file', 'maintenance backup --file')]
        [String]$Arguments,
        # TSM Parameter Value
        [Parameter(Mandatory=$false)]
        #[ValidateSet('')]
        [String]$Arg_Value
    )
    Begin {
        IF ($Arguments -eq 'maintenance cleanup -all') {
            $AllArgs = @('maintenance', 'cleanup', '-all')
        }    
        IF ($Arguments -eq 'settings export --output-config-file') {
            $AllArgs = @('settings', 'export', '--output-config-file', $Arg_Value)
        }
        IF ($Arguments -eq 'maintenance backup --file') {
            $AllArgs = @('maintenance', 'backup', '--file', $Arg_Value)
        }
        Write-Output "`r`n" "Started TSM_Process: $($TSM) $($AllArgs)" "`r`n"
    }
    Process {
        $TSM_Output = Get-ProcessOutput -FileName $TSM -Args $AllArgs
        #$TSM_Output = @($TSM_Output -split '`n')
        Write-Host -ForegroundColor Green $TSM_Output.StandardOutput
        Write-Host -ForegroundColor Red $TSM_Output.StandardError
    }
    End {
        Write-Output "`r`n" "End TSM_Process." "`r`n"
    }
}

#############################################################################################################################################################

Run-TSM -Arguments 'maintenance cleanup -all'

#############################################################################################################################################################

Run-TSM -Arguments 'settings export --output-config-file' -Arg_Value "C:\backup\$($tabcluster)SettingsConfigBackup$($Date).json"

#############################################################################################################################################################

Run-TSM -Arguments 'maintenance backup --file' -Arg_Value "$($tabcluster)RepositoryFileStoreBackup$($Date)"

#############################################################################################################################################################

Function Start-AzCopy_Tableau_BackUp {
    [CmdletBinding()]
    Param(
        # $env:HTTP_PROXY = 'http://zscaler-vse.xxx.com:443'
        [Parameter(Mandatory=$true)]
        [ValidateSet('http://zscaler-vse.xxx.com:443','http://zscaler-vse.xxx.com:443')]
        [String]$HTTP_Proxy,
        # $env:HTTPS_PROXY = 'http://zscaler-vse.xxx.com:443'
        [Parameter(Mandatory=$true)]
        [ValidateSet('http://zscaler-vse.xxx.com:443','http://zscaler-vse.xxx.com:443')]
        [string]$HTTPS_Proxy,
        # $env:No_PROXY = $null
        [Parameter(Mandatory=$false)]
        [bool]$No_Proxy,
        # 
        [Parameter(Mandatory=$true)]
        [ValidateSet('tableau','tableau')]
        [String]$Azure_Storage_Account,
        # 
        [Parameter(Mandatory=$true)]
        [ValidateSet('tableau-backup')]
        [String]$Container,
        #
        [Parameter(Mandatory=$true)]
        [ValidateSet('sp=',
                     'sp='
        )]
        [String]$SAS_Token,
        #
        [Parameter(Mandatory=$true)]
        [ValidateSet('C:\backup\TABR_RepositoryFileStoreBackup*.tsbak','C:\backup\TABR_SettingsConfigBackup*.json')]
        [String]$Source_File
    )
    Begin {
        #$Date = Get-Date -Format "yyyMMddHHmmss"

        #Start-Transcript -Path "C:\logs\AzCopy_Tableau_backup_$($Date).log"
        
        # Setting the Security Protocol Type
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        If ($HTTP_Proxy) {
            $env:HTTP_PROXY = $HTTP_Proxy
        }
        
        IF ($HTTPS_Proxy) {        
            $env:HTTPS_PROXY = $HTTPS_Proxy
        }
        
        IF ($No_Proxy) {
            $env:No_PROXY = $null
            Write-Output "No Proxy is set to: $($env:No_PROXY)"
        }

        Try {
            # Source Tableau Blob File
            $Tableau_Blob_File = $((Get-ChildItem -Path $($Source_File) -ErrorAction Stop) | Sort LastWriteTime -Descending | Select -First 1).FullName
        }
        Catch {
            IF ($Error[0].Exception.Message -ne $null) {
                # This will select all of the Errors, if any.
                $Error_Exception = ($_.Exception | select * )
            }
            Exit
        }
        Try {
            # Check to make sure that 
            $Check_AzCopy_Exists = (Test-Path -Path 'C:\azcopy.exe' -PathType Leaf -ErrorAction Stop)
        }
        Catch {
            IF ($Error[0].Exception.Message -ne $null) {
                # This will select all of the Errors, if any.
                $Error_Exception = ($_.Exception | select * )
            }
            Exit
        }
        If ($Check_AzCopy_Exists -eq $true) {
            Try { 
                Set-Location -Path 'C:\' -ErrorAction Stop
            }
            Catch {
                IF ($Error[0].Exception.Message -ne $null) {
                    # This will select all of the Errors, if any.
                    $Error_Exception = ($_.Exception | select * )
                }
                Exit
            }
        }
        Else {
            Write-Output "AzCopy not found."
            Exit
        }
    }
    Process {
        $SAS_URL = "https://$($Azure_Storage_Account).blob.core.windows.net/$($Container)/?$($SAS_Token)"

        Write-Output "Running AZCopy to upload file: $($Tableau_Blob_File) to the storage account: $($Azure_Storage_Account) to the container: $($Container)"

        .\azcopy.exe copy $($Tableau_Blob_File) $SAS_URL 
    }
    
    End {}
}

#$Environment = (($env:COMPUTERNAME).Substring(2)).remove(3)

#############################################################################################################################################################

IF ($Environment -match "dev") {
    Start-AzCopy_Tableau_BackUp `
    -HTTP_Proxy http://zscaler-vse.xxx.com:443 `
    -HTTPS_Proxy http://zscaler-vse.xxx.com:443 `
    -Azure_Storage_Account xxxtableau `
    -Container tableau-backup `
    -SAS_Token 'sp=' `
    -Source_File C:\backup\TABR_RepositoryFileStoreBackup*.tsbak `
    -No_Proxy $true

    Start-AzCopy_Tableau_BackUp `
    -HTTP_Proxy http://zscaler-vse.xxx.com:443 `
    -HTTPS_Proxy http://zscaler-vse.xxx.com:443 `
    -Azure_Storage_Account mpdevcussatableau `
    -Container tableau-backup `
    -SAS_Token 'sp=' `
    -Source_File C:\backup\TABR_SettingsConfigBackup*.json `
    -No_Proxy $true
}

#############################################################################################################################################################
### Environment = Clone ###
IF ($Environment -match "cln") {
    Start-AzCopy_Tableau_BackUp `
    -HTTP_Proxy http://zscaler-vse.xxx.com:443 `
    -HTTPS_Proxy http://zscaler-vse.xxx.com:443 `
    -Azure_Storage_Account xxxtableau `
    -Container tableau-backup `
    -SAS_Token 'sp=' `
    -Source_File C:\backup\TABR_RepositoryFileStoreBackup*.tsbak  `
    -No_Proxy $true

    Start-AzCopy_Tableau_BackUp `
    -HTTP_Proxy http://zscaler-vse.XXX.com:443 `
    -HTTPS_Proxy http://zscaler-vse.XXX.com:443 `
    -Azure_Storage_Account XXXtableau `
    -Container tableau-backup `
    -SAS_Token 'sp=' `
    -Source_File C:\backup\TABR_SettingsConfigBackup*.json `
    -No_Proxy $true
}
#############################################################################################################################################################
### Environment = Production ###
<#IF ($Environment -match "prd") {
    Start-AzCopy_Tableau_BackUp `
    -HTTP_Proxy  `
    -HTTPS_Proxy  `
    -Azure_Storage_Account  `
    -Container  `
    -SAS_Token  `
    -Source_File  `
    -No_Proxy $true

    Start-AzCopy_Tableau_BackUp `
    -HTTP_Proxy  `
    -HTTPS_Proxy  `
    -Azure_Storage_Account  `
    -Container  `
    -SAS_Token  `
    -Source_File  `
    -No_Proxy $true
}#>
#############################################################################################################################################################

Function Invoke-Azure_Container_File_Retention_Maintenance {
    [CmdletBinding()]
    Param(
        # $env:HTTP_PROXY = 'http://zscaler-vse.xxx.com:443'
        [Parameter(Mandatory=$true)]
        [ValidateSet('http://zscaler-vse.xxx.com:443','http://zscaler-vse.xxx.com:443')]
        [String]$HTTP_Proxy,
        # $env:HTTPS_PROXY = 'http://zscaler-vse.xxx.com:443'
        [Parameter(Mandatory=$true)]
        [ValidateSet('http://zscaler-vse.xxx.com:443','http://zscaler-vse.xxx.com:443')]
        [string]$HTTPS_Proxy,
        # $env:No_PROXY = $null
        [Parameter(Mandatory=$false)]
        [bool]$No_Proxy,
        # 
        [Parameter(Mandatory=$true)]
        [ValidateSet('XXXtableau','XXXtableau')]
        [String]$Azure_Storage_Account,
        # 
        [Parameter(Mandatory=$true)]
        [ValidateSet('tableau-backup')]
        [String]$Container,
        #
        [Parameter(Mandatory=$true)]
        [ValidateSet('sp=',
                     'sp='
        )]
        [String]$SAS_Token
        #
    )
    Begin {
        #$Date = Get-Date -Format "yyyMMddHHmmss"

        #Start-Transcript -Path "C:\logs\AzCopy_Tableau_backup_$($Date).log"
        
        # Setting the Security Protocol Type
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        If ($HTTP_Proxy) {
            $env:HTTP_PROXY = $HTTP_Proxy
        }
        IF ($HTTPS_Proxy) {        
            $env:HTTPS_PROXY = $HTTPS_Proxy
        }
        IF ($No_Proxy) {
            $env:No_PROXY = $null
            Write-Output "No Proxy is set to: $($env:No_PROXY)"
        }
        Try {
            # Check to make sure that 
            $Check_AzCopy_Exists = (Test-Path -Path 'C:\azcopy.exe' -PathType Leaf -ErrorAction Stop)
        }
        Catch {
            IF ($Error[0].Exception.Message -ne $null) {
                # This will select all of the Errors, if any.
                $Error_Exception = ($_.Exception | select * )
            }
            Exit
        }
        If ($Check_AzCopy_Exists -eq $true) {
            Try { 
                Set-Location -Path 'C:\' -ErrorAction Stop
            }
            Catch {
                IF ($Error[0].Exception.Message -ne $null) {
                    # This will select all of the Errors, if any.
                    $Error_Exception = ($_.Exception | select * )
                }
                Exit
            }
        }
        Else {
            Write-Output "AzCopy not found."
            Exit
        }
    }#END Begin
    Process {
        $SAS_URL = "https://$($Azure_Storage_Account).blob.core.windows.net/$($Container)/?$($SAS_Token)"

        $AzList = ((.\azcopy.exe list $SAS_URL --properties 'LastModifiedTime' | select -Skip 2).Split([Environment]::NewLine))

        $AzBlobs = ForEach ($AzFile in $AzList) {
            $New_AzFile = ($AzFile) -split ";"
            $AzFileName_Object = [PSCustomObject]@{
                AzFileName = ($New_AzFile -replace "INFO: " -split ",")[0]
                LastModifiedTime = [datetime]((($New_AzFile -replace " LastModifiedTime: ") -replace '\+' -replace '0000 GMT'-split ",")[1])
            }
            $AzFileName_Object
        }

        $Limit = ((Get-Date).AddDays(-8))

        $TsBak_AzFiles = ($AzBlobs | Where-Object {$_.AzFileName -like "*.tsbak" -and $_.LastModifiedTime -lt $Limit})
        
        $Json_AzFiles = ($AzBlobs | Where-Object {$_.AzFileName -like "*.json" -and $_.LastModifiedTime -lt $Limit})
        
        $Rem_Blobs = ($TsBak_AzFiles.azfilename + $Json_AzFiles.azfilename)
        
        Foreach ($Rem_Blob in $Rem_Blobs) {
            If ($null -ne $Rem_Blob) {
                $SAS_URL_2 = "https://$($Azure_Storage_Account).blob.core.windows.net/$($Container)/$($Rem_Blob)?$($SAS_Token)"
                # THIS IS THE DELETE Command - just Comment out --dry-run

                Write-Output "Running AZCopy to remove file: $($Rem_Blob) from the container: $($Container) from the storage account: $($Azure_Storage_Account)"

                .\azcopy.exe rm $SAS_URL_2 ###--dry-run
            }
        }
    }#END Process
    End {
        #Stop-Transcript
    }
}

#$Environment = (($env:COMPUTERNAME).Substring(2)).remove(3)

#############################################################################################################################################################
### Environment = Development ###
IF ($Environment -match "dev") {
    Invoke-Azure_Container_File_Retention_Maintenance `
    -HTTP_Proxy http://zscaler-vse.XXX.com:443 `
    -HTTPS_Proxy http://zscaler-vse.XXXX.com:443 `
    -Azure_Storage_Account XXXtableau `
    -Container tableau-backup `
    -SAS_Token 'sp=' `
    -No_Proxy $true
}
#############################################################################################################################################################
### Environment = Clone ###
IF ($Environment -match "cln") {
    Invoke-Azure_Container_File_Retention_Maintenance `
    -HTTP_Proxy http://zscaler-vse.xxx.com:443 `
    -HTTPS_Proxy http://zscaler-vse.xxx.com:443 `
    -Azure_Storage_Account XXXtableau `
    -Container tableau-backup `
    -SAS_Token 'sp=' `
    -No_Proxy $true
}
#############################################################################################################################################################
### Environment = Production ###
<#IF ($Environment -match "prd") {
    Invoke-Azure_Container_File_Retention_Maintenance `
    -HTTP_Proxy  `
    -HTTPS_Proxy  `
    -Azure_Storage_Account  `
    -Container  `
    -SAS_Token  `
    -No_Proxy $true
}#>
#############################################################################################################################################################
#>
Stop-Transcript
