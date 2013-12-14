
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

  if (key == CODED && keyCode >=0 && keyCode < 255) {
    keyCodes[keyCode] = true;
  }
  else if (key >= 0 && key < 255) {
    keys[key] = true;
    if (key == '1') 
      ref = tramos.nextFocus();
      saveSetting("focus", tramos.focus);
  }
}
void keyReleased() {

  if (key == CODED && keyCode >=0 && keyCode < 255) 
    keyCodes[keyCode] = false;
  
  else if (key >= 0 && key < 255) 
    keys[key] = false;
  
}

