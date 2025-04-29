CLS
#####
# THIS SCRIPT WILL ENABLE THE NIC CARD TO WAKE ON LAN.
#####
# This WMI class (MSPower_DeviceWakeEnable) can be used to enable the network card to wake the machine. 
# This technique may not work on all devices. This WMI class is unsuported.
# Might be able to use the (powercfg utility) to configure your network cards to wake up the computer.

# Use the Get-Credential cmdlet to retrieve the credentials for the remote computer.
# Store the returned credential object in the $cred variable.
$cred = Get-Credential Group\administrator

# Use WMI and the Get-WmiObject cmdlet to look for a network card on the remote server that is netenabled.
# This property of the Win32_NetworkAdapter class should return True only if the network interface is enabled.
gwmi win32_networkadapter -filter “netenabled = ‘true'” -cn dc1 -cred $cred

# Store the returned WMI object in a variable named $nic.
$nic= gwmi win32_networkadapter -filter “netenabled = ‘true'” -cn dc1 -cred $cred

# Query the MSPower_DeviceWakeEnable WMI class to see what type of date it returns.
gwmi MSPower_DeviceWakeEnable -Namespace root\wmi -cn dc1 -cred $cred


# Special characters need to be escaped before submitting to the Regex engine.
# Next use the escape method from the REGEX class.
# It will escape any invalid character in a string, and permit easy use of that string.
# store the returned object in a variable called $nicPower.
# Query the variable to ensure it contains the proper network adapter.
$nicPower = gwmi MSPower_DeviceWakeEnable -Namespace root\wmi -cn dc1 -cred $cred | 
where {$_.instancename -match [regex]::escape($nic.PNPDeviceID) }

# Change the value of the Enable property from False to True.
# Call the Put method from the base WMI object so that it will write the changes back to the WMI database. 
# The two command examples are shown here.
$nicPower.Enable = $true
$nicPower.psbase.Put()

# It takes a reboot for the changes to take effect.
# Use the Reboot method from the Win32_OperatingSystem WMI class.
(gwmi win32_operatingsystem -CN dc1 -cred $cred).reboot()

#####
# Below is the complete sequence of commands placed easily in a single script
# used to perform this configuration change.


$cred = Get-Credential Group\administrator

$nic= gwmi win32_networkadapter -filter “netenabled = ‘true'” -cn dc1 -cred $cred

$nicPower = gwmi MSPower_DeviceWakeEnable -Namespace root\wmi -cn dc1 -cred $cred |
where {$_.instancename -match [regex]::escape($nic.PNPDeviceID) }

$nicPower.Enable = $true

$nicPower.psbase.Put()

(gwmi win32_operatingsystem -CN dc1 -cred $cred).reboot()
#####
