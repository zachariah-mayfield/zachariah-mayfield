Clear-Host

$Namespace = "xxxxx"
$Class = "Test"

$wmi= [wmiclass]"root\cimv2:__Namespace" 
$newNamespace = $wmi.createInstance() 
$newNamespace.name = $Namespace 
$newNamespace.put() 

$_subClass = New-Object System.Management.ManagementClass ("root\cimv2\$Namespace", [String]::Empty, $null); 
$_subClass["__CLASS"] = $Class; 
$_subClass.Qualifiers.Add("Static", $true)
$_subClass.Properties.Add("Name", [System.Management.CimType]::String, $false)
$_subClass.Properties["Name"].Qualifiers.Add("Key", $true) #A key qualifier must be defined to execute 'Put' command.
$_subClass.Properties.Add("Upload", [System.Management.CimType]::Real64, $false)
$_subClass.Properties.Add("Download", [System.Management.CimType]::Real64, $false)
$_subClass.Properties.Add("SpeedTestFail", [System.Management.CimType]::Real64, $false)
$_subClass.Put()

$keyvalue = "Bandwidth"

$WMIURL = 'root\cimv2\'+$Namespace+':'+$Class
$PushDataToWMI = ([wmiclass]$WMIURL).CreateInstance()
$PushDataToWMI.Name = $keyvalue
$PushDataToWMI.Upload = $_avgUpload
$PushDataToWMI.Download = $_avgDownload
$PushDataToWMI.SpeedTestFail = $_stFailureIndicator
$PushDataToWMI.Put()
