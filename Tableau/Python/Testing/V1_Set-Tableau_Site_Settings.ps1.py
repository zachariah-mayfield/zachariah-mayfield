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

# Example values (replace as needed)
TableauServerName = "your-tableau-server-name"
Environment = "Development"
TableauServerAPI_Version = "3.18"
Tableau_Site_Extracts_Encryption_State = "encrypt-extracts"  # or "decrypt-extracts"

# Mock functions — replace with actual logic
def get_tableau_api_token():
    return "your_tableau_auth_token"

def get_tableau_site_id():
    return "your_site_id"

# Set Tableau site settings (encryption/decryption)
def set_tableau_site_settings(token, site_id, encryption_state, server_name, environment, api_version):
    try:
        headers = {
            "Content-Type": "application/xml",
            "X-Tableau-Auth": token
        }

        url = f"https://{server_name}.{environment}.Company-Domain.com/api/{api_version}/sites/{site_id}/{encryption_state}"

        # Prepare the XML body for the request
        body = f"""<tsRequest>
  <site>
    <extractEncryptionMode>{encryption_state}</extractEncryptionMode>
  </site>
</tsRequest>"""

        response = requests.post(url, headers=headers, data=body)

        if response.status_code == 409:
            logging.warning(f"Conflict: The setting could not be applied.")
            print("Conflict: The setting could not be applied.")
            return None

        response.raise_for_status()
        site_info = response.text
        logging.info(f"Site settings updated: {site_info}")
        return site_info

    except requests.exceptions.RequestException as e:
        logging.error(f"Request failed: {e}")
        sys.exit(1)

# Run the function
token = get_tableau_api_token()
site_id = get_tableau_site_id()
updated_site = set_tableau_site_settings(
    token,
    site_id,
    Tableau_Site_Extracts_Encryption_State,
    TableauServerName,
    Environment,
    TableauServerAPI_Version
)

# Optional print for visibility
# print(updated_site)
