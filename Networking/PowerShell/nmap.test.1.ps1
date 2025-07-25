# Prints verbose output, runs stealth syn scan, T5 timing, OS and version detection + full port range scan. 
# nmap -v -p 1-65535 -sV -O -sS -T5 target

# My Custom NMAP Port Scan to scan all ports for 1 IP Address
# cmd.exe /c "nmap -sL $PingTarget -p1-65535 -T3"


$subnets = "10.0.0.0/23", "192.168.1.0/24"

#run nmap scan for each subnet
foreach ($subnet in $subnets) {
    $filename = ($subnet.substring(0,$subnet.length - 6))
    $nmapfile = ".\temp\" + $filename  + ".xml"
    cmd.exe /c "nmap -PS20,21,22,23,25,3389,80,443,8080 -PE -R  <your dns servers here> -p 20,21,22,23,25,3389,80,443,8080 -oX $nmapfile --no-stylesheet -A -v $subnet"
 
    $csvfilename = ".\results\" + $filename  + ".csv"
    .\parse-nmap.ps1 $nmapfile | select ipv4, status, hostname, fqdn #| Export-Csv $csvfilename
}