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
        return tableau_site_settings

def get_datasources(tableau_api_token, tableau_site_id, tableau_server_name, environment, tableau_server_api_version):
    try:
        headers = {
            "Content-Type": "application/xml",
            "X-Tableau-Auth": tableau_api_token
        }
        payload = ""
        #url_with_filter = f"https://{tableau_server_name}.{environment}.Company-Domain.com/api/{tableau_server_api_version}/sites/{tableau_site_id}/datasources?filter=Name:eq:\DatasourceName\""
        url = f"https://{tableau_server_name}.{environment}.Company-Domain.com/api/{tableau_server_api_version}/sites/{tableau_site_id}/datasources"
        response = requests.get(url, headers=headers, data=payload, verify=False ) 

        response.raise_for_status()  # Raise error for bad response status
        xml_response = ET.fromstring(response.text)

        # Parse the data sources from the XML response
        datasources = []
        for datasource in xml_response.findall('.//datasource'):
            datasource_info = {
                "id": datasource.get('id'),
                "name": datasource.find('name').text,
                "project_id": datasource.find('project').get('id')
            }
            datasources.append(datasource_info)

        logging.info(f"Data Sources: {datasources}")
        return datasources

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

# # Get Tableau datasources
get_datasources = get_datasources(tableau_api_token, tableau_site_id, tableau_server_name, environment, tableau_server_api_version)