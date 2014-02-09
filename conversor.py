#!/usr/bin/python2.7
# -*- coding: utf-8 -*-
import utm

import Tkinter, Tkconstants, tkFileDialog
 
import pyproj
wgs84=pyproj.Proj("+init=EPSG:4326")
utm31=pyproj.Proj("+init=EPSG:32631")
utm32=pyproj.Proj("+init=EPSG:32632")
nad27 = pyproj.Proj("+init=EPSG:4267")

utmRef=pyproj.Proj("+init=EPSG:32633")

def convertGeo2utm(f, g):
    try:
        lines = f.read()
        lines = lines.split(' ')
        for l in lines:
            tokens = l.split(',')
            # u = utm.from_latlon(float(tokens[1]), float(tokens[0]))
            # g.write(str(u[1]) + " " +  str(u[0]))
            # g.write(" " + str(float(tokens[2])) + " " + str(u[2]) + " " +str(u[3]) + "\n")
            x, y = float(tokens[0]), float(tokens[1])
            #x, y = pyproj.transform(wgs84, nad27, x, y)
            a = pyproj.transform(wgs84, utmRef, x, y)
            g.write(str(a[1]) + " " +  str(a[0]))
            g.write(" " + str(float(tokens[2])) + " 33 X\n")
        return 1
    except Exception as e:
        print e
        return -1

def convertAscii2raw(f, g):
    try:
        lines = f.readlines()
        lines = lines[0].replace('\r','\n')
        lines = lines.replace(' m','')
        lines = lines.replace('\t',' ')
        tokens = lines.split()
        tokens = tokens[4:]
        print tokens
        for x in range(len(tokens)/4):
            g.write(tokens[(x * 4)+ 3]) 
            g.write(" ")
            g.write(tokens[(x * 4) + 1])
            g.write(" ")
            g.write(tokens[(x * 4) + 2])
            g.write("\n")
        return 1
    except:
        return -1

def convertUtm2ascii(f, g):
    try:
        lines = f.readlines()

        g.write("Point\tX\tY\tZ\n")
        refX = 0
        refY = 0
        n = 0
        for l in lines:
            tokens = l.split()
            y = float(tokens[0])
            x = float(tokens[1])
            if n == 0:
                refX = x
                refY = y
            g.write(str(n))
            g.write("\t")
            g.write(str(x - refX))
            g.write(" m")
            g.write("\t")
            g.write('0')
            g.write(" m")
            g.write("\t")
            g.write(str(y - refY))
            g.write(" m")
            g.write("\n")
            n += 1
        return 1
    except:
        return -1

class TkFileDialogExample(Tkinter.Frame):

  def __init__(self, root):

    Tkinter.Frame.__init__(self, root)
    root.title("UTM batch conversor")
    self.pack(fill= Tkinter.BOTH, expand=1)
    b = Tkinter.Button(self, text='ASCII to UTM', command=self.ascii2raw)
    b.place(x=20, y=60, width = 120, height = 40 )

    # b = Tkinter.Button(self, text='UTM to ASCII', command=self.utm2ascii)    
    # b.place(x=140, y=20, width = 120, height = 40 )

    b = Tkinter.Button(self, text='Geo to UTM', command=self.geo2utm)
    b.place(x=20, y=20, width = 120, height = 40 )



    self.var = Tkinter.StringVar()
    self.label = Tkinter.Label(self, text=0, textvariable=self.var, wraplength= 120)        
    self.label.place(x=0, y=100, width = 120 )
   
  def ascii2raw(self):
    filename = tkFileDialog.askopenfilename()
    filenameOutput = filename.replace("_ascii", "")
    if filename:
      f = open(filename, 'r')
      g = open(filenameOutput, 'w')
      r = convertAscii2raw(f, g)
      if r == 1:
        self.var.set("Wrote: " + filenameOutput)
      else:
        self.var.set("Error: converting " + filename)
      f.close()
      g.close()

  def utm2ascii(self):
    filename = tkFileDialog.askopenfilename()
    filenameOutput = filename[:-4] + "_ascii.txt" 
    if filename:
      f = open(filename, 'r')
      g = open(filenameOutput, 'w')
      r = convertUtm2ascii(f, g)
      if r == 1:
        self.var.set("Wrote: " + filenameOutput)
      else:
        self.var.set("Error: converting " + filename)
      f.close()
      g.close()
  
  def geo2utm(self):
    filename = tkFileDialog.askopenfilename()
    filenameOutput = filename[:-4] + "_utm.txt" 
    if filename:
      f = open(filename, 'r')
      g = open(filenameOutput, 'w')
      r = convertGeo2utm(f, g)
      if r == 1:
        self.var.set("Wrote: " + filenameOutput)
      else:
        self.var.set("Error: converting " + filename)
      f.close()
      g.close()
      f = open(filenameOutput, 'r')
      filenameOutput = filename[:-4] + "_ascii.txt" 
      g = open(filenameOutput, 'w')
      r = convertUtm2ascii(f, g)
      if r == 1:
        self.var.set("Wrote: " + filenameOutput)
      else:
        self.var.set("Error: converting " + filename)
      f.close()
      g.close()

if __name__=='__main__':
  root = Tkinter.Tk()
  root.geometry("200x250+0+0")
  TkFileDialogExample(root).pack()
  root.mainloop()

