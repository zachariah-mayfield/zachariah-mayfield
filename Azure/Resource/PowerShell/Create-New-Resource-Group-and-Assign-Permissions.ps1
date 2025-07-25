CLS

Function Create-AzureRG_N_SetRole {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
        [Parameter()]
        [System.Management.Automation.PSCredential]$Azure_Credential,
        [Parameter(Mandatory=$true)]
        [ValidateSet("Dev","Test","UAT")]
        [String]$Environment,
        [Parameter(Mandatory=$true)]
        [ValidateSet("Reader","Contributor","Owner")]
        [String]$AzAccessType,
        [Parameter(Mandatory=$true)]
        [String]$NewResourceGroupName,
        [Parameter(Mandatory=$true)]
        [String]$Description,
        [Parameter(Mandatory=$true)]
        [String]$System,
        <# $AzureSubscriptionID = "xxxxxxxxxxxxxxxxxxxxxxxxx" # This is the Subscription ID for -> xxxxxxxxxx #>
        [Parameter(Mandatory=$true)]
        [String]$AzureSubscriptionID,
        [Parameter(Mandatory=$true)]
        [String[]]$AzUser
    )
Begin {
    $FormatEnumerationLimit="0"
    Try {
        Select-AzContext -Name $AzureSubscriptionID -ErrorAction Stop | Out-Null
        Write-Host -ForegroundColor Cyan "Connection to the SubscriptionName: $AzureSubscriptionID" 
    }
    Catch {
        $_.Exception.Message
    }
}
Process {
    $CheckAzureRG = (Get-AzResourceGroup -Name $NewResourceGroupName -ErrorAction SilentlyContinue)

    IF ($CheckAzureRG -ne $null) {
        Write-Host -ForegroundColor Yellow "Resource Group: $NewResourceGroupName already exists"
    }
    Else {
        New-AzResourceGroup -Name $NewResourceGroupName -Location "eastus" -Tag @{Description=$Description; System=$System; Environment=$Environment} 
        IF ((Get-AzResourceGroup -Name $NewResourceGroupName) -ne $null) {
            Write-Host -ForegroundColor Cyan "Resource Group: $NewResourceGroupName has been created."
        }
    }
    ForEach ($User in $AzUser){
        $CheckRoleAssignment = (Get-AzRoleAssignment -ResourceGroupName $NewResourceGroupName -SignInName $User `
        -RoleDefinitionName $AzAccessType -ErrorAction SilentlyContinue)
        IF ($CheckRoleAssignment.RoleDefinitionName -ne $AzAccessType -or $CheckRoleAssignment.RoleDefinitionName -eq $null) {
            Try {
                New-AzRoleAssignment -ResourceGroupName $NewResourceGroupName -SignInName $User -RoleDefinitionName $AzAccessType
                Write-Host -ForegroundColor Cyan "The Azure user: $User has been added to the Resource Group: $NewResourceGroupName with the $AzAccessType Role."
            }
            Catch {
                $_.Exception.Message
            }
        }
        Else {
            Write-Host -ForegroundColor Yellow "The Azure user:" $CheckRoleAssignment.SignInName `
            "is already in the Resource Group: $NewResourceGroupName with the Role:" $CheckRoleAssignment.RoleDefinitionName
        }
    }
}
END{}
}#END Function

