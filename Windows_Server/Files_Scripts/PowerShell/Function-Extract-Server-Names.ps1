CLS

$FilePath = "C:\temp\Test_File1.txt"
$RegEX = ('([\w?]{1,})(\=)([^;]*)')
$Group = 2

Function Get-RegEX_Values {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [System.IO.FileInfo]$FilePath,
    [Parameter()]
    [String]$RegEX,
    [Parameter()]
    [int]$Group
    )
Begin{
    $FormatEnumerationLimit="0"
}
Process {
    # This will pull all of the Data from the filepath.
    $Content = (Get-Content -Path $FilePath)
    # This will pull all of the 'LINE' Results from the $Content.
    $Results = $Content | Select-String $RegEX -AllMatches
    # This will pull all of the 'LINE' Results from the $Content, and show them as individual objects.
    $All_Matches = $Results.Matches
    # This will run a ForEach loop, looping through all of the individual objects, 
    # while pulling the value of group $Group or the RegEX out of the individual object
    # and displaying the data in the form of a variable $Value
    ForEach ($Match in $All_Matches) {
        #$Value = $Match.Groups[$Group].Value  ################################################################
        $Value = $Match.Value
        $Value
    }
}
END {}
}

Get-RegEX_Values -FilePath $FilePath -RegEX $RegEX -Group $Group
