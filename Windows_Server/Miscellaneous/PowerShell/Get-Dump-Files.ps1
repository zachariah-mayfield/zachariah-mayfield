CLS

Function Get-DumpFiles {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [String[]]$ComputerName = $env:COMPUTERNAME
    )
    Begin{
    #This was the problem child - this was hiding the reset of the output ($FormatEnumerationLimit=-1) - will show all of the output.
    $global:FormatEnumerationLimit=-1
    }
    Process{
    ForEach ($Computer in $ComputerName){
    $MiniDumpPath = "\\$Computer\C$\Windows\Minidump" 
    If (Test-Path -Path $MiniDumpPath) {
        # Uncomment the part of line below to filter for in the last 30 days. 
        $DMPFileName = (Get-ChildItem -Path $MiniDumpPath -Recurse -Force <#| Where-Object {$_.CreationTime -gt (Get-Date).AddDays(-30)}#>)
        $DName = Foreach ($DMP in $DMPFileName){ $DMP}
        $DCreatedTime = $DMPFileName | Get-Date -UFormat %a-%B-%d-%Y__%r -ErrorAction SilentlyContinue
        
        $Hash = @{
        ServerName = $Computer
        DMPName = $DName
        Created = $DCreatedTime
        }

        $Object = New-Object PSObject -Property $Hash  
        $Object  
    }
}
    
}
    End{}
} 

Get-DumpFiles
