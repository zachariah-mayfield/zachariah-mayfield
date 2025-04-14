import os
import ctypes
import requests
import logging
from datetime import datetime
import xml.etree.ElementTree as ET
import sys



import requests
import xml.etree.ElementTree as ET

# Base URL for the Tableau REST API to list sites (pagination info will be added to the URL)
base_url = "http://MY-SERVER/api/3.25/sites"

# Number of results per page (set to max allowed, usually 100)
page_size = 100

# Starting page number (1-based index)
page_number = 1

# This list will store all the sites we retrieve
all_sites = []

# Loop continues until we have retrieved all available items
while True:
    # Build the URL with pagination parameters for the current page
    url = f"{base_url}?pageSize={page_size}&pageNumber={page_number}"

    # Make the GET request — we need to send XML and the authentication token
    response = requests.get(url, headers={
        "X-Tableau-Auth": "YOUR-TOKEN",  # Replace with your session or personal access token
        "Content-Type": "application/xml"
    })

    # Raise an error if the request failed
    response.raise_for_status()

    # Parse the XML response
    data = ET.fromstring(response.content)

    # Extract the list of sites from the XML response
    # This path may vary depending on the structure of your XML response
    sites = data.find(".//sites").findall("site")

    # Add the retrieved sites to the master list
    all_sites.extend(sites)

    # Extract pagination info from the XML response
    pagination = data.find(".//pagination")

    # Total number of items available across all pages
    total_available = int(pagination.find("totalAvailable").text)

    # The number of items in each page (what we set as `page_size`)
    current_page_size = int(pagination.find("pageSize").text)

    # The current page number we're on
    current_page_number = int(pagination.find("pageNumber").text)

    print(f"Fetched page {current_page_number}, got {len(sites)} site(s)")

    # Check if we've fetched all available items.
    # For example, if totalAvailable = 246 and pageSize = 100, we need 3 pages.
    if (current_page_number * current_page_size) >= total_available:
        break  # Exit the loop — we're done

    # Otherwise, increment the page number and loop again
    page_number += 1

# At this point, `all_sites` contains all the site data from the server
print(f"Total sites retrieved: {len(all_sites)}")
