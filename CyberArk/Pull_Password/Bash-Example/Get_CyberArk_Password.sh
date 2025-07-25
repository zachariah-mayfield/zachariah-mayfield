#!/bin/bash

# CyberArk App ID
App_ID="your_App_ID"

# CyberArk Safe
Safe="your_Safe"

# CyberArk Object
Object="your_Object"

# CyberArk API Endpoint
CYBERARK_API_URL=$("https://your-cyberark-instance/api/Accounts?AppID=${App_ID}&Safe=${Safe}&Object=${Object}")

# CyberArk Account ID
ACCOUNT_ID="your_account_id"

# Certificate & Key
CERT_FILE="path/to/client.pem"
KEY_FILE="path/to/client.key"

# Version 3 Below: 
password=$(curl -q --silent --http1.1 \
    --cert $CERT_FILE \
    --key $KEY_FILE \
    -H 'Content-Type: application/json' \
    --get $CYBERARK_API_URL |
    grep -Po '"Content":"\K[^"]+')

# Version 2 Below: 
curl --silent -v -sS -k --insecure \
    --cert $CERT_FILE \
    --key $KEY_FILE \
    -H 'Content-Type: application/json' \
    --get $CYBERARK_API_URL |
    grep -Po '"Content":"\K[^"]+'

###################################################################################################################

# Version 1 below:

# Make API Call to Retrieve Password
response=$(curl -s --cert $CERT_FILE --key $KEY_FILE \
    -H "Content-Type: application/json" \
    -X GET "$CYBERARK_API_URL/$ACCOUNT_ID/Password/Retrieve")

# Extract the password (modify if the response format differs)
PASSWORD=$(echo $response | jq -r '.Content')

# Output the Password
echo "Retrieved Password: $PASSWORD"
