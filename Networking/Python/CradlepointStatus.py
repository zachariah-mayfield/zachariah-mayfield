import urllib.request
import urllib.error
import sys
import argparse
import os
import json
import subprocess
import requests



def printresponse(resp):
    print('Response code:>>>> %s <<<<' % resp.status_code)
    if hasattr(resp, 'reason'):
        print('Response reason:>>>> %s <<<<' % resp.reason)
    print('Response headers:>>>> %s <<<<' % resp.headers)
    print('Response body:>>>> %s <<<<' % resp.text)



def makeurlcall(requrl, reqmethod='GET', reqheaders=None, reqdata=None, reqparam=None, reqauth=None):
    response = None

    try:
        response = requests.request(method=str.upper(reqmethod), url=requrl, headers=reqheaders, data=reqdata, params=reqparam, auth=reqauth)
        response.raise_for_status()
    except requests.HTTPError as e:
        if hasattr(e, 'status_code'):
            if e.status_code != 401:
                if e.status_code not in [200, 201]:
                    print('Failure reported.  Check output for troubleshooting steps.')
                    printresponse(e)
                    return None
                else:
                    print('Request was successful.')
                    printresponse(e)
            else:
                print('>>>> 401 Unauthorized error. <<<<')
                printresponse(e)
                return None
        else:
            print('>>>> No status code returned. <<<<')
            print(e)
    except requests.exceptions.RequestException as err:
        print('>>>> Non HTTP error occurred <<<<')
        print(err)
    except:
        print('>>>> Unexpected Error <<<<')
        print(sys.exc_info())

    return response


def run_win_cmd(cmd):
    result = []
    process = subprocess.Popen(cmd,
                               shell=True,
                               stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE)
    result = process.stdout.readlines()
    if result == []:
        error = process.stderr.readlines()
        print(sys.stderr,error)
        return None
    else:
        return result[0].strip().decode('utf-8')



def main():
    parser = argparse.ArgumentParser(description='Checks on Cradlepoint router status.')
    parser.add_argument('xxxx', type=str, default=None, help='xxxxx number that you want to check the status of.')

    args = parser.parse_args()

    # Start Function Method Calls
    print('***************************************')
    print('* Cradlepoint Device Status for %s *' % args.xxxx)
    print('***************************************')
    print()

    # Cradlepoint API Authentication Key Header
    authJson = {
        'X-CP-API-ID': 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
        'X-CP-API-KEY': 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
        'X-ECM-API-ID': 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
        'X-ECM-API-KEY': 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
        'Content-Type': 'application/json',
        "Accept": "application/json"
    }

    # Cradlepoint API URL
    url = 'https://cradlepointecm.com/api/v2/'
    urlreq = 'routers/?fields=name,state,full_product_name,ipv4_address,mac,device_type&offset=100&limit=100'
    data = None
    routers = []

    query = url + urlreq

    # API returns 100 items at a time.  Therefore you must iterate through the list.
    while query is not None:
        try:
            result = makeurlcall(query, reqmethod='GET', reqheaders=authJson)
            alert_data = result.json()
            for cnt in range(0, len(alert_data['data'])):
                routers.append(alert_data['data'][cnt])
            meta = alert_data['meta']
            query = meta['next']
        except:
            print('>>>> Unexpected Error <<<<', file=sys.stderr)
            print(sys.exc_info())
            exit(1)

    for router in routers:
        if args.xxxx in router['name']:
            print('%s \n------------------------------------' % router['name'])
            print('Product            : %s' % router['full_product_name'])
            print('Device Type        : %s' % router['device_type'])
            print('IP Address         : %s' % router['ipv4_address'])
            print('MAC Address        : %s' % router['mac'])
            print('Cradlepoint Status : %s' % router['state'])
            print('\n')
    exit(0)


if '__main__' == __name__:
    main()
