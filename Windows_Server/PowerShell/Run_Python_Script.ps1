CLS

# $Param1 = GUID Parameter for the contractor to terminate or extend
$Param1 = "321321321321321321"

# $Param2 = Date to be set
$Param2 = "2025-02-15"

Invoke-Expression -Command {python C:\Folder\Python-script.py $Param1 $Param2}

