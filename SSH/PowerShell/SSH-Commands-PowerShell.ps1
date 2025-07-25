Clear-Host
# Using POSH_SSH Module and CredentialManager module from the PS Gallery
# Find-Module -Name CredentialManager | Install-Module -Scope 'CurrentUser' -Force | Import-Module -Force
# Find-Module -Name Posh-SSH | Install-Module -Scope 'CurrentUser' -Force | Import-Module -Force

Function Start-SSH_Command {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param (
        # Parameter help description
        [Parameter()]
        [string]$SSH_UserName = (Get-StoredCredential -Target 'Domain' -Type Generic -AsCredentialObject).UserName,
        # Parameter help description
        [Parameter()]
        [securestring]$SSH_PassWord = (Get-StoredCredential -Target 'Domain' -Type Generic -AsCredentialObject).Password,
        # Parameter help description
        [Parameter(Mandatory)]
        [ValidateSet(
            "Server_11",
            "Server_12",
            "Server_13",
            "Server_14",
            "Server_15",
            "Server_16",
            "Server_17",
            "Server_18"
        )]
        [string]$HostName
    )
    begin {
        $WarningPreference = "SilentlyContinue"
        $FormatEnumerationLimit = "0"
        $Credential = New-Object System.Management.Automation.PSCredential ($SSH_UserName, $SSH_PassWord)
    }
    process {
        $SSH_Command = {"Get-Process"}
        $SSH_Connection = (New-SSHSession -HostName $HostName -Port 22 -Credential $Credential -AcceptKey -Force -WarningAction 'SilentlyContinue')
        $SSH_Response = (Invoke-SSHCommand -SSHSession $SSH_Connection -Command $SSH_Command)
        $SSH_Response.Output
    }
    end {
        Get-SSHSession | Remove-SSHSession | Out-Null
    }
}

Start-SSH_Command -HostName "Server_11"
