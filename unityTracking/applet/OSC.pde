import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;

void setupOsc() {
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12001);
}

void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/car")==true) {
    int id = theOscMessage.get(0).intValue();
    float x = int(theOscMessage.get(1).floatValue()); 
    float y = int(theOscMessage.get(2).floatValue()); 
    float s = theOscMessage.get(3).floatValue();
    int d = theOscMessage.get(4).intValue();
    cars.add(id, x, y, s, d);

    return;
  }
  if (theOscMessage.checkAddrPattern("/reset")==true) {
    cars.reset();
    return;
  }
  println("### received an osc message. with address pattern "+
    theOscMessage.addrPattern()+" typetag "+ theOscMessage.typetag());
}
void oscSendCar(int id, int x, int y, float avgS, float s, String st){
  OscMessage myMessage = new OscMessage("/car");
  myMessage.add(id); 
  myMessage.add(x); 
  myMessage.add(y); 
  myMessage.add(avgS); 
  myMessage.add(s); 
  myMessage.add(st); 
  oscP5.send(myMessage, myRemoteLocation); 
}

void oscSendActiveCars(String s){ 
  OscMessage myMessage = new OscMessage("/active");
  myMessage.add(s); 
  oscP5.send(myMessage, myRemoteLocation);   
}

void oscSendReset(int id){
  OscMessage myMessage = new OscMessage("/reset");
  myMessage.add(id); 
  oscP5.send(myMessage, myRemoteLocation);   
}
