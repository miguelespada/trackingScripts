#!/usr/bin/python2.7
# -*- coding: utf-8 -*-
import utm

import Tkinter, Tkconstants, tkFileDialog

def convertGeo2utm(f, g):
    try:
        lines = f.readlines()
        for l in lines:
            tokens = l.split(' ')
            u = utm.from_latlon(float(tokens[1]), float(tokens[0]))
            g.write(str(u[1]) + " " +  str(u[0]))
            g.write(" " + str(float(tokens[2])) + " " + str(u[2]) + " " +str(u[3]) + "\n")
        return 1
    except:
        return -1

def convertAscii2raw(f, g):
    try:
        lines = f.readlines()
        lines = lines[0].replace('\r','\n')
        lines = lines.replace(' m','')
        lines = lines.replace('\t',' ')
        tokens = lines.split()
        tokens = tokens[4:]
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
    b.place(x=20, y=20, width = 120, height = 40 )

    b = Tkinter.Button(self, text='UTM to ASCII', command=self.utm2ascii)    
    b.place(x=140, y=20, width = 120, height = 40 )

    b = Tkinter.Button(self, text='Geo to UTM', command=self.geo2utm)
    b.place(x=260, y=20, width = 120, height = 40 )



    self.var = Tkinter.StringVar()
    self.label = Tkinter.Label(self, text=0, textvariable=self.var)        
    self.label.place(x=0, y=100-20, width = 600)
   
  def ascii2raw(self):
    filename = tkFileDialog.askopenfilename()
    filenameOutput = filename[:-4] + "_raw.txt" 
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

if __name__=='__main__':
  root = Tkinter.Tk()
  root.geometry("600x100+0+0")
  TkFileDialogExample(root).pack()
  root.mainloop()

