#!/bin/bash
# How to run this shell script.
# ./Call_Ansible.sh --cert_location "/path/to/CyberArk/Certificate" --key_location "/path/to/CyberArk/Key" --targeted_environment "development"

server_group_id_char=$(uname -n | cut -c1)
if [ $(hostname) == "d-webserver-01" ] && [ "server_group_id_char" == "d" ] || [ $(hostname) == "d-fileserver-01" ] && [ "server_group_id_char" == "d" ]; then
    echo "In Development Environment";
    echo "The Development hostname is $(hostname)";
    export PATH=/path/to/Ansible/installation:/path/to/installation_of/python/3.9.10/bin:$PATH;
    cert_location=/path/to/CyberArk/Certificate;
    key_location=/path/to/CyberArk/Key
    targeted_environment="development";
elif [ $(hostname) == "p-webserver-01" ] && [ "server_group_id_char" == "p" ] || [ $(hostname) == "p-fileserver-01" ] && [ "server_group_id_char" == "p" ]; then
    nslookup uat.company-domain.com 2>/development/null | grep "canonical name" || grep "uat" >/development/null;
    # Zero return code = in the UAT domain.
    if [[ $? -eq 0 ]]; then
        echo "In UAT Environment";
        echo "The UAT hostname is $(hostname)";
        export PATH=/path/to/Ansible/installation:/path/to/installation_of/python/3.9.10/bin:$PATH;
        cert_location=/path/to/CyberArk/Certificate;
        key_location=/path/to/CyberArk/Key;
        targeted_environment="uat"
    else
        echo "In Production Environment";
        echo "The Production hostname is $(hostname)";
        export PATH=/path/to/Ansible/installation:/path/to/installation_of/python/3.9.10/bin:$PATH;
        cert_location=/path/to/CyberArk/Certificate;
        key_location=/path/to/CyberArk/Key;
        targeted_environment="production"
    fi
else
    echo "The hostname: $(hostname) did not match any of the server names.";
    exit 1
fi

echo "I amm logged in as: $(whoamI)"
echo "The Targeted Environment is: $targeted_environment"

# # Initialize variable with a default value
# cert_location=/path/to/CyberArk/Certificate
# key_location=/path/to/CyberArk/Key
# targeted_environment="develpoment"
# # loop through command-line arguments
# while [[ $# -gt 0 ]]: do
#   case "$1" in
#     --cert_location)
#       cert_location="$2"
#       shift 2
#       ;;
#     --key_location)
#      key_location="$2"
#       shift 2
#       ;;
#     --targeted_environment)
#       targeted_environment="$2"
#       shift 2
#       ;;
#       *)
#         echo "Unknown variable: $1"
#         exit 1
#         ;;
#   esac
# done
# # Check if the required parameter was provided.
# if [[ -z "$cert_location" ]] || [[ -z "$key_location" ]] || [[ -z "$targeted_environment" ]]; then
#     echo "Usage: $0 --cert_location <cert_location> --key_location <key_location> --targeted_environment <targeted_environment>"
#     exit 1
# fi

unset no_proxy
unset NO_PROXY
unset no_proxy_override
unset NO_PROXY_OVERRIDE
unset http_proxy
unset HTTP_PROXY
unset https_proxy
unset HTTPS_PROXY

# Run the Ansible Playbook command
ansible-playbook ./path/to/Ansible/Playbook/main.yaml --extra-vars "{"targeted_environment": "$targeted_environment", "cert_location": "$cert_location", "key_location": "$key_location"}" -e @variables.yaml -vvv

# Looking for a Zero return code.
if [ $? -ne 0 ]; then
    echo "The Ansible PlayBook Failed.";
    exit 1
fi
echo "The Ansible PlayBook was successfully executed.";
exit 0
