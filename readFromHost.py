#!/usr/bin/python2.7
# -*- coding: utf-8 -*-

import urllib2
import xml.etree.ElementTree as ET
import _mysql
import time

path = "backup/"
host = "http://127.0.0.1:8888/unity/gps1.xml"

def parseGps(data): 
    return ET.fromstring(data)
    
def getVehicleIds(xml):
    acts = []
    for c in xml:
        acts += [c.find('vehicle').text]
    return acts

def insertDB(data):
	s = "SELECT count(*) FROM data WHERE carId = " + str(data[0]) + " and time = " + str(data[4])
	con.query(s)
	r = con.store_result()
	if int(r.fetch_row()[0][0]) == 0:
		s = "INSERT INTO data(carId, x, y, speed, time, status) VALUES (%d, %.2f, %.2f, %.2f, %d, %s)" % data
		con.query(s)
		con.commit()
		return True
	else:
		con.commit()
		return False

def processVehicles(xml):
	query = ".//tracking"
	result = xml.findall(query)
	fresh = False
	for r in result:
		carId =  r.find('vehicle').text
		northing =  r.find('utm').find('northing').text
		easting =  r.find('utm').find('easting').text
		state =  "'" + r.find('fleet').text + "'"
		speed =  r.find('speed').text
		carTime =  r.find('date').text
		data = int(carId), float(northing), float(easting), float(speed), (int(carTime) / 1000) % 1000000, state
		if insertDB(data):
			fresh = True
	return fresh

con = _mysql.connect('127.0.0.1', 'miguel', 'miguel', 'unity', 8889)
print "Downloading from: ", host

response = urllib2.urlopen(host)
html = response.read()
xml = parseGps(html)
vs = getVehicleIds(xml)
if processVehicles(xml):
	fileName = path + str(int(time.time())) + ".xml"
	f = open(fileName, 'w')
	f.write(html)
	print "[OK] new data backing up: ", fileName
else:
	print "[OK] no new data"
