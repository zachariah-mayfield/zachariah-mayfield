import requests
import xml.etree.ElementTree as ET

# Function to get Tableau API Token
def get_tableau_api_token(tableau_api_username, tableau_api_password, tableau_server_name, Environment, tableau_server_api_version):
        return token


def get_tableau_sites(token, tableau_server_name, Environment, tableau_server_api_version):
    # Set URL for Tableau Sites
    tableau_sites_url = f"https://{tableau_server_name}.{Environment}.Company-Domain.com/api/{tableau_server_api_version}/sites"

    # Prepare headers
    headers = {
        'Content-Type': 'application/xml',
        'X-Tableau-Auth': token,
    }

    # Make the GET request to retrieve the sites
    response = requests.get(tableau_sites_url, headers=headers)
    
    if response.status_code == 200:
        # Parse the XML response
        root = ET.fromstring(response.content)
        sites = root.findall(".//site")
        site_details = []
        
        for site in sites:
            site_details.append({
                "id": site.get("id"),
                "name": site.get("name"),
                "contentUrl": site.get("contentUrl")
            })
        
        return site_details
    else:
        response.raise_for_status()

# Example usage
tableau_api_username = "CyberArk_UserName"  # Replace with actual value
tableau_api_password = "CyberArk_Password"  # Replace with actual value
tableau_server_name = "Your-Company-Tableau-Server-Name"
environment = "Development"
tableau_server_api_version = "3.10"  # Adjust API version as needed

try:
    # Get API Token
    tableau_api_token = get_tableau_api_token(tableau_api_username, tableau_api_password, tableau_server_name, environment, tableau_server_api_version)
    
    # Get Sites
    tableau_sites = get_tableau_sites(tableau_api_token, tableau_server_name, environment, tableau_server_api_version)
    for site in tableau_sites:
        print(f"Site ID: {site['id']}, Site Name: {site['name']}, Content URL: {site['contentUrl']}")
except Exception as e:
    print(f"An error occurred: {e}")
