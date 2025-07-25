Clear-History

$CSV_Path = "D:\xxxx.csv"

$CSV_Data = Import-Csv -Path $CSV_Path

$CSVRowNumber = $CSV_Data.count

$Values = @(1..$CSVRowNumber)

ForEach ($V in $Values) {
    IF ($null -ne $CSV_Data[$v]) {
        $AppPool = $CSV_Data[$V].AppPool
        $Sites = $CSV_Data[$V].Sites
        $Folders = $CSV_Data[$V].Folders
    }
      
    $New_WebApplication = $Sites
    $WebApplication_Parent = "xxx.xxx"
    $New_WebApplicationPool = $AppPool
    $New_WebApplicationPool_PSPath = "D:\xxx.xxx\$Sites"
    $New_WebApplicationPool_PSParentPath = "D:\Webapps\xxx.xxx.xxx\"
    $UserName = "xxx"
    $PassWord = "xxxx"




    # Create new folder under the correct Site 
    IF ((Test-Path -Path $New_WebApplicationPool_PSPath) -eq $false) {
        New-Item -Path $New_WebApplicationPool_PSParentPath -Name $New_WebApplication -ItemType "Directory"
    }

    # Creates a new WebApplication
    New-WebApplication -Name $New_WebApplication -Site  $WebApplication_Parent -ApplicationPool $New_WebApplicationPool -PhysicalPath $New_WebApplicationPool_PSPath
}
