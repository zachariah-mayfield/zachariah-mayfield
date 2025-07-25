import subprocess
import argparse
import string
import re

host = "xxxxxxxx.rtr.Company-x.com"


def ping_host(hostname):

    ping = subprocess.Popen(
        ["ping", hostname],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    out, error = ping.communicate()
    if out:

        regex = '\[(.*?)\]'
        # ping_response = out.decode()
        search_obj = re.search(regex, out.decode())

        if search_obj:
            print(search_obj.group(1))
        else:
            print('No Match')
    elif error:
        return error.decode()
    else:
        return None


ping_host(host)

