CLS
Function Get-WorkerComputerInfo {
        Param($Computername)
        $MacHash=@{}
        $Server=Hostname
        $GetMac=getmac /nh /fo csv /s $Server
        $MacAddresses=$GetMac -split ","
        $Interface = 2
        $MacAddresses | 
        ForEach {
            if ($MacAddresses -ne "") {
                $MacAddresses=$_
            if ($MacAddresses.SubString(3,1) -eq "-") {
                $MacAddress = $MacAddresses.Replace("""","")
                $Adapter = $Interface/2                   
                #Write-Host $MacAddress
                $MacHash.add("$MacAddress","$Adapter")
                }
                }
            $Interface += .5
        }
        $ComputerName = Hostname
        # HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion
# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DefaultProductKey
# Getting Windows Product Key 1
# create table to convert in base 24  
$map="BCDFGHJKMPQRTVWXY2346789"  
# Read registry Key  
$value = (get-itemproperty "HKLM:\\SOFTWARE\Microsoft\Windows NT\CurrentVersion").digitalproductid[0x34..0x42]  
# Convert in Hexa to show you the Raw Key  
$hexadecimal1 = ""  
$value | foreach {  
  $hexadecimal1 = $_.ToString("X2") + $hexadecimal1
}  
# find the Product Key  
$digitalproductid = ""  
for ($i = 24; $i -ge 0; $i--) {  
  $r = 0  
  for ($j = 14; $j -ge 0; $j--) {  
    $r = ($r * 256) -bxor $value[$j]  
    $value[$j] = [math]::Floor([double]($r/24))  
    $r = $r % 24  
  }  
  $digitalproductid = $map[$r] + $digitalproductid   
  if (($i % 5) -eq 0 -and $i -ne 0) {  
    $digitalproductid = "-" + $digitalproductid  
  }  
}
# Getting Windows Product Key 2
# create table to convert in base 24  
$map="BCDFGHJKMPQRTVWXY2346789"  
# Read registry Key  
$value = (get-itemproperty "HKLM:\\SOFTWARE\Microsoft\Windows NT\CurrentVersion").digitalproductid4[0x34..0x42]  
# Convert in Hexa to show you the Raw Key  
$hexadecimal2 = ""  
$value | foreach {  
  $hexadecimal2 = $_.ToString("X2") + $hexadecimal2  
}  
# find the Product Key  
$digitalproductid4 = ""  
for ($i = 24; $i -ge 0; $i--) {  
  $r = 0  
  for ($j = 14; $j -ge 0; $j--) {  
    $r = ($r * 256) -bxor $value[$j]  
    $value[$j] = [math]::Floor([double]($r/24))  
    $r = $r % 24  
  }  
  $digitalproductid4 = $map[$r] + $digitalproductid4   
  if (($i % 5) -eq 0 -and $i -ne 0) {  
    $digitalproductid4 = "-" + $digitalproductid4  
  }  
}  

# Read registry Key  
$CurrentWinKey = (get-itemproperty "HKLM:\\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductId  

$hexadecimal1 = (& { for ($i = 0;$i -lt $hexadecimal1.length;$i += 5){
                        $hexadecimal1.substring($i,5)
                   }
                 }) -join '-'

$hexadecimal2 = (& { for ($i = 0;$i -lt $hexadecimal2.length;$i += 5){
                        $hexadecimal2.substring($i,5)
                   }
                 }) -join '-'

        $OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computername
        $BIOS = Get-WmiObject -Class Win32_BIOS -ComputerName $Computername
        $Disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'" -ComputerName $Computername
        $SystemInfo = Get-WmiObject -class Win32_ComputerSystem -ComputerName $Computername
        $NetworkInfo = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName $Computername
        $DHCPLeaseObtained = $NetworkInfo.DHCPLeaseObtained.Substring(0,14)
        $DHCPLeaseObtained = [datetime]::ParseExact($DHCPLeaseObtained,'yyyyMMddhhmmss',$null)
        $DHCPLeaseExpires = $NetworkInfo.DHCPLeaseExpires.Substring(0,14)
        $DHCPLeaseExpires = [datetime]::ParseExact($DHCPLeaseExpires,'yyyyMMddhhmmss',$null)
        
        $Obj = New-Object -TypeName PSObject
        $Obj | Add-Member -MemberType NoteProperty -Name 'ComputerName:'                   -Value ($ComputerName)
        $Obj | Add-Member -MemberType NoteProperty -Name 'OS Version:'                     -Value ($OS.Caption)
        $Obj | Add-Member -MemberType NoteProperty -Name 'Service Pack Version:'           -Value ($OS.Version)
        $Obj | Add-Member -MemberType NoteProperty -Name 'OS Build #:'                     -Value ($OS.BuildNumber)
        $Obj | Add-Member -MemberType NoteProperty -Name 'System Type:'                    -Value ($SystemInfo.SystemType)
        $Obj | Add-Member -MemberType NoteProperty -Name 'System Manufacturer:'            -Value ($SystemInfo.Manufacturer)
        $Obj | Add-Member -MemberType NoteProperty -Name 'System Model:'                   -Value ($SystemInfo.Model)
        $Obj | Add-Member -MemberType NoteProperty -Name 'User:'                           -Value ($SystemInfo.UserName)
        $Obj | Add-Member -MemberType NoteProperty -Name 'Domain:'                         -Value ($SystemInfo.Domain)
        $Obj | Add-Member -MemberType NoteProperty -Name 'BIOS Serial #:'                  -Value ($BIOS.Serialnumber)
        $Obj | Add-Member -MemberType NoteProperty -Name 'System Free Space(GB):'          -Value ($Disk.FreeSpace /1GB)
        $Obj | Add-Member -MemberType NoteProperty -Name 'Total System Space(GB):'         -Value ($Disk.Size /1GB)
        $Obj | Add-Member -MemberType NoteProperty -Name 'Total Ram(GB):'                  -Value ($SystemInfo.TotalPhysicalMemory /1GB)
        $Obj | Add-Member -MemberType NoteProperty -Name 'Number Of Processor Cores:'      -Value ($SystemInfo.NumberOfLogicalProcessors)
        #$Obj | Add-Member -MemberType NoteProperty -Name 'MAC Address:' -Value ($NetworkInfo.MACAddress)
        $Obj | Add-Member -MemberType NoteProperty -Name 'IPv4 and IPv6 Address:'          -Value ($NetworkInfo.IPAddress)
        $Obj | Add-Member -MemberType NoteProperty -Name 'Subnet Mask:'                    -Value ($NetworkInfo.IPSubnet)
        $Obj | Add-Member -MemberType NoteProperty -Name 'Default Gateway:'                -Value ($NetworkInfo.DefaultIPGateway)
        $Obj | Add-Member -MemberType NoteProperty -Name 'Network Card Info:'              -Value ($NetworkInfo.Description)
        $Obj | Add-Member -MemberType NoteProperty -Name 'DHCP Lease Obtained:'            -Value ($DHCPLeaseObtained)
        $Obj | Add-Member -MemberType NoteProperty -Name 'DHCP Lease Expires:'             -Value ($DHCPLeaseExpires)
        $Obj | Add-Member -MemberType NoteProperty -Name 'DHCP Server:'                    -Value ($NetworkInfo.DHCPServer)
        $Obj | Add-Member -MemberType NoteProperty -Name 'DNS Domain:'                     -Value ($NetworkInfo.DNSDomain)
        $Obj | Add-Member -MemberType NoteProperty -Name 'DNS Suffixs:'                    -Value ($NetworkInfo.DNSDomainSuffixSearchOrder)
        $Obj | Add-Member -MemberType NoteProperty -Name 'DNS Servers:'                    -Value ($NetworkInfo.DNSServerSearchOrder)
        $Obj | Add-Member -MemberType NoteProperty -Name 'Primary WINS Server:'            -Value ($NetworkInfo.WINSPrimaryServer)
        $Obj | Add-Member -MemberType NoteProperty -Name 'Secondary WINS Server:'          -Value ($NetworkInfo.WINSSecondaryServer)
        $Obj | Add-Member -MemberType NoteProperty -Name 'MAC Address(s):'                 -Value ($MacHash)
        $Obj | Add-Member -MemberType NoteProperty -Name "Raw Key Big Endian1:"            -Value ($hexadecimal1)
        $Obj | Add-Member -MemberType NoteProperty -Name "Product Key1:"                   -Value ($digitalproductid)
        $Obj | Add-Member -MemberType NoteProperty -Name "Raw Key Big Endian2:"            -Value ($hexadecimal2)
        $Obj | Add-Member -MemberType NoteProperty -Name "Product Key2:"                   -Value ($digitalproductid4)
        $Obj | Add-Member -MemberType NoteProperty -Name "Current Windows Product ID Key:" -Value ($CurrentWinKey)

        Write-Output $Obj

}

Get-WorkerComputerInfo

