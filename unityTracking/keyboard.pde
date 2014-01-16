
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
  if (key == CODED && keyCode >=0 && keyCode < 255) {
    keyCodes[keyCode] = true;
    if (keyCode == UP) {
      if(keyCodes[ALT] == false)
        tramos.addStart();
      else
        tramos.addEnd();
      
    } 
    else if (keyCode == DOWN) {
      if(keyCodes[ALT] == false)
        tramos.subStart();
      else
        tramos.subEnd();
    } 
  }
  
  else if (key >= 0 && key < 255) {
    keys[key] = true;
    if (key == '1') {
      ref = tramos.nextFocus();
      saveSetting("focus", tramos.focus);
    }
    
     if (key == '0') {
      trackThreshold += 1;
      saveSetting("trackThreshold", trackThreshold);
    }
    
     if (key == '9') {
      trackThreshold -= 1;
      saveSetting("trackThreshold", trackThreshold);
    }
    
    if (key == 'a')
         cars.enable();
    if (key == 'A')
         cars.disable();
    
    if(key == 'r'){
      initSystem();
      mySql.remove();
    }
     if(key == 'R'){
        dX = 0;
        dY = 0;
        dZ = 0.05;
        saveSetting("dX", dX);
        saveSetting("dY", dY);
        saveSetting("dZ", dZ);
    }
  }
}


