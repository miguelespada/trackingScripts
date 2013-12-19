import processing.core.*; 
import processing.xml.*; 

import oscP5.*; 
import netP5.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class unityTracking extends PApplet {

PVector ref;

float dX;
float dY;
float dZ;
Cars cars; 
Tramos tramos;

public void setup() {
  size(800, 600);
  frameRate(30);
  smooth();
  loadSettings();

  setupOsc();
  initializeKeys();

  tramos = new Tramos();
  tramos.add(0, "0_trackUtm.txt");
  tramos.add(1, "1_trackUtm.txt");

  cars = new Cars();
  tramos.register(cars);

  dX = loadSetting("dX", 6000);
  dY = loadSetting("dY", 7500);
  dZ = loadSetting("dZ", 0.05f);
  int f = loadSetting("focus", 0);

  ref = tramos.setFocus(f);
  
  
}

public void draw() {
  background(0);
  stroke(255);
  pushMatrix();
  scale(dZ);
  translate(dX -ref.x, dY -ref.y);

  strokeWeight(1/dZ);
  tramos.draw();
  cars.update();
  cars.draw();
  popMatrix();

  cars.displayInfo(10, 20);
  tramos.drawCurrentClassification(width - 200, 20);
  tramos.drawFinalClassification(width - 100, 20);
 // cars.sendActiveCars(tramos.focus);
}

class Button {
  int x, y, a;
  boolean state = true;
  int id;
  String type;
  
  Button(String type, int id) {
    this.id = id;
    this.type = type;
    state = loadSetting(type + "_" + id, false);
  }
  
  public void setPosition(int x, int y, int a) {
    this.x = x - a;
    this.y = y + a;
    this.a = a;
  } 

  public void draw() {
    pushStyle();

    if (state)
      fill(53, 200, 87);
    else
      fill(200, 102, 48);

    noStroke();
    ellipseMode(CENTER);
    ellipse(x, y, a, a);
    popStyle();
  }
  public void mouseClicked() {
    if (dist(mouseX, mouseY, x, y)  < a / 2) {
      state = !state;
      saveSetting(type + "_" + id, state);
    }
  }
  
  public boolean getValue() {
    return state;
  }
  
  public void setValue(boolean b) {
    state = b;
  }
}

int M = 20;
int ANCHO = 200;

class Car {
  int theColor;
  PVector pos;
  int id; 
  PVector tracks[];
  int idx = 0;
  
  float speed = 0;
  int active = -1;
  ArrayList<TramoStatus> tramos;
  int time = -1;
  int pTime = -1;
  Button enabledButton;
  Button soloButton;
  boolean fresh = false;

  Car(int id) {
    this.pos = new PVector(0, 0);
    this.id = id;
    tracks = new PVector[M];
    tramos = new ArrayList<TramoStatus>();
    enabledButton = new Button("enable", id);
    soloButton = new Button("solo", id);
  }
  
  public void reset() {
    for (TramoStatus t: tramos)
      t.reset();
    
    tracks = new PVector[M];
    fresh = false;
  }
  public boolean isActive() {
    return active > 0 && PApplet.parseInt((frameCount - active)/frameRate) < 11;
  }
  
  
  public void update() {  
    for (TramoStatus t: tramos) {
      t.update();
      if (enabledButton.getValue()){
          t.sendCar(id, speed *1000/3600);
        t.drawLoop();
      }
    }
  }

  public void addPos(float x, float y) {
    pos = new PVector(x, y);
    tracks[idx] = pos;
    idx = (idx + 1) % M;
    active = frameCount;
  }

  public void draw() {
    pushStyle();
    if (enabledButton.getValue()) {
      for (int i = 0; i < M - 1; i ++) {
        int p0 = (idx + i) % M;
        int p1 = (idx + i + 1) % M;
        PVector pos0 = tracks[p0];
        PVector pos1 = tracks[p1];
        stroke(setAlpha(i));
        if (pos0 != null && pos1 != null)
          line(pos0.x, pos0.y, pos1.x, pos1.y);
      }
    }
    if (enabledButton.getValue()) {
      fill(theColor);
      if (inTrack()) stroke(255);
      else noStroke();
    }
    else {
      fill(setAlpha(1));
      noStroke();
    }

    ellipseMode(CENTER);
    ellipse(pos.x, pos.y, 18/dZ, 18/dZ);
    fill(0);
    textSize(12/dZ);
    textAlign(CENTER);
    noStroke();
    float ascent = textAscent();
    text(id, pos.x, pos.y + 5/dZ);

    for (TramoStatus t: tramos)
      t.drawProyection(theColor);
    popStyle();
  }


  public void setColor(int c) {
    theColor = c;
  }

  public float dist(PVector p) {
    return pos.dist(p);
  }

  public int setAlpha(int i) {
    return color(red(theColor), 
    green(theColor), 
    blue(theColor), 
    map(i, 0, M - 1, 50, 255) );
  }

  public void drawControls(int x, int y) {
    int a = 10;
    int xx = ANCHO + x - 2 * a;
    
    enabledButton.setPosition(xx, y, a);
    enabledButton.draw();
    soloButton.setPosition(xx, y + 2 * a, a);
    soloButton.draw();
  }

  public void mouseClicked() {
    enabledButton.mouseClicked();
    soloButton.mouseClicked();
  }

  public int drawInfo(int x, int y) {
    int s = 12;
    pushStyle();
    fill(255, 200);
    stroke(255);
    strokeWeight(1);
    rect(x - 5, y, ANCHO, s * 5);
    fill(0);
    textSize(s * 0.8f);
    textAlign(LEFT);
    text("Id: " + id + " idle time: " +  PApplet.parseInt((frameCount - active)/frameRate) + " s", x, y + s);
    text("Speed: " + PApplet.parseInt(speed) + " km/h", x, y + s * 2);

    String status = "";

    TramoStatus t = getActiveTramo();

    pushStyle();

    float dst =  t.getDistanceFromStart();   
    if (t.finish) {
      fill(0, 123, 0);
      text("Status: DONE", x, y + s * 3);
      float cTime = t.getTotalTime();
      float kmh = (dst / cTime) * 3.600f;
      text("Time: " + PApplet.parseInt(cTime) + " Dist: " + PApplet.parseInt(dst) + " Avg " + PApplet.parseInt(kmh) + " km/h", x, y + s * 5);
    }
    else if (t.running) {
      fill(0, 0, 255);
      text("Status: RUNNING", x, y + s * 3);
      float cTime =  t.getCurrentTime(); 
      float avgSpeedLastPeriod = t.getAvgSpeedOfLastPeriod(speed);
      text( "Delta speed: " + PApplet.parseInt(avgSpeedLastPeriod * 3.6f) + " km/h", x, y + s * 4);  
      float kmh = (dst / cTime) * 3.6f;
      text("Time: " + PApplet.parseInt(cTime) + " Dist: " + PApplet.parseInt(dst) + " Avg " + PApplet.parseInt(kmh) + " km/h", x, y + s * 5);
    }
    else if (t.inTrack) {
      fill(0, 255, 0);
      text("Status: WAITING", x, y + s * 3);
      text("time: " + 0, x, y + s * 4);
    }
    else {
      fill(0);
      text("Status: OUT", x, y + s * 3);
    }

    popStyle();

    popStyle();
    return s*5;
  }
  public void registerTramo(Tramo t) {
    TramoStatus tramo = new TramoStatus(this, t);
    tramos.add(tramo);
  }
  public boolean inTrack() {
    for (TramoStatus t: tramos)
      if (t.inTrack) return true;
    return false;
  }

  public TramoStatus getActiveTramo() {
    for (TramoStatus t: tramos)
      if (t.t.inFocus()) return t;
    return null;
  }
  public boolean isInTramo(int id) {
      Tramo activeTramo = getActiveTramo().t;
      return activeTramo.id == id && getActiveTramo().inTrack;
  }
  
  public float getActiveDistance(){
     TramoStatus t = getActiveTramo();
     return PApplet.parseInt(t.getDistanceFromStart());
  }
  
  public boolean enabled(){
    return enabledButton.getValue();
  }
  
  public boolean solo(){
    return soloButton.getValue();
  }
  public void unSolo(){
    soloButton.setValue(false);
  }
  
  public boolean finished(int tramoId){
    TramoStatus t = getActiveTramo();
    return t.finish && t.t.id == tramoId;
  }
  public boolean running(int tramoId){
    TramoStatus t = getActiveTramo();
    return t.running && t.t.id == tramoId;
  }
  public float getEndTime(){
    TramoStatus t = getActiveTramo();
    return t.getEndTime();
  }
  public void drawLoop(int tId){
     for (TramoStatus t: tramos)
      if (t.t.id == tId) t.drawLoop();
  }
  public void resetLoop(int tId){
     for (TramoStatus t: tramos)
      if (t.t.id == tId) t.resetLoop();
  }
}  

int N = 25;
int[] carColors = {
  0xffFF244C, 0xffFF24F5, 0xff7724FF, 
  0xff244AFF, 0xff24BBFF, 0xff24FFBF, 
  0xff24FF3B, 0xffD2FF24, 0xffFFB624, 
  0xffFF3624
};

class Cars {
  Car cars[];
  Car solo = null;
  Cars() {
    cars = new Car[N];
    for (int i = 0; i < N; i++) {
      cars[i] = new Car(i);
      cars[i].setColor(carColors[i % carColors.length]);
    }
  }
  public void update() {
    for (int i = 0; i < N; i++) {
      cars[i].update();
    }
    updateSolo();
  }
  public void add(int id, float x, float y, float s, int d){
    if(cars[id].time == d) 
      return;
    cars[id].fresh = true; 
    cars[id].addPos(x, y);
    cars[id].speed = s;
    cars[id].pTime = cars[id].time;
    cars[id].time = d;
  }
  
  public void updateSolo(){
    boolean isSolo = false;
    for(int i = 0; i < N; i++){
      if(cars[i].solo()){
        isSolo = true;
        if(solo == null)
          solo = cars[i];
        if(solo != cars[i])
          cars[i].unSolo();
      }
    }
    if(!isSolo) solo = null;
  }
  public void draw() {
    if(solo != null)
       solo.draw();
    else{
      for (int i = 0; i < 25; i++) {
        if (cars[i].isActive())
          cars[i].draw();
      }
    }
  }

  
  public void displayInfo(int x, int y) {
    for (int i = 0; i < 25; i++) {
      if (cars[i].isActive()) {
        int nextY = y + cars[i].drawInfo(x, y);
        cars[i].drawControls(x, y);
        y = nextY;
      }
    }
  }
  
  public void registerTramo(Tramo t) {
    for (int i = 0; i < 25; i++) 
      cars[i].registerTramo(t);
  }
  
  public void reset() {
    for (int i = 0; i < 25; i++) 
      cars[i].reset();
  }
  
  public void mouseClicked() {
    for (int i = 0; i < 25; i++) 
      cars[i].mouseClicked();
  }
  
  public ArrayList<Car> getActiveCars(int tramoId) {
    ArrayList<Car> active = new ArrayList<Car>();
    for (int i = 0; i < 25; i++) {
      if (cars[i].isInTramo(tramoId) && cars[i].enabled())
        active.add(cars[i]);
    }
    return active;
  }
  
  public ArrayList<Car> getFinalizedCars(int tramoId) {
    ArrayList<Car> active = new ArrayList<Car>();
    for (int i = 0; i < 25; i++) {
      if (cars[i].finished(tramoId) && cars[i].enabled())
        active.add(cars[i]);
    }
    return active;
  }
  
  public ArrayList<Car> getRunningOrFinishCars(int tramoId) {
    ArrayList<Car> active = new ArrayList<Car>();
    for (int i = 0; i < 25; i++) {
      if ((cars[i].finished(tramoId) 
         || cars[i].running(tramoId)) 
        && cars[i].enabled())
        active.add(cars[i]);
    }
    return active;
  }
  
  
  public void sendActiveCars(int tramoId){
    ArrayList<Car> active = getActiveCars(tramoId);
    String s = "";
    for(Car c: active){
      s += c.id;
      s += " ";
    }
    oscSendActiveCars(s);
  
  }
  public void drawLoop(int t){
  for (int i = 0; i < 25; i++) 
      cars[i].drawLoop(t);
  }
  public void resetLoop(int t){
  for (int i = 0; i < 25; i++) 
      cars[i].resetLoop(t);
  }
}

class LoopPoint {
  PVector pos;
  float time;
  float distance;
  float speed;
  float avgSpeed;
  LoopPoint() {
    pos = new PVector(0, 0);
    time = 0;
    distance = 0;
    speed = 0;
  }
  LoopPoint(PVector pos, float time, float distance, float speed) {
    this.pos = pos;
    this.time = time;
    this.distance = distance;
    this.speed = speed;
    this.avgSpeed = avgSpeed;
  }
}
class LoopTrack {

  ArrayList<LoopPoint> loopTrack;
  LoopPoint pos;
  Tramo tramo;
  int drawIdx = 0;

  LoopTrack(Tramo t) {
    loopTrack = new ArrayList<LoopPoint>();
    reset();
    this.tramo = t;
  } 

  public void reset() {
    loopTrack.clear();
    pos = new LoopPoint();
  }

  public void add(PVector p, float time, float speed) {
    if (p.x != pos.pos.x && p.y != pos.pos.y) {
      float dst = tramo.getDistanceFromStart(p);
      pos = new LoopPoint(new PVector(p.x, p.y), time, dst, speed);
      loopTrack.add(pos);
    }
  }

  public float getDistanceFromStart() {
    return pos.distance;
  }

  public float calculateAvgSpeedOfLastPeriod() {
    if (loopTrack.size() > 1) {
      LoopPoint prev = loopTrack.get(loopTrack.size() - 2);
      if (pos.time - prev.time == 0) return 0;

      return (pos.distance - prev.distance)/(pos.time - prev.time);
    }
    else {
      return -1;
    }
  }
  

  public float getStartTime() {
    if(loopTrack.size() == 0) return 0;
    return loopTrack.get(0).time;
  }
  public float getEndTime() {
    if(loopTrack.size() == 0) return 0;
    return loopTrack.get(loopTrack.size() - 1).time;
  }
  public float getTotalTime() {
    return getEndTime() - getStartTime();
  }

  public float getCurrentTime() {
    return pos.time - getStartTime();
  }
  public void drawLoop(int carId){
    if(frameCount % 60 != 0) return;
    if(drawIdx < loopTrack.size()){
      LoopPoint lp = loopTrack.get(drawIdx);
      String st = "normal";
      if(drawIdx == 0)
        st = "first"; 
        
      float avg = 0;    
      if(drawIdx > 0 ) {
         LoopPoint prev = loopTrack.get(drawIdx - 1);
         if(lp.time - prev.time != 0)
           avg = (lp.distance - prev.distance)/(lp.time - prev.time);
      }
      oscSendCar(carId, PApplet.parseInt(lp.pos.x - tramo.getStart().x), 
                        PApplet.parseInt(lp.pos.y - tramo.getStart().y), 
                        avg, 
                        lp.speed, 
                        st);
                        
      println(carId + "--- Drawing loop " + st + " " + drawIdx + " " + 
                 avg + " " +
                 PApplet.parseInt(lp.pos.x - tramo.getStart().x) + " " +
                 PApplet.parseInt(lp.pos.y - tramo.getStart().y) );
      drawIdx += 1;
    }
  }
  public void resetLoop(){
    drawIdx = 0;
  }
}



OscP5 oscP5;
NetAddress myRemoteLocation;

public void setupOsc() {
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12001);
}

public void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/car")==true) {
    int id = theOscMessage.get(0).intValue();
    float x = PApplet.parseInt(theOscMessage.get(1).floatValue()); 
    float y = PApplet.parseInt(theOscMessage.get(2).floatValue()); 
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
public void oscSendCar(int id, int x, int y, float avgS, float s, String st){
  OscMessage myMessage = new OscMessage("/car");
  myMessage.add(id); 
  myMessage.add(x); 
  myMessage.add(y); 
  myMessage.add(avgS); 
  myMessage.add(s); 
  myMessage.add(st); 
  oscP5.send(myMessage, myRemoteLocation); 
}

public void oscSendActiveCars(String s){ 
  OscMessage myMessage = new OscMessage("/active");
  myMessage.add(s); 
  oscP5.send(myMessage, myRemoteLocation);   
}

public void oscSendReset(int id){
  OscMessage myMessage = new OscMessage("/reset");
  myMessage.add(id); 
  oscP5.send(myMessage, myRemoteLocation);   
}
int trackThreshold = 20;
int endThreshold = 500;

class TramoStatus {
  Tramo t;
  Car car;

  boolean inTrack = false;
  boolean running = false;
  boolean finish = false;

  float pdStart, dStart, pdEnd, dEnd;
  PVector proyection, pProyection;
  LoopTrack loopTrack;

  TramoStatus(Car c, Tramo t) {
    this.t = t;
    this.car = c;
    loopTrack = new LoopTrack(this.t);
    reset();
  }

  public void reset() {
    inTrack = false;
    running = false;
    finish = false;
    loopTrack.reset();
    proyection = new PVector();
    pProyection = new PVector();
    pdStart = 1000000;
    dStart = 1000000;
    pdEnd = 1000000;
    dEnd = 1000000;
  }

  public PVector updateProyection(PVector pos) {
    return t.getClosest(pos);
  }

  public boolean updateInTrack() {
    return car.pos.dist(proyection) < trackThreshold;
  }

  public boolean updateStart() {  
    dStart = t.distToStart(car.pos);
    if (inTrack && 
      !running && 
      dStart + trackThreshold > pdStart && 
      car.speed > 30) {
      return true;
    }
    pdStart = dStart;
    return false;
  }
  public boolean updateEnd() {
    dEnd = t.distToEnd(car.pos);

    if (!inTrack && running && dEnd < endThreshold) 
      return true;
    
    pdEnd = dEnd;
    return false;
  }

  public void update() {
    if(finish) 
      return;
      
    pProyection.x =  proyection.x;
    pProyection.y =  proyection.y;

    proyection = updateProyection(car.pos);
    if (car.fresh = true) {
      inTrack = updateInTrack();
      if (!running) {
        running = updateStart(); 
        if (running) {
          oscSendReset(car.id);
          loopTrack.reset();
          println((pProyection.x - t.getStart().x) + " " +  (pProyection.y - t.getStart().y));
          loopTrack.add(pProyection, car.pTime, 0);
        }
        
        car.fresh = false;
      }
      
      if(running) {
        loopTrack.add(proyection, car.time, car.speed);
      }

      finish = updateEnd(); 
      if (finish) {
        inTrack = false;
        running = false;
      }
    }
  }


  public void drawProyection(int c) {
    if (inTrack) {
      pushStyle();
      rectMode(CENTER);
      noStroke();
      fill(0);
      rect(proyection.x, proyection.y, 2/dZ, 2/dZ);
      popStyle();
    }
  }
  public float getDistanceFromStart() {
    if (inTrack && !running) return 0;
    return loopTrack.getDistanceFromStart();
  }

  public float getTotalTime() {
    return loopTrack.getTotalTime();
  }

  public float getCurrentTime() {
    return loopTrack.getCurrentTime();
  }
  
  public float getEndTime() {
    return loopTrack.getEndTime();
  }
  
  public float getAvgSpeedOfLastPeriod(float speed) {
    float avgSpeed = loopTrack.calculateAvgSpeedOfLastPeriod();
    if (avgSpeed == -1) avgSpeed = speed;
    return avgSpeed;
  }
  
  public void sendCar(int id, float speed) {
    if (t.inFocus() && inTrack) {
//      oscSendCar(id, 
//      int(proyection.x - t.getStart().x), 
//      int(proyection.y - t.getStart().y), 
//      getAvgSpeedOfLastPeriod(speed), 
//      speed, "current");
         println("Drawing normal " + getAvgSpeedOfLastPeriod(speed) + " " +
         PApplet.parseInt(proyection.x - t.getStart().x) + " " + 
          PApplet.parseInt(proyection.y - t.getStart().y));

    }
  }
  public void drawLoop(){
    loopTrack.drawLoop(car.id);
  }
   public void resetLoop(){
    loopTrack.resetLoop();
  }
}

class Tramos {
  ArrayList<Tramo> tramos;
  int focus = -1;
  Tramos() {
    tramos = new ArrayList<Tramo>();
  }
  public void add(int id, String name) {
    Tramo t = new Tramo(id);
    t.loadData(name);
    tramos.add(t);
  }
  public PVector setFocus(int i) {
    this.focus = i;
    PVector r = null; 
    for (Tramo t: tramos) {
      if (t.id == focus) {
        t.setFocus(true);
        r = t.getStart();
      }
      else {
        t.setFocus(false);
      }
    }
    return r;
  }
  public PVector nextFocus() {
    focus = (focus + 1) % tramos.size();
    return setFocus(focus);
  }

  public void register(Cars cars) {
    for (Tramo t: tramos)
      cars.registerTramo(t);
  }
  public void draw() {
    for (Tramo t: tramos){
      t.draw();
      if(t.inFocus()){
        t.calculateCurrentClassification();
        t.calculateFinalClassification();
      }
    }
  }
  
  public void drawCurrentClassification(int x, int y) {
    for (Tramo t: tramos){
      if(t.inFocus())
        t.drawCurrentClassification(x, y);
    }
  }
   public void drawFinalClassification(int x, int y) {
    for (Tramo t: tramos){
      if(t.inFocus())
        t.drawFinalClassification(x, y);
    }
  }
  
}


boolean keys[];
boolean keyCodes[];

public void initializeKeys() {
  keys = new boolean[255];
  keyCodes = new boolean[255];
  for (int i = 0; i < 255; i ++) {
    keys[i] = false;
    keyCodes[i] = false;
  }
}
public void keyPressed() {

  if (key == CODED && keyCode >=0 && keyCode < 255) {
    keyCodes[keyCode] = true;
  }
  else if (key >= 0 && key < 255) {
    keys[key] = true;
    if (key == '1') {
      ref = tramos.nextFocus();
      saveSetting("focus", tramos.focus);
    }
    if(key == 'l'){
      println("Reseting loop");
      cars.resetLoop(1);
    }
  }
}
public void keyReleased() {

  if (key == CODED && keyCode >=0 && keyCode < 255) 
    keyCodes[keyCode] = false;
  
  else if (key >= 0 && key < 255) 
    keys[key] = false;
  
}

public void mouseDragged() {
  if (keyPressed && key == 'z') {
    dZ += (pmouseY - mouseY) / PApplet.parseFloat(height);
    if (dZ <= 0.001f) dZ = 0.001f;
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
public void mouseClicked(){
   cars.mouseClicked(); 
}

String settingsFile = "mySettings.txt";
HashMap settings = new HashMap();

public String loadSetting(String id, String defaultValue) {
  String v = (String)settings.get(id);
  if (v == null) return defaultValue;
  return v;
}
public int loadSetting(String id, int defaultValue) {
  String v = (String)settings.get(id);
  if (v == null) return defaultValue;
  return PApplet.parseInt(v);
}
public boolean loadSetting(String id, boolean defaultValue) {
  String v = (String)settings.get(id);
  if (v == null) return defaultValue;
  return PApplet.parseBoolean(v);
}

public float loadSetting(String id, float defaultValue) {
  String v = (String)settings.get(id);
  if (v == null) return defaultValue;
  return PApplet.parseFloat(v);
}

public void saveSetting(String id, String value) {
  settings.put(id, value);
  saveSettings();
}
public void saveSetting(String id, int value) {
  settings.put(id, (new Integer(value)).toString());
  saveSettings();
}
public void saveSetting(String id, float value) {
  settings.put(id, (new Float(value)).toString());
  saveSettings();
}
public void saveSetting(String id, boolean value) {
  settings.put(id, (new Boolean(value)).toString());
  saveSettings();
}

//------------------
//------------------
//------------------

public void loadSettings() {
  String[] list = loadStrings(settingsFile);
  for (int i = 0; i < list.length; i++) {
    String[] tokens = list[i].split(" ");
    settings.put(tokens[0], tokens[1]);
  }
}
public void saveSettings() {
  PrintWriter output;
  output = createWriter(settingsFile);

  Iterator i = settings.entrySet().iterator();  
  while (i.hasNext ()) {
    Map.Entry me = (Map.Entry)i.next();
    output.println(me.getKey() + " " + me.getValue());
  }
  output.close();
}

class TramoPoint {
  PVector pos;
  float dst;
  float accSpeed;
  float n = 0;
  
  TramoPoint(PVector pos, float dst) {
    this.dst = dst;
    this.pos = pos;
    this.accSpeed = 0;
    this.n = 0;
  }
  
  public void addAvg(float avg){
    this.accSpeed += avg;  
    this.n += 1;
  }
  public float getAvg(){
    return accSpeed/n;
  }
}

class Tramo {

  ArrayList<TramoPoint> data;
  TramoPoint end, start;
  int n;
  int id;
  boolean bFocus = false;

  ArrayList<Car> clasification;
  ArrayList<Car> finalClasification;

  Tramo(int id) {
    this.id = id;
    clasification = new ArrayList<Car>();
    finalClasification = new ArrayList<Car>();
  }

  public boolean inFocus() {
    return bFocus;
  }

  public void loadData(String fileName) {
    String lines[] = loadStrings(fileName);
    n = lines.length;
    data = new ArrayList<TramoPoint>();
    float dst = 0;
    for (int i = 0 ; i < n; i++) {
      String[] tokens = splitTokens(lines[i]);
      PVector pos = new PVector(PApplet.parseInt(tokens[0]), PApplet.parseInt(tokens[1]));
      if (i > 1)
        dst += data.get(i - 1).pos.dist(pos);
      data.add(new TramoPoint(pos, dst));
    }
    if (n > 0) {
      start = data.get(0);
      end = data.get(data.size() - 1);
    }
  }
  public void draw() {
    
 //   colorMode(HSB, 360, 100, 100);
    int opacity = 255;
    if (!bFocus)
      opacity = 50;


    for (int i = 0 ; i < n - 1; i++) {
      float x0 = data.get(i).pos.x;
      float y0 = data.get(i).pos.y;
      float x1 = data.get(i + 1).pos.x;
      float y1 = data.get(i + 1).pos.y;
      float a = data.get(i).getAvg();
      strokeWeight(10);
//      if (a == 0) 
//        stroke(0, opacity);
//      else{
//        float v = map(a, 0, 120, 0, 255);
//        stroke(v, opacity);
//      }
      stroke(255, opacity);
      point(x0, y0);
      line(x0, y0, x1, y1);
    }
    pushStyle();
    fill(255, 0, 0);
    noStroke();
    ellipse(start.pos.x, start.pos.y, 10, 10);
    fill(0, 255, 0);
    noStroke();
    ellipse(end.pos.x, end.pos.y, 10, 10); 
    popStyle();
    colorMode(RGB);
  }

  public void setFocus(boolean b) {
    bFocus = b;
  }

  public float getDistanceFromStart(PVector pos) {
    for (TramoPoint p: data) {
      if(p.pos.equals(pos))
        return p.dst;
    }
    return -1;
  }
  public void propagateAverages(PVector i, PVector o, float avg){
     boolean found = false;
     
     for (TramoPoint p: data) {
      if(found || p.pos.equals(i))  
        found = true;
      
      if(found)
        p.addAvg(avg);  
      if(found && p.pos.equals(o))  
        found = false;
     }  
    
  }
  
  public PVector getClosest(PVector pos){
   float minDist = 10000000;
   PVector proyection = null;
    for (TramoPoint p: data) {
      float d = pos.dist(p.pos);
      if (d < minDist) {
        proyection = p.pos;
        minDist = d;
      }
    }
    return proyection;
  }
  public float distToStart(PVector pos){
    return pos.dist(start.pos);
  }
  
  public float distToEnd(PVector pos){
    return pos.dist(end.pos);
  }
  public PVector getStart(){
    return start.pos;
  }

  public void calculateCurrentClassification() {
    ArrayList<Car> activeCars = cars.getActiveCars(id);
    clasification.clear();
    for (Car c: activeCars) {
      int i = 0;
      float d = c.getActiveDistance();
      while (i < clasification.size ()) {
        if (d > clasification.get(i).getActiveDistance())
          break;
        else
          i ++;
      }
      clasification.add(i, c);
    }
  }

  public void calculateFinalClassification() {
    ArrayList<Car> finalizedCars = cars.getFinalizedCars(id);
    finalClasification.clear();
    for (Car c: finalizedCars) {
      int i = 0;
      float d = c.getEndTime();
      while (i < finalClasification.size ()) {
        if (d < finalClasification.get(i).getEndTime())
          break;
        else
          i ++;
      }
      finalClasification.add(i, c);
    }
  }


  public void drawCurrentClassification(int x, int y) {
    pushStyle();
    stroke(255);
    fill(255);
    textSize(10);
    String s = "TRAMO (dst) - " + id + "\n" ;
    for (Car c: clasification) {
      s += c.id + "   " + PApplet.parseInt(c.getActiveDistance());
      s += " m \n";
    }
    text(s, x, y);
    popStyle();
  }

  public void drawFinalClassification(int x, int y) {
    pushStyle();
    stroke(255);
    fill(255);
    textSize(10);
    String s = "TRAMO (time) - " + id + "\n" ;
    for (Car c: finalClasification) {
      s += c.id + "   " + PApplet.parseInt(c.getEndTime());
      s += " s \n";
    }
    text(s, x, y);
    popStyle();
  }
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "unityTracking" });
  }
}
