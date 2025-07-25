import subprocess
import re
import argparse
import time
import sys
import string


def ping_host(host_name):
    ping = subprocess.Popen(
        # "Command", "Argument"
        ["ping", host_name],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    out, error = ping.communicate()
    if out:
        regex = '\[(.*?)\]'
        search_obj = re.search(regex, out.decode())
        if search_obj:
            ip_address = search_obj.group(1)
            # Check to see if the two strings are in the output of the regex search.
            if 'Request timed out.' in out.decode() or 'Destination net unreachable.' in out.decode():
                return None
            return ip_address
        else:
            print('Did not find an IP Address for the Device.')
    elif error:
        return error.decode()
    return None


def StoreChecker(StoreNumber):
    StoreNumber_REGEX = re.compile(r'^\d{5}$')
    # If the StoreNumber Parameter supplied is not == equal to 5 digits, this will raise an error.
    if not StoreNumber_REGEX.search(StoreNumber):
        raise argparse.ArgumentTypeError("ERROR: Restaurant Number is not 5 Digits.")
    else:
        print('Store number passed the 5 digit check. . .')
        return StoreNumber


def main():
    parser = argparse.ArgumentParser(description='This script will Ping a store Device.', allow_abbrev=False)
    # StoreNumber is the only Parameter that the main function will take in.
    # StoreChecker is a Function that only has one parameter.
    parser.add_argument('StoreNumber', type=StoreChecker, help='Store Number of the Device that was rebooted.')
    parser.add_argument('DeviceType', type=str.lower, choices=['router', 'pos'], help='Select either router or pos')
    args = parser.parse_args()

    if args.DeviceType == 'router':
        host = args.StoreNumber + ".rtr.Company-x.com"

    elif args.DeviceType == 'pos':
        host = args.StoreNumber + ".pos.Company-x.com"

    # host variable takes in the StoreNumber parameter and appends the string.
    # hostname variable is set to the ping_host function.
    hostname = ping_host(host)

    # If no IP Address is found when running the ping_host function, the script will end.
    # regex1 = "\b(?:(?:2(?:[0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9])\.){3}(?:(?:2([0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9]))\b"
    # Match = re.search(regex1, hostname)
    count = 0
    if hostname is None:
        while hostname is None and count < 20:
            count += 1
            print('Device is still offline, this is attempt number: ' + str(count))
            time.sleep(15)  # This will sleep for 15 seconds at a max of 20 times.
            hostname = ping_host(host)
            if hostname is not None:
                print('Obtaining Device IP Address. . .')
                print('The IP Address is: ' + hostname)
                print('The Device is back online. . .')
            elif count >= 20:
                print('The Device has not came back online yet, investigate manually.')
    else:
        print('Obtaining Device IP Address. . .')
        print('The IP Address is: ' + hostname)
        print('The Device is back online. . .')


if __name__ == '__main__':
    main()

