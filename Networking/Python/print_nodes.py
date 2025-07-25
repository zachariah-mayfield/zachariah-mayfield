import subprocess
import infoblox
import re
import argparse
import time
import sys
import string

domain = "XXX.com"
session_username = "xxx"
session_password = "xxx"
gridmaster = "xxx.com"  

iba_api = infoblox.Infoblox(gridmaster, session_username, session_password, '2.1', 'internal', 'default', False)
try:
    hosts = iba_api.get_host_by_ip('xxx.xxx.xxx.xxx')
    print(hosts)
except Exception as e:
    print(e)



def xxxxxChecker(xxxxxNumber):
    xxxxxNumber_REGEX = re.compile(r'^\d{5}$')
    # If the xxxxxNumber Parameter supplied is not == equal to 5 digits, this will raise an error.
    if not xxxxxNumber_REGEX.search(xxxxxNumber):
        raise argparse.ArgumentTypeError("ERROR: xxx Number is not 5 Digits.")
    else:
        print('xxxxx number passed the 5 digit check. . .')
        return xxxxxNumber

