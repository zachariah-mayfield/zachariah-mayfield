# Script for POST KEVLAR Validation using the Cisco Meraki API
# Author: Minh Trinh


####################
# Modules Required #
####################
import requests, json, sys, re


###################
# Class Functions #
###################


# Get the request - GET Request
# Input: (Endpoint URL, Request Header)
# Output: JSON Response as a dictionary
def get_request(end_point, request_header):
    URL = HOST + end_point
    request = requests.get(URL, headers=request_header)
    # For Bad Requests, raise exception and print error output
    request.raise_for_status()
    #print('GET CODE: ' + str(request.status_code))
    json_response = json.loads(request.text)

    return json_response


# Get Organization ID
def get_organization_id(org_endpoint):
    organizations = get_request(org_endpoint, REQUEST_HEADERS)
    org_id = ''
    for org in organizations:
        org_name = 'Company-x'
        if org['name'] == org_name:
            org_id = org['id']
            break
        '''
        elif not org['name'] == org_name:
            print('There is no organization id for the name %s' % org_name)
        '''

    return org_id


# Get Network ID
def get_network_id(networks_endpoint, store_number):
    networks = get_request(networks_endpoint, REQUEST_HEADERS)
    network_id = ''
    for network in networks:
        if network['name'] == store_number:
            network_id = network['id']
            break
        '''
        elif not network['name'] == store_number:
            print('There is no network id for the store %s' % store_number)
        '''

    return network_id


# Get Device Serial
def get_device_serial(devices_endpoint):
    devices = get_request(devices_endpoint, REQUEST_HEADERS)
    device_serial_dict = {}
    for device in devices:
        device_serial_dict[device['name']] = device['serial']

    return device_serial_dict


# Get Device Uplink Status
def get_device_uplink_status(device_uplink_endpoint):
    devices = get_request(device_uplink_endpoint, REQUEST_HEADERS)
    for device_status in devices:
        print('Interface       : %s' % device_status.get('interface', None))
        print('IP Address      : %s' % device_status.get('ip', None))
        print('Gateway         : %s' % device_status.get('gateway', None))
        print('Public IP       : %s' % device_status.get('publicIp', None))
        print('DNS             : %s' % device_status.get('dns', None))
        print('Switch Status   : %s ' % device_status.get('status', None))


#Get Switch Port Status
def get_switch_port_status(switch_port_endpoint, serial, port_number):
    switch_port_endpoint = switch_port_endpoint % (serial, port_number)
    switch_port = get_request(switch_port_endpoint, REQUEST_HEADERS)
    print('Port %s Enabled : %s' % (port_number, switch_port.get('enabled', None)))


####################
# Global Variables #
####################
HOST = 'https://dashboard.meraki.com/api/v0/' # Meraki HOST API URL
ORG_ENDPOINT = 'organizations'
STORE_NUMBER = ''

# Regular expression used for commandline error handling: store number must be 5 digits
REST_REGEX = re.compile(r'^\d{5}$')

# Temporary Location of Credentials
API_KEY = 'API_KEY'

# Request Header Information
MIME_TYPE = 'application/json'
REQUEST_HEADERS = {'X-Cisco-Meraki-API-Key': API_KEY, 'content-type': MIME_TYPE}


#######################
# Main Function Calls #
#######################

if len(sys.argv) is not 2:
    sys.exit('ERROR: Invalid Parameters - Usage: MerakiHealthCheck.py \"StoreNumber\"')
else:
    STORE_NUMBER = sys.argv[1]
    if not REST_REGEX.search(STORE_NUMBER):
        sys.exit('ERROR: store Number is not 5 Digits')

print('**********************************************')
print('* Meraki Switch Status for store: %s *' % STORE_NUMBER)
print('**********************************************\n')

ORG_ID = get_organization_id(ORG_ENDPOINT)
NETWORKS_ENDPOINT = 'organizations/%s/networks' % ORG_ID
NETWORK_ID = get_network_id(NETWORKS_ENDPOINT, STORE_NUMBER)
DEVICES_ENDPOINT = 'networks/%s/devices' % NETWORK_ID
DEVICE_SERIAL_DICT = get_device_serial(DEVICES_ENDPOINT)
SWITCH_PORT_ENDPOINT = 'devices/%s/switchPorts/%s'

for device, serial in DEVICE_SERIAL_DICT.items():
    DEVICE_UPLINK_ENDPOINT = 'networks/%s/devices/%s/uplink' % (NETWORK_ID, serial)
    print('%s \n------------------------------------' % device)
    get_device_uplink_status(DEVICE_UPLINK_ENDPOINT)
    get_switch_port_status(SWITCH_PORT_ENDPOINT, serial, 23)
    get_switch_port_status(SWITCH_PORT_ENDPOINT, serial, 24)
    print('\n')


