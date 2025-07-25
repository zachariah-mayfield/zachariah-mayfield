#!/usr/bin/env python3

# pip install requests

import requests
import xml.etree.ElementTree as ET

API_Version = "3.18"  # example version
TableauServerName = "Your-Company-Tableau-Server-Name"
Tableau_API_UserName = "CyberArk_UserName"  # Replace with real or fetched credentials
Tableau_API_Password = "CyberArk_Password"
url_type = "signin", "Set_Site_Encryption", "New_Tableau_Group", "Update_Tableau_Datasource_Connection"
Encryption_State = "encrypt-extracts"  # or "decrypt-extracts"
token = 'Tableau_API_Generated_Token'
Site_ID = 'Your-Tableau-Site-ID'
Workbook_ID = 'Your-Workbook-ID'
Datasource_ID = 'Your-Datasource-ID'
Connection_ID = 'Your-Connection-ID'
Group_ID ='Your-Group_ID'
Environment = "Development"  # or UAT, Production


headers = {
    "Content-Type": "application/xml",
    "X-Tableau-Auth": token
}

def build_tableau_xml_request(url_type, **kwargs):
    # Build a consistent base URL using common parts
    base_url = f"https://{kwargs['TableauServerName']}.{kwargs['Environment']}.Company-Domain.com/api/{kwargs['API_Version']}"
######################################################################################################################################
######################################################################################################################################
    # URL builder based on the type of request
    if url_type == "signin":
        url = f"{base_url}/auth/signin/"
        url_request_method = 'POST'
        xml_body = f"""
        <tsRequest>
            <credentials name="{kwargs['Tableau_API_UserName']}" password="{kwargs['Tableau_API_Password']}">
                <site contentUrl="{kwargs.get('Site_Content_URL', '')}" />
            </credentials>
        </tsRequest>
        """
        return {"url": url, "xml_body": xml_body.strip(), "url_request_method": url_request_method}
######################################################################################################################################
######################################################################################################################################
    elif url_type == "get_site":
        url = f"{base_url}/sites/{kwargs['Site_ID']}"
        return {"url": url, "xml_body": xml_body.strip(), "url_request_method": url_request_method}
######################################################################################################################################
######################################################################################################################################
    elif url_type == "list_sites":
        url = f"{base_url}/sites"
        return {"url": url, "xml_body": xml_body.strip(), "url_request_method": url_request_method}
######################################################################################################################################
######################################################################################################################################
    elif url_type == "Set_Site_Encryption":
        url = f"{base_url}/sites/{kwargs['Site_ID']}/{kwargs['Encryption_State']}"
        url_request_method = 'POST'
        xml_body = f"""<tsRequest>
        <site>
            <extractEncryptionMode>{kwargs['Encryption_State']}</extractEncryptionMode>
        </site>
        </tsRequest>"""
        return {"url": url, "xml_body": xml_body.strip(), "url_request_method": url_request_method}
######################################################################################################################################
######################################################################################################################################
    elif url_type == "Set_Tableau_Guest_Access":
        url = f"{base_url}/sites/{kwargs['Site_ID']}"
        url_request_method = 'PUT'
        xml_body = f"""
        <tsRequest>
            <site guestAccessEnabled="{str(kwargs['guest_access_enabled']).lower()}" />
        </tsRequest>"""
        return {"url": url, "xml_body": xml_body.strip(), "url_request_method": url_request_method}
######################################################################################################################################
######################################################################################################################################
    elif url_type == "list_groups":
        url = f"{base_url}/sites/{kwargs['Site_ID']}/groups"
        return {"url": url, "xml_body": xml_body.strip(), "url_request_method": url_request_method}
######################################################################################################################################
######################################################################################################################################
    elif url_type == "New_Tableau_Group":
        url = f"{base_url}/sites/{kwargs['Site_ID']}/groups"
        url_request_method = 'POST'
        xml_body = f"""
        <tsRequest>
            <group name="{kwargs['tableau_group_name']}">
                <import source="ActiveDirectory" 
                        domainName="company-domain.com"
                        grantLicenseMode="onSync"
                        siteRole="{kwargs['tableau_site_role']}" />
            </group>
        </tsRequest>
        """
        return {"url": url, "xml_body": xml_body.strip(), "url_request_method": url_request_method}
######################################################################################################################################
######################################################################################################################################
    elif url_type == "list_datasources":
        url = f"{base_url}/sites/{kwargs['Site_ID']}/datasources"
        url_request_method = 'Get'
        return {"url": url, "xml_body": xml_body.strip(), "url_request_method": url_request_method}
######################################################################################################################################
######################################################################################################################################
    elif url_type == "list_datasource_connections":
        url = f"{base_url}/sites/{kwargs['Site_ID']}/datasources/{kwargs['Datasource_ID']}/connections"
        url_request_method = 'Get'
        return {"url": url, "xml_body": xml_body.strip(), "url_request_method": url_request_method}
######################################################################################################################################
######################################################################################################################################
    elif url_type == "Get_Tableau_Datasource_Connection":
        url = f"{base_url}/sites/{kwargs['Site_ID']}/datasources/{kwargs['Datasource_ID']}/connections"
        url_request_method = 'GET'        
        return {"url": url, "xml_body": xml_body.strip(), "url_request_method": url_request_method}
######################################################################################################################################
######################################################################################################################################
    elif url_type == "Update_Tableau_Datasource_Connection":
        url = f"{base_url}/sites/{kwargs['Site_ID']}/datasources/{kwargs['Datasource_ID']}/connections/{kwargs['Connection_ID']}"
        url_request_method = 'PUT'
        xml_body = f"""
        <tsRequest>
        <connection
            serverAddress="Data_Source_Connection_Address"
            serverPort="Port_Number"
            userName="{kwargs['username']}"
            password="{kwargs['password']}"
            embedPassword="true"
            queryTaggingEnabled="false" />
        </tsRequest>
        """
        return {"url": url, "xml_body": xml_body.strip(), "url_request_method": url_request_method}
######################################################################################################################################
######################################################################################################################################
    elif url_type == "list_workbook_connections":
        url = f"{base_url}/sites/{kwargs['Site_ID']}/workbooks/{kwargs['Workbook_ID']}/connections"
        url_request_method = 'Get'
        return {"url": url, "xml_body": xml_body.strip(), "url_request_method": url_request_method}
######################################################################################################################################
######################################################################################################################################
    elif url_type == "Get_Tableau_Workbook_Connection":
        url = f"{base_url}/sites/{kwargs['Site_ID']}/workbooks/{kwargs['Workbook_ID']}/connections"
        url_request_method = 'Get'
        return {"url": url, "xml_body": xml_body.strip(), "url_request_method": url_request_method}
######################################################################################################################################
######################################################################################################################################
    elif url_type == "Update_Tableau_Workbook_Connection":
        url = f"{base_url}/sites/{kwargs['Site_ID']}/workbooks/{kwargs['Workbook_ID']}/connections/{kwargs['Connection_ID']}"
        url_request_method = 'PUT'
        xml_body = f"""
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
        return {"url": url, "xml_body": xml_body.strip(), "url_request_method": url_request_method}
######################################################################################################################################
######################################################################################################################################
    else:
        raise ValueError(f"Unknown URL type: {url_type}")
######################################################################################################################################
######################################################################################################################################

response = requests.request(url_request_method, url, headers=headers, data=xml_body, verify=False)

