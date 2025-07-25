# chmod +x CyberArk-CSR.sh - This will enable the bash .sh file to be executed.

# This will create the CSR file.
openssl req -new -out CyberArk-CSR.csr -key CyberArk-key_name.key -config CyberArk-CSR-INI.ini
