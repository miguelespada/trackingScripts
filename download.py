#!/usr/local/bin/python

import os
os.system("export PYTHONPATH=/usr/lib/pymodules/python2.6/")
# -*- coding: utf-8 -*-
import urllib2
import xml.etree.ElementTree as ET
import _mysql
import time
import pyproj


wgs84=pyproj.Proj("+init=EPSG:4326")
utm31=pyproj.Proj("+init=EPSG:32631")
utm32=pyproj.Proj("+init=EPSG:32632")

path = "backup/"
#host = "http://147.96.81.188/gps1.xml"
host = "http://89.140.246.27/GwtGui/GetPositions?userName=voxel&pass=sit11&vehicle=001 002 003 004 005 006 007 008 009 010 011 012 021 022&typeFile=XML&index=1"
host = host.replace(" ", "%20")
#host = "http://89.140.246.27/GwtGui/GetPositions?userName=voxel&pass=sit11&vehicle=001%20002&typeFile=XML&index=1"

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
		print carId,
		latitud =  float(r.find('latitude').text)
		longitud =  float(r.find('longitude').text)
		easting, northing = pyproj.transform(wgs84, utm31, longitud, latitud)
		state =  "'" + r.find('fleet').text + "'"
		speed =  r.find('speed').text
		carTime =  r.find('date').text
		data = int(carId), float(easting), float(northing),  float(speed), int(carTime), state
		if insertDB(data):
			fileName = path + carId + "_" + str(int(time.time())) + ".xml"
			f = open(fileName, 'w')
			s = ET.tostring(r)
 			f.write(s)
			f.close()
			print
			print "[OK] new data backing up: ", carId
	print 
	
con = _mysql.connect('127.0.0.1', 'root', 'wtw6sb', 'unity')
while True:
	#print "Downloading from: ", host
	response = urllib2.urlopen(host)
	html = response.read()
	xml = parseGps(html)
	vs = getVehicleIds(xml)
	processVehicles(xml)
	time.sleep(2)
