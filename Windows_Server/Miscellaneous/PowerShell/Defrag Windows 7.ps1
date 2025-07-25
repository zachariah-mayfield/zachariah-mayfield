CLS


# Defrag the machine on a Windows 7 machine use the below:

$ComputerList = $env:COMPUTERNAME

ForEach ($Computer in $ComputerList )
{
    $Volume = Get-WmiObject -Class Win32_Volume -ComputerName $Computer -Filter "DriveLetter = 'c:'"
    $res = $Volume.Defrag($false)

    IF ($res.ReturnValue -eq 0)
    {
        Write-Host "Defrag succeeded."
    } Else {
        Write-Host "Defrag failed Result code: " $res.ReturnValue
    }
}




# Defragment the drive on a windows 10 machine use the below command. 
##### Optimize-Volume -DriveLetter C -Defrag –Verbose