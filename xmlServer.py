#!/usr/bin/python2.7
# -*- coding: utf-8 -*-

from ttk import *
from Tkinter import *
import xml.etree.ElementTree as ET
import sys,os
import dateutil.parser
import OSC
import _mysql
from glob import glob
import time
import urllib2
response = urllib2.urlopen('http://www.example.com/')
html = response.read()

con = _mysql.connect('127.0.0.1', 'miguel', 'miguel', 'unity', 8889)


delay = 1000
gps = None
lastModified = 0

class GPS:
    def __init__(self, path, I, O):
        self.i = 1
        self.path = path
        self.I = I
        self.O = O
        self.i = I
        self.data = None

    def reset(self):
        self.i = self.I
        con.query("DELETE FROM data WHERE 1")
        sendOscReset()
    
    def jump(self, v):
        self.i = v
        sendOscReset()

    def parseGps(self):
        global delay, lastModified
        theFile = self.path + "gps" + str(self.i) + ".xml"
        self.i += 1
        if self.i == self.O:
            delay = 0
            self.i -= 1
            #sendOscReset()
        if os.path.getmtime(theFile) != lastModified:
            tree = ET.parse(theFile)
            lastModified = os.path.getmtime(theFile) 
            return tree.getroot()
        else:
            return None

    def getAllData(self, value):
        query = ".//tracking[vehicle='" + value +"']"
        result = self.gps.findall(query)[0]
        s = ""
        self.selected = result
        for r in result:
            if r.tag == 'utm':
                for rr in r:
                    row = "utm -> " + rr.tag + " -> " + rr.text + "\n"
                    s += row
            elif r.tag == 'iso8601date':
                theDate = dateutil.parser.parse(r.text)
                row = "date -> " + str(theDate) + "\n"
                s += row
            else:
                row = r.tag + " -> " + r.text + "\n"
                s += row 
        return s

    def getVehicleIds(self):
        acts = []
        for c in self.data:
            acts += [c.find('vehicle').text]
        return acts
    
    def getVehicleNavigationData(self, value):
        query = ".//tracking[vehicle='" + value +"']"
        result = self.data.findall(query)[0]
        northing =  result.find('utm').find('northing').text
        easting =  result.find('utm').find('easting').text
        state =  result.find('fleet').text
        speed =  result.find('speed').text
        time =  result.find('date').text
        d = int(value), float(northing), float(easting), float(speed), (int(time) / 1000) % 10000, state
        return d
        
    def getVehicleStatus(self, value):
        query = ".//tracking[vehicle='" + value +"']"
        result = self.data.findall(query)[0]
        state =  result.find('fleet').text
        speed =  int(float(result.find('speed').text))
        return "\t" + str(speed) + " km/h\t\t" + str(state)

    def pullData(self):
        self.data = self.parseGps()
        if self.data == None: return None
        return self.getVehicleIds()
        

class myFrame(Frame):
  
    def __init__(self, parent):

        Frame.__init__(self, parent)   
        self.parent = parent
        self.initUI()
        parent.title("GPS tracking system")  
        self.selected = []
    def initUI(self):
      
        self.parent.title("Buttons")
        self.style = Style()
        self.style.theme_use("default")
        
        self.frame = Frame(self, relief=RAISED, borderwidth=1)
        self.frame.pack(fill=BOTH, expand=1)
        self.pack(fill=BOTH, expand=1)
        
      
        quitButton = Button(self, text="Quit",
            command=self.quit)
        quitButton.pack(side=RIGHT, padx=5, pady=5)
       

        resetButton = Button(self, text="Reset",
            command=self.onReset)
        resetButton.pack(side=RIGHT, padx=5, pady=5)


        clearButton = Button(self, text="Clear",
            command=self.onClear)
        clearButton.pack(side=RIGHT, padx=5, pady=5)

        # vizButton = Button(self, text="Visual",
        #     command=self.onOpenViz)
        # vizButton.pack(side=RIGHT, padx=5, pady=5)

        self.lb = Listbox(self.frame, relief = RAISED,width= 40, selectmode=MULTIPLE, exportselection=0)
        self.lb.pack(fill=Y, side=LEFT,  padx=5, pady=5)  

        scrollbar = Scrollbar(self.frame)
        scrollbar.pack(side=LEFT, fill=Y)

        self.lb.config(yscrollcommand=scrollbar.set)
        scrollbar.config(command=self.lb.yview)


        self.lFrequency = Listbox(self.frame, width= 20, relief = RAISED, exportselection=0)
        self.lFrequency.pack(side=TOP, padx=5, pady=5) 
        self.lFrequency.bind("<<ListboxSelect>>", self.onSelectFrequency)   
        freqs = [0, 100, 500, 1000, 3000, 10000]
        for f in freqs: 
            self.lFrequency.insert(END, f)   
        
        self.lFrequency.selection_set(freqs.index(delay))
        
        
        self.var = StringVar()
        self.label = Label(self, text=0, textvariable=self.var, justify=LEFT)  
        self.label.pack(side = LEFT)  

    def registerGPS(self, gps):
        self.gps = gps
        self.w1 = Scale(self.frame, from_=self.gps.I, to=self.gps.O, orient=HORIZONTAL, command=self.onScaleI)
        self.w1.pack(side=TOP, padx=5, pady=5)

        self.w2 = Scale(self.frame, from_=self.gps.I, to=self.gps.O, orient=HORIZONTAL, command=self.onScaleO)
        self.w2.pack(side=TOP, padx=5, pady=5)
        self.w2.set(self.gps.O)
        
    def onScaleI(self, val):
        self.gps.I = int(val)
        if self.gps.I >= self.gps.O:
            self.gps.I = self.gps.O - 1
            self.w1.set(self.gps.I)

    def onScaleO(self, val):
        self.gps.O = int(val)
        if self.gps.O <= self.gps.I:
            self.gps.O = self.gps.I + 1
            self.w2.set(self.gps.O)

    def setListData(self, data, gps): 
        sel = self.getSelected()   
        self.lb.delete(0, END)
        i = 0
        for v in data:
            status = gps.getVehicleStatus(v)
            item = v + " " + status
            self.lb.insert(END, item)
            if int(v) in sel:
                self.lb.selection_set(i)
            i += 1
    
    # def onSelect(self):
    #     sender = val.widget
    #     idx = sender.curselection()
    #     value = sender.get(idx)
    #     if value in self.selected:
    #         self.selected.remove(value)
    #     else:
    #         self.selected.append(value)
    
    def setLog(self, s):
        self.var.set(s)
    
    def getSelected(self):
        cSelection = map(int, self.lb.curselection())
        sel = []
        for c in cSelection:
            value = self.lb.get(c)
            t = int(value.split(' ')[0])
            sel.append(t)
        return sel
    
    def getSelectedString(self):
        cSelection = map(int, self.lb.curselection())
        sel = []
        for c in cSelection:
            value = self.lb.get(c)
            t = value.split(' ')[0]
            sel.append(t)
        return sel



    def onSelectFrequency(self, val):
        global delay
        sender = val.widget
        idx = sender.curselection()
        value = sender.get(idx)
        delay = int(value)


    def onReset(self):
        self.gps.reset()

    def onClear(self):
        print "clearing..."
        con.query("UPDATE data SET processed = 0 WHERE processed = 1")


    def onOpenViz(self):
        os.system('open unityTracking2.app')

def sendOsc(data):
    s = "INSERT INTO data(carId, x, y, speed, time) VALUES (%d, %.2f, %.2f, %.2f, %d)" % data[0:5]
    print s
    con.query(s)
    
def sendOscReset():
    msg = OSC.OSCMessage()
    msg.setAddress("/reset")
    try:
        client.sendto(msg, ('localhost', 12000)) # note that the second arg is a tupple and not two arguments
    except Exception as e:
        print e

def main():
    root = Tk()
    ex = myFrame(root)
    #gps = GPS("XML/xml_2/", 165, 220)
    gps = GPS("XML/xml_2/", 1, 310)
    #gps = GPS("XML/xml_1/", 1, 410)
    
    root.geometry("600x400")
    ex.registerGPS(gps)

    def readData():
        if delay == 0:
            root.after(1000,readData)
        else:  
            vehicles = gps.pullData()
            if vehicles != None:
                ex.setListData(vehicles, gps)
                selected = ex.getSelectedString()
                ex.setLog("Current track: " + str(gps.i))
                for s in selected:
                    data = gps.getVehicleNavigationData(s)
                    if data[-1] == 'WRC':
                        sendOsc(data)
            root.after(delay,readData)  

    root.after(1,readData)
    root.mainloop()  


if __name__ == '__main__':
    client = OSC.OSCClient()
    main()  