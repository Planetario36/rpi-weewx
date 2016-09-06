#!/usr/bin/env python

#Drew McCalmont
#uploads a webcam image to weather underground

#import correct libraries
import urllib
import ftplib
import ConfigParser
import os, sys
import time

#initialize Config Parser to get correct settings
conf = ConfigParser.RawConfigParser()
conf.read(os.path.join(os.path.dirname(os.path.abspath(sys.argv[0])),'wunderground_upload_cam.conf'))

#get the local url to pull the images from
webcam_url = conf.get('Settings','webcam_url')

#get the ftp path to upload the files to... i.e.:WeatherUnderground
ftp_url = conf.get('Settings','ftp_url')

#ftp upload username and password
username = conf.get('Settings','username')
password = conf.get('Settings','password')

print "Starting Webcam Upload"

#connect to ftp server
f = urllib.urlopen(webcam_url)
s = ftplib.FTP()

s.connect(ftp_url,21)
s.login(username, password)

#upload image
s.storbinary('STOR image.jpeg', f)
print "END"

#give uploader time to upload, helps with poor internet connection
time.sleep(30)

#close connection with ftp server, and close local url
f.close()
s.quit()
