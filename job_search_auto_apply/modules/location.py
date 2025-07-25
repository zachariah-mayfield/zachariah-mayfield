# -----------------------------
# modules/location.py
# -----------------------------

import requests

def get_coordinates(zip_code):
    # Assume a service like Google Maps API to get coordinates from a zip code
    response = requests.get(f"https://api.example.com/geocode?zip={zip_code}")
    response.raise_for_status()
    data = response.json()
    return data['lat'], data['lon']

def get_nearby_companies(lat, lon, radius):
    # Dummy implementation, you could use a company data API
    companies = ["Company A", "Company B", "Company C"]  # Placeholder
    return companies


### OLD CODE ###
# import requests

# def get_coordinates(zip_code):
#     response = requests.get(f"https://nominatim.openstreetmap.org/search?postalcode={zip_code}&format=json")
#     data = response.json()
#     if data:
#         return float(data[0]['lat']), float(data[0]['lon'])
#     else:
#         raise ValueError("Invalid ZIP code or no location data found.")

# def get_nearby_companies(lat, lon, radius):
#     # Simulate with static companies
#     return [
#         {"name": "Navy Federal Credit Union", "url": "https://www.navyfederal.org/careers/"},
#         {"name": "AppRiver", "url": "https://www.appriver.com/company/careers"},
#     ]
### OLD CODE ###

#     # In a real-world scenario, you would use an API or database to find companies within the specified radius.
#     # For example, you could use the Google Places API or a local database of companies.
#     # Here, we will simulate this with a static list of companies.
#     # You can replace this with actual API calls or database queries.
#     # For example:
#     # response = requests.get(f"https://api.example.com/companies?lat={lat}&lon={lon}&radius={radius}")
#     # data = response.json()
#     # return data['companies']
#
#     # For now, we will return a static list of companies for demonstration purposes.  
#     return [
#         {"name": "Company A", "url": "https://example.com/careers/company-a"},
#         {"name": "Company B", "url": "https://example.com/careers/company-b"},
#         {"name": "Company C", "url": "https://example.com/careers/company-c"},
#     ]