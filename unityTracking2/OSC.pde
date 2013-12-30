import oscP5.*;
import netP5.*;
OscP5 oscP5;

void setupOsc() {
  oscP5 = new OscP5(this, 12000);
}


void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/car")==true) {
    int id = theOscMessage.get(0).intValue();
    float x = int(theOscMessage.get(1).floatValue()); 
    float y = int(theOscMessage.get(2).floatValue()); 
    float s = theOscMessage.get(3).floatValue() ;
    int d = theOscMessage.get(4).intValue();
    cars.addData(id, x, y, s, d);
    return;
  }
  
  if (theOscMessage.checkAddrPattern("/reset")==true) {
    initSystem();
    cars.removeLoops();
    return;
  }
  
  println("### received an osc message. with address pattern "+
    theOscMessage.addrPattern()+" typetag "+ theOscMessage.typetag());
}
