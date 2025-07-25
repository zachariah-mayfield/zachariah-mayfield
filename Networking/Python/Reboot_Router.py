import subprocess
import paramiko
import re
import argparse
import sys
import string


# This Function will run a Windows CMD to grab the CyberArk Credential.
def Get_CyberArk_Password(cmd):
    result = []
    process = subprocess.Popen(cmd,
                               shell=True,
                               stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE)
    result = process.stdout.readlines()
    if result == []:
        error = process.stderr.readlines()
        print(sys.stderr, error)
        return None
    else:
        return result[0].strip().decode('utf-8')


# This Function will run a Windows CMD to ping the host_name of the router to get back the IP address.
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
            print('Obtaining Router IP Address. . .')
            return ip_address
        else:
            print('Did not find an IP Address for the router.')
    elif error:
        return error.decode()
    return None


def ssh_Connect(hostname, port, command, username, password):
    try:
        SSH_client = paramiko.SSHClient()
        SSH_client.load_system_host_keys()
        SSH_client.set_missing_host_key_policy(paramiko.WarningPolicy)
        SSH_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

        SSH_client.connect(hostname, port=port, username=username, password=password)

        stdin, stdout, stderr = SSH_client.exec_command(command)

        regex = r'(System is rebooting).{3}'
        SSH_Output = str(stdout.read())
        search_obj = re.search(regex, SSH_Output)

        if search_obj:
            print('Making an SSH Connection to the router. . .')
            print('Restarting Router. . .')
            Phrase1 = search_obj.group()
            print(Phrase1)
        else:
            print('No Match for Search Phrase: "System is rebooting..."')
    except paramiko.SSHException as e:
        print(f' Unexpected Error {e}', file=sys.stderr)
    except:
        print(sys.exc_info())

    finally:
        if SSH_client:
            SSH_client.close()


def StoreChecker(StoreNumber):
    StoreNumber_REGEX = re.compile(r'^\d{5}$')
    # If the StoreNumber Parameter supplied is not == equal to 5 digits, this will raise an error.
    if not StoreNumber_REGEX.search(StoreNumber):
        raise argparse.ArgumentTypeError("ERROR: store Number is not 5 Digits.")
    else:
        print('Store number passed the 5 digit check. . .')
        return StoreNumber


def main():
    parser = argparse.ArgumentParser(description='This script will connect using SSH to a store router.', allow_abbrev=False)
    # StoreNumber is the only Parameter that the main function will take in.
    # StoreChecker is a Function that only has one parameter.
    parser.add_argument('StoreNumber', type=StoreChecker, help='Store Number of the router that will be rebooted.')

    args = parser.parse_args()

    # host variable takes in the StoreNumber parameter and appends the string.
    host = args.StoreNumber + ".rtr.Company-x.com"

    # hostname variable is set to the ping_host function.
    hostname = ping_host(host)

    # If no IP Address is found when running the ping_host function, the script will end.
    if hostname is None:
        print('Router: ' + host + ' is NOT Responding, exiting script. . .')
        exit(1)
    else:
        print('Router hostname is: ' + host)
        print('Router IP Address is: ' + hostname)

    username = 'fortinetpas_service'
    # CyberArk variable is set to the Get_CyberArk_Password function.
    CyberArk = Get_CyberArk_Password('"%PROGRAMFILES(x86)%\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=$AppID /p Query=$Query;Folder=Root;Object=$Object /o Password')
    port = 22

    # command is the SHH Command that will reboot the router and auto accept the questions.
    command = """execute reboot\ny\ny"""

    # This function call is the SSH Connection Command that does all of the work.
    ssh_Connect(hostname, port, command, username, CyberArk)

    exit(0)


if __name__ == '__main__':
    main()


