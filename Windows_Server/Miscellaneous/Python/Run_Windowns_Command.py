# Module containing useful windows functions

import sys, subprocess


# functions
def run_win_cmd(cmd):
    result = []
    process = subprocess.Popen(cmd,
                               shell=True,
                               stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE)
    result = process.stdout.readlines()
    if result == []:
        error = process.stderr.readlines()
        print(sys.stderr,error)
        return None
    else:
        return result[0].strip().decode('utf-8')

