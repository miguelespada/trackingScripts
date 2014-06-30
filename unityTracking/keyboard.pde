boolean keys[];
boolean keyCodes[];

void initializeKeys() {
  keys = new boolean[255];
  keyCodes = new boolean[255];
  for (int i = 0; i < 255; i ++) {
    keys[i] = false;
    keyCodes[i] = false;
  }
}

void keyReleased() {
  if (key == CODED && keyCode >=0 && keyCode < 255) 
    keyCodes[keyCode] = false;
  
  else if (key >= 0 && key < 255) 
    keys[key] = false;
}

void keyPressed() {
  lastActivity  =millis();
 
  if (key == CODED && keyCode >=0 && keyCode < 255) 
    keyCodes[keyCode] = true;
    
  if (key >= 0 && key < 255) 
    keys[key] = true;
  
  if (key == CODED && keyCode == UP) {
      if(keys['e']) tramos.addEnd(1);
      if(keys['i']) tramos.addStart(1);
      if(keys['t']) {
        trackThreshold += 1;
        saveSetting("trackThreshold", trackThreshold);
      }
      if(keys['1']) {
        tramos.changeFocus(1);
        saveSetting("focus", tramos.focus);
         dX = 0;
        dY = 0;
        saveSetting("dX", dX);
        saveSetting("dY", dY);
      }
    } 
    else if (key == CODED &&  keyCode == DOWN) {
      if(keys['e']) tramos.addEnd(-1);
      if(keys['i']) tramos.addStart(-1);
      if(keys['t']) {
        trackThreshold -= 1;
        saveSetting("trackThreshold", trackThreshold);
      }
      if(keys['1']) {
        tramos.changeFocus(-1);
        saveSetting("focus", tramos.focus); 
        dX = 0;
        dY = 0;
        saveSetting("dX", dX);
        saveSetting("dY", dY);
      }
    } 

    
    if(key == 'I')
      tramos.setInitTime();
    else if(key == 'E')
      tramos.setEndTime();
    else if(key == 'q')
      rt.toggle();
    else if(key == 'a')
      rt.reset();
    else if(key == 'M')
      rt.offset(60);
    else if(key == 'O')
      rt.maxOffset();
    else if(key == 'R'){
      cars.reset();
      mysql.remove();
      rt.running = false;
      bProcess = false;
    }
     if(key == 'C'){
        dX = 0;
        dY = 0;
        dZ = 0.05;
        saveSetting("dX", dX);
        saveSetting("dY", dY);
        saveSetting("dZ", dZ);
    }
    
   if (key == ' ') {
       bProcess = !bProcess;
    }
    
    
}


