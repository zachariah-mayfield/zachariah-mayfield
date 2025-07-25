CLS

Function Get-AllDependentServices {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    )

Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}

Process {

######################################################################################################
######################################################################################################

$Global:FormatEnumerationLimit=-1

$DependentServices = Get-Service | Select DisplayName, ServicesDependedOn

$Output = @() 

ForEach ($Service in $DependentServices) {

        [System.Collections.IDictionary]$Properties = @{}

        $Properties = @{'Service Display Name'            =  $Service.DisplayName;
                        'Dependent Services'              =  $Service.ServicesDependedOn.ForEach('DisplayName')
                        'Number of Dependent Services'    =  $Service.ServicesDependedOn.Count;}#END $Properties
 
        $Output += New-Object -TypeName psobject -Property $Properties 

}

Write-Output $Output 

######################################################################################################
######################################################################################################

}# END Proccess
END {}
}# END Function Get-AllDependentServices

Get-AllDependentServices 