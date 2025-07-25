CLS

$CSV_Import_File = ("C:\List.csv")

Function Set-Corp_ServiceAccount_PW {
    [Cmdletbinding()]
    Param(
    [Parameter()]
    [System.IO.FileInfo]$CSV_Import_File
    )
Begin {
    $FormatEnumerationLimit="0"
    $CSV_Data = Import-Csv -Path $CSV_Import_File
    $CSVRowNumber = $CSV_Data.count
    $Values = @(0..$CSVRowNumber)
}
Process {
    ForEach ($V in $Values) {
        IF ($CSV_Data[$v] -ne $null) {
            $ServiceAccount = $CSV_Data[$V].ServiceAccount
            $SA_SamAccountName = ((Get-ADUser $ServiceAccount | Select SamAccountName).SamAccountName)
            Set-ADAccountPassword -Identity $SA_SamAccountName -NewPassword (ConvertTo-SecureString $ServiceAccount.PassWord -AsPlainText -Force) -Reset -Confirm:$false -Verbose
        }
    }
}
END {}
}
