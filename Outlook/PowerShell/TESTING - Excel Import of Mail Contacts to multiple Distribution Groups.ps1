CLS

$ParentPath = (Get-ChildItem -Path $MyInvocation.InvocationName).DirectoryName

$Path = "$ParentPath\Locations by Distribution Center.xlsx"

$Path2 = "$ParentPath\Distribution_DC_Trans.xlsx"

$Excel = Import-Excel -Path $Path

$Excel2 = Import-Excel -Path $Path2

# This is a PowerShell Dictionary of all of the group members email addresses, that will be added to the distroibution groups.
$Dictionary = @{} 

# This is a PowerShell Dictionary of all the Distribution group names to their abbreaveated name.
$Trans = @{}

# This is a loop for $Excel2 to loop through all of the $trans Dictionary items and set them to the coresponding abbreaveated names.   
ForEach ($Row2 in $Excel2) {

    IF ($Row2.'DC Abbreviation') {
        $Trans.item($Row2.'DC Abbreviation') = $Row2.'DC Name'
    }
}

# This is a loop for $Excel to loop through all of the $Emails in the $Dictionary items and set them to the coresponding $Row abbreaveated names.   
ForEach ($Row in $Excel) {
    
    $Emails = @()

    IF ($Row.'Business Consultant') {
        $BCEmail = (($Row.'Business Consultant') -replace " ",".") + "@Company-x.com"
        $Emails += ($BCEmail)
    }

    IF ($Row.'Restaurant Email') {
        $Emails += ($Row.'Restaurant Email')
    }

    IF ($Row.'Operator Email - Primary') {
        $Emails += ($Row.'Operator Email - Primary')
    }

    IF ($Row.'Distribution Center') {
        $Dictionary.Item($Row.'Distribution Center') += $Emails
    }
}

Write-Host -ForegroundColor Magenta $Trans.Item("xxxx")

Write-Host -ForegroundColor Green $Dictionary.Item("xxxx")

# This will loop through all of the Distribution Group Names.
ForEach ($DistributionGroup in $Dictionary.Keys) {
    
    # These are all of the translated Distribution Group names from the Abbreviated list.
    $DistroGroup = ($Trans.item($DistributionGroup))

    Write-Host -ForegroundColor Yellow ("$DistroGroup")
    
    # These are all of the group members from the excel list.
    $GroupMember = $Dictionary.Item($DistributionGroup)
    
    Write-Host -ForegroundColor Cyan ("$GroupMember")

}