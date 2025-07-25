import ctypes
import sys
import os
import logging
import requests
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

# Example placeholder values (replace with your actual logic)
TableauServerName = "Your-Company-Tableau-Server-Name"
Environment = "Development"
TableauServerAPI_Version = "3.18"
Tableau_Site_Guest_Access_State = True

def get_tableau_api_token():
    return "your_tableau_auth_token"

def get_tableau_site_id():
    return "your_site_id"

def set_tableau_guest_access(token, site_id, guest_access_enabled, server_name, environment, api_version):
    try:
        headers = {
            "Content-Type": "application/xml",
            "X-Tableau-Auth": token
        }

        url = f"https://{server_name}.{environment}.Company-Domain.com/api/{api_version}/sites/{site_id}"

        body = f"""<tsRequest>
  <site guestAccessEnabled="{str(guest_access_enabled).lower()}" />
</tsRequest>"""

        response = requests.put(url, headers=headers, data=body)
        response.raise_for_status()
        logging.info(f"Guest access update response: {response.text}")
        return response.text
    except requests.exceptions.RequestException as e:
        logging.error(f"Request failed: {e}")
        if e.response is not None:
            return e.response.text
        sys.exit(1)

# Run the function
token = get_tableau_api_token()
site_id = get_tableau_site_id()

set_tableau_guest_access(
    token,
    site_id,
    Tableau_Site_Guest_Access_State,
    TableauServerName,
    Environment,
    TableauServerAPI_Version
)
