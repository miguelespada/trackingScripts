void mouseDragged() {

  lastActivity  =millis();
  if (keyPressed && key == 'z') {
    dZ += (pmouseY - mouseY) / (height * 10.0);
    if (dZ <= 0.001) dZ = 0.001;
    saveSetting("dZ", dZ);

  }
  else {
    if(keyCodes[SHIFT]){
      dX -= (pmouseX - mouseX) / dZ;
      dY -= (pmouseY - mouseY) / dZ;
      saveSetting("dX", dX);
      saveSetting("dY", dY);
    }
  }
}
void mouseClicked(){   
  lastActivity  =millis();
   cars.mouseClicked(); 
}

