import requests
import xml.etree.ElementTree as ET

# Function to get Tableau API Token
def get_tableau_api_token(tableau_api_username, tableau_api_password, tableau_server_name, environment, tableau_server_api_version):
        return tableau_api_token

def new_tableau_ad_group(tableau_api_token, tableau_site_id, tableau_group_name, tableau_site_role, tableau_server_name, environment, tableau_server_api_version):
    # Set the URL for Tableau API group creation
    url = f"https://{tableau_server_name}.{environment}.company-domain.com/api/{tableau_server_api_version}/sites/{tableau_site_id}/groups"

    # Create XML body for group creation
    body = f"""
    <tsRequest>
        <group name="{tableau_group_name}">
            <import source="ActiveDirectory" 
                    domainName="company-domain.com"
                    grantLicenseMode="onSync"
                    siteRole="{tableau_site_role}" />
        </group>
    </tsRequest>
    """

    headers = {
        'Content-Type': 'application/xml',
        'X-Tableau-Auth': tableau_api_token
    }

    response = requests.post(url, data=body, headers=headers)

    if response.status_code == 201:
        root = ET.fromstring(response.content)
        group = root.find(".//group").text
        return group
    elif response.status_code == 409:
        print(f"Group {tableau_group_name} already exists.")
        return None
    else:
        print(f"Error: {response.status_code} - {response.text}")
        return None

def main():
    tableau_api_username = "CyberArk_UserName"
    tableau_api_password = "CyberArk_Password"
    tableau_server_name = "Your-Company-Tableau-Server-Name"
    environment = "Development"
    tableau_server_api_version = "3.10"  # Update to the correct API version
    tableau_group_name = "Tableau-Group-Name"
    tableau_site_role = "Tableau-Site-Role"

    # Get Tableau API Token
    tableau_api_token = get_tableau_api_token(tableau_api_username, tableau_api_password, tableau_server_name, environment, tableau_server_api_version)

    if tableau_api_token:
        # Get Tableau Site ID (example - this would require another function to fetch site ID)
        tableau_site_id = "Sample_Site_ID"  # Replace with actual site ID fetching logic

        # Create a new Tableau AD Group
        new_group = new_tableau_ad_group(tableau_api_token, tableau_site_id, tableau_group_name, tableau_site_role, tableau_server_name, environment, tableau_server_api_version)
        if new_group:
            print(f"New group created: {new_group}")

if __name__ == "__main__":
    main()
