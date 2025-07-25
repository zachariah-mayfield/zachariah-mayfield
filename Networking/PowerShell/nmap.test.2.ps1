CLS

$PingTarget = "192.168.1.1"


If (Test-Connection $PingTarget -quiet) {
            Write-host 'The Device is still Reachable!'
            Write-Host The PingTarget was $PingTarget
            # My Custom NMAP Port Scan to scan all ports for 1 IP Address
            # -sV Probe open ports to determine service/version info
            # -p Specify ports, e.g. -p80,443 or -p- or -p 1-65535
            # -sS TCP SYN scan
            # -T 0-5 Set timing template - higher is faster, but (less accurate)
            cmd.exe /c "nmap -p 1-8100 -sV -sS -T5 $PingTarget"
            
        } #End If #1 