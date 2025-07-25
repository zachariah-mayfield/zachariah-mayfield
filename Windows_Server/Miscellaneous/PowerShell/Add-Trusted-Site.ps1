CLS
# The line below - sets the current working Directory.
Set-Location "HKCU:\"
# The line below - sets the current working Directory.
set-location "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" 
# The line below - sets the current working Directory.
set-location "ZoneMap\Domains" 
# The line below - creates a new item in the current working directory.
new-item "xxxxx.com" -Force -ErrorAction SilentlyContinue
# The line below - sets the current working Directory.
set-location "xxxxx.com" 
# The line below - creates a new item in the current working directory.
new-item "www" -Force -ErrorAction SilentlyContinue
# The line below - sets the current working Directory.
set-location "www" 
# The line below - creates a new item property in the current working directory.
new-itemproperty . -Name https -Value 2 -Type DWORD -Force -ErrorAction SilentlyContinue
