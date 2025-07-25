import requests
import xml.etree.ElementTree as ET
import logging
from datetime import datetime

# Setup logging
log_file = fr"C:\Logs\Tableau_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.log"
logging.basicConfig(filename=log_file, level=logging.DEBUG, format='%(asctime)s %(message)s')
logging.info("Script started")

# Function to check if running as admin (in Windows)
def is_admin():
    import ctypes
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

if not is_admin():
    logging.info("Restarting with admin privileges...")
    import sys
    import os
    script = os.path.abspath(sys.argv[0])
    params = " ".join([f'"{arg}"' for arg in sys.argv[1:]])
    ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, f'"{script}" {params}', None, 1)
    sys.exit()

# Example values (replace with actual logic for credentials)
Tableau_API_UserName = "CyberArk_UserName"
Tableau_API_Password = "CyberArk_Password"
TableauServerName = "Your-Company-Tableau-Server-Name"
Environment = "Development"
TableauServerAPI_Version = "3.18"

# Function to get Tableau API Token
def get_tableau_api_token(username, password, server_name, environment, api_version):
    try:
        headers = {
            "Content-Type": "application/xml"
        }
        
        body = f"""
        <tsRequest>
            <credentials name="{username}" password="{password}">
                <site contentUrl="" />
            </credentials>
        </tsRequest>
        """

        url = f"https://{server_name}.{environment}.Company-Domain.com/api/{api_version}/auth/signin/"
        
        # Make the POST request to the Tableau server
        response = requests.post(url, headers=headers, data=body)
        response.raise_for_status()  # Will raise an exception for bad status codes
        
        # Parse the XML response to get the auth token
        response_xml = ET.ElementTree(ET.fromstring(response.text))
        root = response_xml.getroot()

        token = root.find('.//credentials/token').text
        logging.info(f"Tableau API Token: {token}")
        return token

    except requests.exceptions.RequestException as e:
        logging.error(f"Request failed: {e}")
        raise

# Get the Tableau API token
token = get_tableau_api_token(Tableau_API_UserName, Tableau_API_Password, TableauServerName, Environment, TableauServerAPI_Version)
logging.info(f"API Token: {token}")
