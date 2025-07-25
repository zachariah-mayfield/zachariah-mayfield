CLS

Function Get-AllKeys {

$ComputerName = $env:COMPUTERNAME

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



        $Obj = New-Object -TypeName PSObject
        $Obj | Add-Member -MemberType NoteProperty -Name "ComputerName:"                   -Value ($ComputerName)
        $Obj | Add-Member -MemberType NoteProperty -Name "Raw Key Big Endian1:"            -Value ($hexadecimal1)
        $Obj | Add-Member -MemberType NoteProperty -Name "Product Key1:"                   -Value ($digitalproductid)
        $Obj | Add-Member -MemberType NoteProperty -Name "Raw Key Big Endian2:"            -Value ($hexadecimal2)
        $Obj | Add-Member -MemberType NoteProperty -Name "Product Key2:"                   -Value ($digitalproductid4)
        $Obj | Add-Member -MemberType NoteProperty -Name "Current Windows Product ID Key:" -Value ($CurrentWinKey)

        Write-Output $Obj
}

Get-AllKeys
