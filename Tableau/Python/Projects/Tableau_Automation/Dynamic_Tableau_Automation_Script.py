#!/usr/bin/env python3

import requests
import xml.etree.ElementTree as ET

# =====================================================================================
# CONFIGURATION
# =====================================================================================

# Replace these values with environment-specific settings or secure credentials.
kwargs = {
    "Tableau_API_UserName": "your-username",
    "Tableau_API_Password": "your-password",
    "TableauServerName": "your-server",       # e.g., 'tableau'
    "Environment": "prod",                    # e.g., 'prod', 'dev'
    "API_Version": "3.21",
    "Site_Content_URL": ""                    # Use empty string for Default site
}


# =====================================================================================
# UTILITY FUNCTIONS
# =====================================================================================

# -- Construct the base Tableau REST API URL
def build_base_url(server_name, environment, api_version):
    return f"https://{server_name}.{environment}.Company-Domain.com/api/{api_version}"

# -- Return the correct XML body based on the request type
def xml_template(template_name, **kwargs):
    templates = {
        "signin": f"""
            <tsRequest>
                <credentials name="{kwargs['Tableau_API_UserName']}" password="{kwargs['Tableau_API_Password']}">
                    <site contentUrl="{kwargs.get('Site_Content_URL', '')}" />
                </credentials>
            </tsRequest>
        """,
        "Set_Site_Encryption": f"""
            <tsRequest>
                <site>
                    <extractEncryptionMode>{kwargs['Encryption_State']}</extractEncryptionMode>
                </site>
            </tsRequest>
        """,
        "Set_Tableau_Guest_Access": f"""
            <tsRequest>
                <site guestAccessEnabled="{str(kwargs['guest_access_enabled']).lower()}" />
            </tsRequest>
        """,
        "New_Tableau_Group": f"""
            <tsRequest>
                <group name="{kwargs['tableau_group_name']}">
                    <import source="ActiveDirectory" 
                            domainName="company-domain.com"
                            grantLicenseMode="onSync"
                            siteRole="{kwargs['tableau_site_role']}" />
                </group>
            </tsRequest>
        """,
        "Update_Tableau_Datasource_Connection": f"""
            <tsRequest>
                <connection
                    serverAddress="Data_Source_Connection_Address"
                    serverPort="Port_Number"
                    userName="{kwargs['username']}"
                    password="{kwargs['password']}"
                    embedPassword="true"
                    queryTaggingEnabled="false" />
            </tsRequest>
        """,
        "Update_Tableau_Workbook_Connection": f"""
            <tsRequest>
                <connection
                    serverAddress="Data_Source_Connection_Address"
                    serverPort="Port_Number"
                    userName="{kwargs['username']}"
                    password="{kwargs['password']}"
                    embedPassword="true"
                    queryTaggingEnabled="query-tagging-enabled" />
            </tsRequest>
        """
    }
    return templates.get(template_name, "").strip()

# -- Constructs a request dictionary from the endpoint map
def build_tableau_xml_request(url_type, **kwargs):
    base_url = build_base_url(kwargs['TableauServerName'], kwargs['Environment'], kwargs['API_Version'])

    endpoint_map = {
        "signin": {"method": "POST", "url": f"{base_url}/auth/signin/", "template": "signin"},
        "get_site": {"method": "GET", "url": f"{base_url}/sites/{kwargs['Site_ID']}"},
        "get_group": {"method": "GET", "url": f"{base_url}/sites/{kwargs['Site_ID']}/groups/{kwargs['Group_ID']}"},
        "get_datasource": {"method": "GET", "url": f"{base_url}/sites/{kwargs['Site_ID']}/datasources/{kwargs['Datasource_ID']}"},
        "get_workbook": {"method": "GET", "url": f"{base_url}/sites/{kwargs['Site_ID']}/workbooks/{kwargs['Datasource_ID']}"},
        "list_sites": {"method": "GET", "url": f"{base_url}/sites"},
        "list_workbooks": {"method": "GET", "url": f"{base_url}/sites/{kwargs['Site_ID']}/workbooks"},
        "list_groups": {"method": "GET", "url": f"{base_url}/sites/{kwargs['Site_ID']}/groups"},
        "list_datasources": {"method": "GET", "url": f"{base_url}/sites/{kwargs['Site_ID']}/datasources"},
        "Set_Site_Encryption": {
            "method": "POST",
            "url": f"{base_url}/sites/{kwargs['Site_ID']}/{kwargs['Encryption_State']}",
            "template": "Set_Site_Encryption"
        },
        "Set_Tableau_Guest_Access": {
            "method": "PUT",
            "url": f"{base_url}/sites/{kwargs['Site_ID']}",
            "template": "Set_Tableau_Guest_Access"
        },
        "New_Tableau_Group": {
            "method": "POST",
            "url": f"{base_url}/sites/{kwargs['Site_ID']}/groups",
            "template": "New_Tableau_Group"
        },
        "list_datasource_connections": {
            "method": "GET",
            "url": f"{base_url}/sites/{kwargs['Site_ID']}/datasources/{kwargs['Datasource_ID']}/connections"
        },
        "Get_Tableau_Datasource_Connection": {
            "method": "GET",
            "url": f"{base_url}/sites/{kwargs['Site_ID']}/datasources/{kwargs['Datasource_ID']}/connections"
        },
        "Update_Tableau_Datasource_Connection": {
            "method": "PUT",
            "url": f"{base_url}/sites/{kwargs['Site_ID']}/datasources/{kwargs['Datasource_ID']}/connections/{kwargs['Connection_ID']}",
            "template": "Update_Tableau_Datasource_Connection"
        },
        "list_workbook_connections": {
            "method": "GET",
            "url": f"{base_url}/sites/{kwargs['Site_ID']}/workbooks/{kwargs['Workbook_ID']}/connections"
        },
        "Get_Tableau_Workbook_Connection": {
            "method": "GET",
            "url": f"{base_url}/sites/{kwargs['Site_ID']}/workbooks/{kwargs['Workbook_ID']}/connections"
        },
        "Update_Tableau_Workbook_Connection": {
            "method": "PUT",
            "url": f"{base_url}/sites/{kwargs['Site_ID']}/workbooks/{kwargs['Workbook_ID']}/connections/{kwargs['Connection_ID']}",
            "template": "Update_Tableau_Workbook_Connection"
        }
    }

    request = endpoint_map[url_type]
    result = {
        "method": request["method"],
        "url": request["url"],
        "paginated": url_type.startswith("list")
    }

    if "template" in request:
        result["xml_body"] = xml_template(request["template"], **kwargs)

    return result

# -- Handles paginated XML responses and aggregates results
def perform_paginated_request(base_url, headers, method="GET"):
    page_size = 100
    page_number = 1
    total_available = 0
    all_items = []

    while True:
        paged_url = f"{base_url}?pageSize={page_size}&pageNumber={page_number}"
        response = requests.request(method, paged_url, headers=headers, verify=False)
        root = ET.fromstring(response.text)

        # Identify item container
        container = None
        for tag in ["sites", "workbooks", "datasources", "groups"]:
            container = root.find(tag)
            if container is not None:
                break

        if container is None:
            break

        items = [elem.attrib for elem in container]
        all_items.extend(items)

        pagination = root.find("pagination")
        if pagination is not None:
            total_available = int(pagination.attrib.get("totalAvailable", 0))
            if len(all_items) >= total_available:
                break
        else:
            break

        page_number += 1

    return {
        "totalAvailable": total_available,
        "items": all_items
    }


# =====================================================================================
# MAIN WORKFLOW: Sign-in and call paginated endpoint
# =====================================================================================

# -- Sign-in to get auth token
signin_request = build_tableau_xml_request("signin", **kwargs)
signin_headers = {
    "Content-Type": "application/xml"
}
signin_response = requests.request(
    signin_request["method"],
    signin_request["url"],
    headers=signin_headers,
    data=signin_request["xml_body"],
    verify=False
)

signin_root = ET.fromstring(signin_response.text)
credentials = signin_root.find("credentials")
token = credentials.attrib["token"]  #  This token is used in ALL requests
site_id = credentials.find("site").attrib["id"]
kwargs["Site_ID"] = site_id

# -- Authenticated headers for subsequent requests
headers = {
    "Content-Type": "application/xml",
    "X-Tableau-Auth": token  #  Token required for pagination
}

# print(f"\n Signed in successfully. Token starts with: {token[:6]}..., Site ID: {site_id}")
print(f"\n Signed in successfully. Full Token: {token}, Site ID: {site_id}")

# -- List all Tableau Sites (Paginated)
list_sites_request = build_tableau_xml_request("list_sites", **kwargs)

if list_sites_request.get("paginated"):
    sites_response = perform_paginated_request(list_sites_request["url"], headers)
    print(f"\n📋 Found {sites_response['totalAvailable']} sites:")
    for site in sites_response["items"]:
        print(f" - {site['name']} (ID: {site['id']})")
else:
    print("\n Endpoint is not paginated.")
