from selenium import webdriver

Browser = webdriver.Chrome("C:/windows/chromedriver.exe")

url = 'https://www.google.com/'

Browser.get(url)