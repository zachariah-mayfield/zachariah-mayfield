# Tableau XML REST API Integration (Python)

This project provides a fully-featured Python script for interacting with the Tableau Server REST API using **XML** instead of JSON. It supports a wide range of operations including sign-in, site and workbook management, connection updates, and includes **automatic pagination handling** for listing endpoints.

---

## 📄 Features

- XML-based requests and responses
- Session token-based authentication
- Support for multiple Tableau endpoints (sites, workbooks, groups, datasources, etc.)
- Automatic pagination for any `list_*` endpoints
- Highly customizable and extensible
- Secure practices with optional debug output

---

## 🔧 Requirements

- Python 3.7+
- `requests` library

Install dependencies:
```bash
pip install requests

🚀 Setup
1. Clone or download the script
Place the script in your project directory.

2. Set your environment and credentials
You can hardcode, securely fetch, or load from a .env file:

python
Copy
Edit
kwargs = {
    "Tableau_API_UserName": "your_tableau_username",
    "Tableau_API_Password": "your_tableau_password",
    "TableauServerName": "your-server",
    "Environment": "prod",  # or "dev", "qa", etc.
    "API_Version": "3.21",
    "Site_Content_URL": "",  # For default site, leave as empty string
}

🛠️ How It Works
Sign-in
Sends a POST request with XML credentials

Receives a session token and site ID

These are used in all subsequent API calls via X-Tableau-Auth header

Request Builder
A centralized function maps keywords like list_sites, get_workbook, etc. to actual Tableau REST API endpoints and XML templates.

Pagination
Automatically detects and loops through all pages when calling list_* endpoints.

Uses the <pagination totalAvailable="x"/> tag from the XML response to determine how many items to fetch.

✅ Examples
▶️ Sign In and List All Sites
python
Copy
Edit
from tableau_xml_api import TableauAPIClient  # If split into a module

# Initialize and sign in
client = TableauAPIClient(**kwargs)
client.sign_in()

# List all sites with automatic pagination
all_sites = client.make_paginated_request("list_sites")

# Print site names
for site in all_sites:
    print(site.attrib.get("name"))


📚 Supported Operations
You can pass one of the following keys to make_paginated_request() or make_request():

Operation Key	Description
signin	Sign in and get auth token + site ID
get_site	Get a specific site
list_sites	List all sites (paginated)
list_workbooks	List all workbooks on a site
list_groups	List all groups
list_datasources	List all datasources
Set_Site_Encryption	Update site encryption settings
Set_Tableau_Guest_Access	Enable/disable guest access for a site
New_Tableau_Group	Create a new AD group in Tableau
Update_Tableau_Datasource_Connection	Update datasource connection creds
Update_Tableau_Workbook_Connection	Update workbook connection creds