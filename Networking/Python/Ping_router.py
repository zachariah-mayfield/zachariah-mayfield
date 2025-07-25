import subprocess
import re
import sys
import string


StoreNumber = '12221'
host_name = StoreNumber + ".rtr.Company-x.com"


def Ping_Router(host_name):
    ping = subprocess.Popen(
        # "Command", "Argument"
        ["ping", host_name],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    out, error = ping.communicate()
    if out:
        print(out.decode())
    elif error:
        return error.decode()
    else:
        return None


ping_result = Ping_Router(host_name)

while People <= 10:
    print(People)
    People += 1


Ping_Router(host_name)

