import ctypes
import sys
import os
import requests
import logging
from datetime import datetime

# Setup logging
log_file = fr"C:\Logs\Tableau_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.log"
logging.basicConfig(filename=log_file, level=logging.DEBUG, format='%(asctime)s %(message)s')
logging.info("Script started")

# Admin check
def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

if not is_admin():
    logging.info("Restarting with admin privileges...")
    script = os.path.abspath(sys.argv[0])
    params = " ".join([f'"{arg}"' for arg in sys.argv[1:]])
    ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, f'"{script}" {params}', None, 1)
    sys.exit()

# Example values (replace as needed)
TableauServerName = "your-tableau-server-name"
Environment = "Development"
TableauServerAPI_Version = "3.18"
Tableau_Site_ID = "your_site_id"

# Function to get Tableau API Token
def get_tableau_api_token(tableau_api_username, tableau_api_password, tableau_server_name, environment, tableau_server_api_version):
        return tableau_api_token

# Get Tableau Groups function
def get_tableau_groups(token, site_id, server_name, environment, api_version):
    try:
        headers = {
            "Content-Type": "application/xml",
            "X-Tableau-Auth": token
        }

        url = f"https://{server_name}.{environment}.Company-Domain.com/api/{api_version}/sites/{site_id}/groups"

        response = requests.get(url, headers=headers)

        response.raise_for_status()
        groups_info = response.json().get("tsResponse", {}).get("groups", {}).get("group", [])
        
        logging.info(f"Groups retrieved: {groups_info}")
        return groups_info

    except requests.exceptions.RequestException as e:
        logging.error(f"Request failed: {e}")
        sys.exit(1)

# Run the function
token = get_tableau_api_token()
groups = get_tableau_groups(
    token,
    Tableau_Site_ID,
    TableauServerName,
    Environment,
    TableauServerAPI_Version
)

# Optional print for visibility
# print(groups)
