CLS
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
                Write-Host "MacAddress$Adapter" ,$MacAddress
                $MacHash.add("MacAddress$Adapter" ,$MacAddress)
                }
                }
            $Interface += .5
        }
		
		
		CLS

$NetWorkInfo=@(IPConfig -all | Where {
 $_ -AND $_ -NotMatch ("Host Name") -AND
 $_ -NotMatch ("Node Type") -AND 
 $_ -NotMatch ("IP Routing Enabled") -AND 
 $_ -NotMatch ("WINS Proxy Enabled") -AND 
 $_ -NotMatch ("DNS Suffix Search List") -AND 
 $_ -NotMatch ("Media State") -AND 
 $_ -NotMatch ("Description") -AND 
 $_ -NotMatch ("DHCP Enabled") -AND 
 $_ -NotMatch ("Autoconfiguration Enabled") -AND 
 $_ -NotMatch ("Connection-specific DNS Suffix") -AND 
 $_ -NotMatch ("Autoconfiguration Enabled") -AND 
 $_ -NotMatch ("Link-local IPv6 Address") -AND 
 $_ -NotMatch ("IPv4 Address") -AND 
 $_ -NotMatch ("Subnet Mask") -AND 
 $_ -NotMatch ("Lease Obtained") -AND 
 $_ -NotMatch ("Lease Expires") -AND 
 $_ -NotMatch ("Default Gateway") -AND 
 $_ -NotMatch ("DHCP Server") -AND 
 $_ -NotMatch ("DHCPv6 IAID") -AND 
 $_ -NotMatch ("DHCPv6 Client DUID") -AND 
 $_ -NotMatch ("DNS Servers") -AND 
 $_ -NotMatch ("Primary WINS Server") -AND 
 $_ -NotMatch ("Secondary WINS Server") -AND 
 $_ -NotMatch ("NetBIOS over Tcpip") -AND  
 $_ -NotMatch ("Primary Dns Suffix")
 } | Select -skip 2)

 $NetWorkInfo
