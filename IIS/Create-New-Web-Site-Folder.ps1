CLS

$CSV_Path = "D:\Webapps\xxx.csv"

$CSV_Data = Import-Csv -Path $CSV_Path

$CSVRowNumber = $CSV_Data.count

$Values = @(1..$CSVRowNumber)

ForEach ($V in $Values) {
    IF ($CSV_Data[$v] -ne $null) {
        $AppPool = $CSV_Data[$V].AppPool
        $Sites = $CSV_Data[$V].Sites
        $Folder = $CSV_Data[$V].Folders
    }
    
    $WebSite = "xx.xx.xx"
    $WebSitePath = "D:\Webapps\xx.xx.xx\"
    $WebSiteFolder = $Folder
    $WebSiteFolderPath = "D:\Webapps\xx.xx.xx\$Folder"
    $ApplicationPool = "DefaultAppPool"


    $UserName = "xx"
    $PassWord = "xx"

    IF ((Test-Path -Path $WebSiteFolderPath) -eq $false) {
        New-Item -Path "D:\Webapps\xx.xx.xx\" -Name $WebSiteFolder -ItemType "Directory"
    }

    New-WebVirtualDirectory -Name $WebSiteFolder -Site $WebSite -Application $ApplicationPool -PhysicalPath $WebSiteFolderPath -Force

}
