
Function Get-ApplicationInfo 
{  
 
[CmdletBinding()]  
Param  
    (  
        # Enter a ComputerName or IP Address, accepts multiple ComputerNames 
        [Parameter(  
        ValueFromPipeline=$True,  
        ValueFromPipelineByPropertyName=$True, 
        HelpMessage="Enter a ComputerName or IP Address, accepts multiple ComputerNames")]  
        [String[]]$ComputerName = "$env:COMPUTERNAME", 
        # Activate this switch to force the function to run an ICMP check before running 
        [Parameter( 
        HelpMessage="Activate this switch to force the function to run an ICMP check before running")] 
        [Switch]$ping 
    )  
Begin   
    { 
        Write-Verbose "Instantiating Function Paramaters" 
            $param = @{ScriptBlock = { 
                if ((Get-WmiObject win32_operatingsystem).OSArchitecture -notlike '64-bit')  
                    { 
                        $keys= (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*') 
                    }  
                else  
                    { 
                        $keys = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*') 
                    }   
                $Keys |  
                Where-Object {$_.Publisher -or $_.UninstallString -or $_.displayversion -or $_.DisplayName} |  
                ForEach-Object {  
                        New-Object -TypeName PSObject -Property @{  
                                Computer = $env:COMPUTERNAME 
                                Company = $_.Publisher  
                                Uninstall = $_.UninstallString  
                                Version = $_.displayversion  
                                Product = $_.DisplayName  
                            }  
                    } 
                }} 
    }  
Process  
    { 
        foreach ($Computer in $ComputerName)  
            { 
                If ($Ping)  
                    { 
                        Write-Verbose "Testing connection to $Computer" 
                        if (-not(Test-Connection -ComputerName $Computer -Quiet))  
                            { 
                                Write-Warning "Could not ping $Computer" ; $Problem = $true 
                            } 
                    } 
                Write-Verbose "Beginning operation on $Computer" 
                If (-not($Problem)) 
                    { 
                        If ($Computer -ne $env:COMPUTERNAME)  
                            { 
                                Write-Verbose "Adding ComputerName, $Computer, to Invoke-Command" 
                                $param.Add("ComputerName",$Computer) 
                            } 
                        Try 
                            { 
                                Write-Verbose "Invoking Command on $Computer" 
                                Invoke-Command @param | Select-Object -Property Computer,Company,Product,Version,Uninstall 
                            } 
                        Catch  
                            { 
                                Write-warning $_.Exception.Message 
                            } 
                    } 
                if ($Problem) {$Problem = $false} 
                if ($param.ContainsKey('ComputerName'))  
                    { 
                        Write-Verbose "Clearing $Computer from Parameters" 
                        $param.Remove("ComputerName") 
                    }  
            } 
    }  
End {}  
}
# This is the END of The Functions Get-ApplicationInfo ***********************************************************



