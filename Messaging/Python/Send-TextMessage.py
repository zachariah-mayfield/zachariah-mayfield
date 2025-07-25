# This is a Python script that will send a Text message to a phone number.
# Carrier = 'Verizon'
# PhoneNumber = ''
# Text = MIMEText('This is a txt msg from python')

import smtplib
from email.mime.text import MIMEText

From = 'xxx.xxx.xx@Company-x.com'

SMTPServer = 'smtp.Company-x.com'

Carrier = input('Enter/Select a Cellphone Carrier: ')  # Show the Dictionary of CarrierDictionary Carriers.

PhoneNumber = input('Enter in a 10 digit phone number: ')  # ensure that 10 and only 10 digits are passed in. and remove spaces and dashes.

MSG = input('Type your text msg that you would like to send: ')  #

Text = MIMEText(MSG)

CarrierDictionary = {'Verizon': '@vzwpix.com', 'Project Fi': '@msg.fi.google.com', 'Virgin Mobile': '@vmpix.com',
                'T-Mobile': '@tmomail.net', 'Sprint': '@pm.sprint.com', 'Nextel': '@messaging.nextel.com',
                'MetroPCS': '@mymetropcs.com', 'Boost Mobile': '@myboostmobile.com', 'AT&T': '@mms.att.net',
                'Alltel': '@mms.alltelwireless.com', 'Cricket': '@mms.cricketwireless.net'}

# PhoneNumber = PhoneNumber + str(CarrierDictionary[Carrier])
PhoneNumber = f"{PhoneNumber} + {CarrierDictionary[Carrier]}"

print('Sending', MSG, 'to: ' (PhoneNumber))

MailMessage = smtplib.SMTP(SMTPServer)
MailMessage.sendmail(From, PhoneNumber, str(Text))
MailMessage.quit()
