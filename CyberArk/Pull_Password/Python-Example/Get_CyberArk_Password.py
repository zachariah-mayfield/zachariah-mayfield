#!/usr/bin/env python3

#region import
import argparse
import requests
import warnings
#endregion import

# Argument Parser
arg_parser=argparse.ArgumentParser()
arg_parser.add_argument(--CyberArk_AppID, help="This is the App ID in CyberArk")
arg_parser.add_argument(--CyberArk_Safe, help="This is the Safe in CyberArk")
arg_parser.add_argument(--CyberArk_Object, help="This is the Account Name or Object in CyberArk")
args=arg_parser.parse_args()

# CyberArk App ID, Safe, Object
CyberArk_AppID = args.CyberArk_AppID
CyberArk_Safe = args.CyberArk_Safe
CyberArk_Object = args.CyberArk_Object

# Certificate and Key Location
Cert_and_Key_Location = ('./path/to/client.pem', './path/to/client.key')

# Function
def Get_CyberArk_Object(Cert_and_Key_Location, CyberArk_AppID, CyberArk_Safe, CyberArk_Object):
  # This will supress any warnings.
  warnings.filterwarnings('ignore')
  #region Variables / Arguments / Parameters
  params = {
    'AppID': CyberArk_AppID,
    'Safe': CyberArk_Safe,
    'Object': CyberArk_Object
  }
  # Headers
  headers = {
    'Content-Type': 'Application/json'
  }
  # CyberArk API URL
  CyberArk_API_URL = 'https://your-cyberark-instance/api/Accounts'
  #endregion Variables / Arguments / Parameters
  #region API Request
  response = requests.get(CyberArk_API_URL, params=params, headers=headers, cert=cert, verify=False)  
  #endregion API Request
  CyberArk_Object = response.json()
  
  UserName = {'UserName' : CyberArk_Object['UserName']}
  Password = {'Password' : CyberArk_Object['Content']}
  
  return(UserName, Password)

CyberArk_Object = Get_CyberArk_Object(Cert_and_Key_Location, CyberArk_AppID, CyberArk_Safe, CyberArk_Object)

UserName = CyberArk_Object[0].get('UserName')
Password = CyberArk_Object[1].get('Password')

print(CyberArk_Object[0].get('UserName'))
print(CyberArk_Object[1].get('Password'))
