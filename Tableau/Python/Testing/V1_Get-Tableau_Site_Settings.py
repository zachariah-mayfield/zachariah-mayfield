import requests
import xml.etree.ElementTree as ET
import logging
from datetime import datetime

# Setup logging
log_file = fr"C:\Logs\Tableau_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.log"
logging.basicConfig(filename=log_file, level=logging.DEBUG, format='%(asctime)s %(message)s')
logging.info("Script started")

# Function to get Tableau API Token
def get_tableau_api_token(tableau_api_username, tableau_api_password, tableau_server_name, environment, tableau_server_api_version):
        return tableau_api_token

# Function to get Tableau Site Settings
def get_tableau_site_settings(tableau_api_token, tableau_site_id, tableau_server_name, environment, tableau_server_api_version):
    try:
        headers = {
            "Content-Type": "application/xml",
            "X-Tableau-Auth": tableau_api_token
        }

        url = f"https://{tableau_server_name}.{environment}.Company-Domain.com/api/{tableau_server_api_version}/sites/{tableau_site_id}"
        response = requests.get(url, headers=headers)

        response.raise_for_status()  # Raise error for bad response status
        xml_response = ET.fromstring(response.text)

        # Parse the site settings from the XML response
        extract_encryption_mode = xml_response.find('.//extractEncryptionMode').text
        site_name = xml_response.find('.//name').text

        tableau_site_settings = {
            "ExtractEncryptionMode": extract_encryption_mode,
            "Site_ID": tableau_site_id,
            "Site_Name": site_name
        }

        logging.info(f"Tableau Site Settings: {tableau_site_settings}")
        return tableau_site_settings

    except requests.exceptions.RequestException as e:
        logging.error(f"Request failed: {e}")
        raise

# Example usage (replace with actual values)
tableau_api_username = "CyberArk_UserName"
tableau_api_password = "CyberArk_Password"
tableau_server_name = "Your-Company-Tableau-Server-Name"
environment = "Development"
tableau_server_api_version = "3.18"  # Adjust API version as needed
tableau_site_id = "your_site_id"  # Replace with actual site ID

# Get Tableau API token
tableau_api_token = get_tableau_api_token(tableau_api_username, tableau_api_password, tableau_server_name, environment, tableau_server_api_version)

# Get Tableau site settings
site_settings = get_tableau_site_settings(tableau_api_token, tableau_site_id, tableau_server_name, environment, tableau_server_api_version)

# Optional: Print the site settings
print(site_settings)
