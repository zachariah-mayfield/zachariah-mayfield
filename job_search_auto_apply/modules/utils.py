# -----------------------------
# modules/utils.py
# -----------------------------

import json

def load_user_config():
    # Assume a config file that stores user information for applying
    with open("user_profile.json", "r") as f:
        config = json.load(f)
    return config



### OLD CODE ###

# import json

# def load_user_config(path="config/user_profile.json"):
#     with open(path) as f:
#         return json.load(f)

### OLD CODE ###