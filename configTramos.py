#!/usr/bin/python2.7
# -*- coding: utf-8 -*-

from ttk import *
from Tkinter import *
import tkFileDialog

host = "/Applications/MAMP/htdocs/unity/Tramos/"
class Tramo:
    name =  ""
    real =  ""
    teorico = ""
    start = 0
    end = 0
    def __str__(self):
        return self.name + "," + self.teorico + "," + self.real + "," + str(self.start) + "," + str(self.end)


tramos = []
f = open(host + "tramos.txt", 'r')

lines = f.readlines()
for l in lines:
    tokens = l.split(',')
    t = Tramo()
    t.name = tokens[0]
    t.teorico = tokens[1]
    t.real = tokens[2]
    t.start = int(tokens[3])
    t.end = int(tokens[4])
    tramos.append(t)

class TkFileDialogExample(Frame):
    def __init__(self, root):

        Frame.__init__(self, root)        


        self.lb= Listbox(self, width= 20, relief = RAISED, exportselection=0)
        self.lb.pack(side=TOP, padx=5, pady=5)  

        for t in tramos: 
            print t
            self.lb.insert(END, str(t))   

        # options for buttons
        button_opt = {'padx': 5, 'pady': 5}

        Button(self, text='Teorico', command=self.openTeorico).pack(**button_opt)
        
        self.teorico = StringVar()
        label = Label(self, text=0, textvariable=self.teorico)        
        label.pack()

        Button(self, text='Real', command=self.openReal).pack(**button_opt)
        self.real = StringVar()
        label = Label(self, text=0, textvariable=self.real)        
        label.pack()


    def openTeorico(self):
        filename = tkFileDialog.askopenfilename()
        name = filename.split('/')[-1]
        self.teorico.set(name)

    def openReal(self):
        filename = tkFileDialog.askopenfilename()
        name = filename.split('/')[-1]
        self.real.set(name)
        



if __name__=='__main__':
  root =  Tk()
  TkFileDialogExample(root).pack()
  root.mainloop()