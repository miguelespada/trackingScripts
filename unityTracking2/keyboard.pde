
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
void keyPressed() {
  lastActivity  =millis();
  if (key == CODED && keyCode >=0 && keyCode < 255) {
    keyCodes[keyCode] = true;
    if (keyCode == UP) {
      if(keyCodes[ALT] == false)
        tramos.addStart();
      else
        tramos.addEnd();
      
      tramos.write();
    } 
    else if (keyCode == DOWN) {
      if(keyCodes[ALT] == false)
        tramos.subStart();
      else
        tramos.subEnd();
      tramos.write();
  
    } 
    
  }
  else if (key >= 0 && key < 255) {
    keys[key] = true;
    if (key == '1') {
      ref = tramos.nextFocus();
      saveSetting("focus", tramos.focus);
    }
    
    if (key == 'a'){
       if(keyCodes[SHIFT])
         cars.disable();
       else 
         cars.enable();
    }
    if(key == 'r'){
      initSystem();
      clearMySQL();
      removeMySQL();
    }
  }
}
void keyReleased() {

  if (key == CODED && keyCode >=0 && keyCode < 255) 
    keyCodes[keyCode] = false;
  
  else if (key >= 0 && key < 255) 
    keys[key] = false;
  
}

