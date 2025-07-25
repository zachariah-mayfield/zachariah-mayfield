import subprocess
import re
import argparse
import time
import sys
import string


Sentence = "RegExr v3 was created by gskinner.com, 172.31.1.1 hosted by Media Temple."

pattern = re.compile(r'\b(?:(?:2(?:[0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9])\.){3}(?:(?:2([0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9]))\b')

matches = pattern.finditer(Sentence)

for match in matches:
    print(match.group())

