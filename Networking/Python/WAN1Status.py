# import libraries required by LogicMonitor API
import requests, json, hashlib, base64, time, datetime, hmac

# import script specific libraries
import sys, os, logging, argparse, json, csv, re
from os.path import basename
from pprint import pprint

# Global Variables
company = 'company'
accessID = 'accessID'
accessKey = 'accessKey'


# Create signature for LogicMonitor API authentication
def getSignature(httpVerb, data, resourcePath):
    epoch = str(int(time.time() * 1000))
    requestVars = httpVerb + epoch + data + resourcePath
    hmc = hmac.new(accessKey.encode(), msg=requestVars.encode(), digestmod=hashlib.sha256).hexdigest()
    signature = base64.b64encode(hmc.encode())
    auth = 'LMv1 ' + accessID + ':' + signature.decode() + ':' + epoch

    return auth


# Get the device id for the store router
def getRTRDeviceID(storeNumber):
    httpVerb = 'GET'
    resourcePath = '/device/devices'
    data = ''
    queryParams = '?filter=name:' + str(storeNumber) + '.rtr.Company-x.com&fields=id,total'

    url = 'https://' + company + '.logicmonitor.com/santaba/rest' + resourcePath + queryParams
    auth = getSignature(httpVerb, data, resourcePath)
    headers = {'Content-Type': 'application/json', 'Authorization': auth}

    try:
        response = requests.get(url, data=data, headers=headers)
        loadsResponse = json.loads(response.content)['data']['items']
        dumpID = json.dumps(loadsResponse)
        rtrID = json.loads(dumpID)[0]['id']
        return rtrID

    except:
        print("Error getting router device id.", file=sys.stderr)
        return 0


# Get datasource id
def getDatasourceID(routerID):
    httpVerb = 'GET'
    resourcePath = '/device/devices/' + str(routerID) + '/devicedatasources'
    data = ''
    queryParams = '?filter=dataSourceName:snmp64_If-'

    url = 'https://' + company + '.logicmonitor.com/santaba/rest' + resourcePath + queryParams
    auth = getSignature(httpVerb, data, resourcePath)
    headers = {'Content-Type': 'application/json', 'Authorization': auth}

    try:
        response = requests.get(url, data=data, headers=headers)
        loadsResponse = json.loads(response.content)['data']['items']
        dumpID = json.dumps(loadsResponse)
        dsID = json.loads(dumpID)[0]['id']
        return dsID

    except:
        print("Error getting data source id.", file=sys.stderr)
        return 0


# Get instance id
def getInstanceID(routerID, datasourceID):
    httpVerb = 'GET'
    resourcePath = '/device/devices/' + str(routerID) + '/devicedatasources/' + str(datasourceID) + '/instances'
    data = ''
    queryParams = '?filter=displayName:wan1'

    url = 'https://' + company + '.logicmonitor.com/santaba/rest' + resourcePath + queryParams
    auth = getSignature(httpVerb, data, resourcePath)
    headers = {'Content-Type': 'application/json', 'Authorization': auth}

    try:
        response = requests.get(url, data=data, headers=headers)
        loadsResponse = json.loads(response.content)['data']['items']
        dumpID = json.dumps(loadsResponse)
        instanceID = json.loads(dumpID)[0]['id']
        return instanceID

    except:
        print("Error getting instance id.", file=sys.stderr)
        return 0


# Get status data
def getInstanceData(routerID, dataSourceID, instanceID):
    httpVerb = 'GET'
    resourcePath = '/device/devices/' + str(routerID) + '/devicedatasources/' + str(dataSourceID) + '/instances/' + str(
        instanceID) + '/data'
    data = ''
    queryParams = ''

    url = 'https://' + company + '.logicmonitor.com/santaba/rest' + resourcePath + queryParams
    auth = getSignature(httpVerb, data, resourcePath)
    headers = {'Content-Type': 'application/json', 'Authorization': auth}

    try:
        response = requests.get(url, data=data, headers=headers)
        datapoints = (json.loads(response.content)['data']['dataPoints'])
        loadValues = json.loads(response.content)['data']['values'][0]
        statusIndex = datapoints.index("Status")
        wan1Status = loadValues[statusIndex]

        if (wan1Status == "No Data"):
            return 0
        return wan1Status

    except:
        print("Error getting instance data.", file=sys.stderr)
        return 0



# Main Function Calls

# Check script parameters are correct
REST_REGEX = re.compile(r'^\d{5}$')
if len(sys.argv) is not 2:
    sys.exit('ERROR: Invalid Parameters - Usage: wan1Status.py \"StoreNumber\"')
else:
    if not REST_REGEX.search(sys.argv[1]):
        sys.exit('ERROR: store Number is not 5 Digits')

# Assign Store Number
storeNumber = sys.argv[1]

# Start Function Method Calls
print('*****************************************')
print('* Fortinet Router WAN1 Status for %s *' % storeNumber)
print('*****************************************')

## To begin process, pass in 5 digit store number
routerID = getRTRDeviceID(storeNumber)
datasourceID = getDatasourceID(routerID)
instanceID = getInstanceID(routerID, datasourceID)
## If wan1Status = 1 it is up, else it is down
wan1Status = getInstanceData(routerID, datasourceID, instanceID)

if int(wan1Status) == 1:
    print('Fortinet WAN1 Status: online')
    exit(0)
else:
    print('Fortinet WAN1 Status: offline', file=sys.stderr)
    exit(1)
