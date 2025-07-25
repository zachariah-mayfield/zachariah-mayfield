import re
import subprocess
import sys


# Regular expression used for commandline error handling: store number must be 5 digits
StoreNumber_REGEX = re.compile(r'^\d{5}$')
if len(sys.argv) is not 2:
    sys.exit('ERROR: Invalid Parameters - Usage: MerakiHealthCheck.py \"StoreNumber\"')
else:
    STORE_NUMBER = sys.argv[1]
    if not StoreNumber_REGEX.search(STORE_NUMBER):
        sys.exit('ERROR: store Number is not 5 Digits')

