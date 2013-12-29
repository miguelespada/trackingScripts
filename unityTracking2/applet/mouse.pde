void mouseDragged() {
  if (keyPressed && key == 'z') {
    dZ += (pmouseY - mouseY) / float(height);
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

