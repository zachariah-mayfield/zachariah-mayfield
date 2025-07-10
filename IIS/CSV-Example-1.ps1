CLS

$CSV_Path = "D:\xxxxServers.csv"

$CSV_Data = Import-Csv -Path $CSV_Path

$CSVRowNumber = $CSV_Data.count

$Values = @(0..$CSVRowNumber)

ForEach ($V in $Values) {
    IF ($CSV_Data[$v] -ne $null) {
        $AppPool = $CSV_Data[$V].AppPool
        $Sites = $CSV_Data[$V].Sites
        $Folders = $CSV_Data[$V].Folders
        

    }  
}
