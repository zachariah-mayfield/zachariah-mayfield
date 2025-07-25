#!/usr/bin/env python3

import os
import ctypes
import requests
import logging
from datetime import datetime
import xml.etree.ElementTree as ET
import sys

# -----------------------------
# Check for Administrator Privileges
# -----------------------------
def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

if not is_admin():
    ctypes.windll.shell32.ShellExecuteW(
        None, "runas", sys.executable, ' '.join(sys.argv), None, 1
    )
    sys.exit()

# -----------------------------
# Logging Setup
# -----------------------------
log_path = f"C:\\Logs\\Tableau_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.log"
logging.basicConfig(filename=log_path, level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logging.info("Script started")

# -----------------------------
# Configuration
# -----------------------------
Tableau_API_UserName = "CyberArk_UserName"  # Replace with real or fetched credentials
Tableau_API_Password = "CyberArk_Password"
TableauServerName = "Your-Company-Tableau-Server-Name"
Environment = "Development"  # or UAT, Production
TableauServerAPI_Version = "3.18"  # example version

# -----------------------------
# Function to Get Tableau API Token
# -----------------------------
def get_tableau_api_token(Tableau_API_UserName, Tableau_API_Password, TableauServerName, Environment, TableauServerAPI_Version):
    try:
        url = f"https://{TableauServerName}.{Environment}.Company-Domain.com/api/{TableauServerAPI_Version}/auth/signin/"
        headers = {
            "Content-Type": "application/xml"
        }
        body = f"""
        <tsRequest>
            <credentials name="{Tableau_API_UserName}" password="{Tableau_API_Password}">
                <site contentUrl="" />
            </credentials>
        </tsRequest>
        """

        response = requests.post(url, headers=headers, data=body)
        response.raise_for_status()

        # Parse XML response
        root = ET.fromstring(response.text)
        token = root.find('.//t:credentials', {'t': 'http://tableau.com/api'}).attrib['token']
        logging.info("Successfully retrieved Tableau API token")
        return token

    except requests.exceptions.HTTPError as http_err:
        logging.error(f"HTTP error occurred: {http_err}")
        sys.exit(1)
    except Exception as err:
        logging.error(f"Other error occurred: {err}")
        sys.exit(1)

# -----------------------------
# Main 
# -----------------------------
if __name__ == "__main__":
    token = get_tableau_api_token(
        Tableau_API_UserName,
        Tableau_API_Password,
        TableauServerName,
        Environment,
        TableauServerAPI_Version
    )
    print(f"Tableau API Token: {token}")
    logging.info(f"Token: {token}")
    logging.info("Script completed successfully")
