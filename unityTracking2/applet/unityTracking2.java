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

public class unityTracking2 extends PApplet {

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
  
  dX = loadSetting("dX", 6000);
  dY = loadSetting("dY", 7500);
  dZ = loadSetting("dZ", 0.05f);
  int f = loadSetting("focus", 0);

  tramos = new Tramos("tramos.txt");
  ref = tramos.setFocus(f);
  
  cars = new Cars();
  cars.registerTramos(tramos);
  cars.loadCars("cars.txt");
  cars.loadLoops();
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
 
  cars.displayInfo(tramos.focus, 10, 20, 255);

}

int M = 20;
int ANCHO = 200;


class Car {
  int theColor;
  PVector pos;
  int id; 
  float speed;
  
  PVector tracks[];
  int idx;
  float time, pTime;
  int lastActiveFrame;
  boolean fresh;
  String name;
  
  ArrayList<TramoStatus> tramos;


  Car(int id, String name) {
    this.name = name;
    this.id = id;
    this.pos = new PVector(0, 0);
    tracks = new PVector[M];
    idx = 0;
    time = 0;
    pTime = 0;
    lastActiveFrame = -1;
    fresh = false;
    tramos = new ArrayList<TramoStatus>();
    
  }
  
  
  public void addPoint(float x, float y, float s, int t){
    if(time == t) return;
    fresh = true; 
    lastActiveFrame = frameCount;
    addPos(x, y);
    speed = s;
    pTime = time;
    time = t;
  }

  public void addPos(float x, float y) {
    pos = new PVector(x, y);
    tracks[idx] = pos;
    idx = (idx + 1) % M;
  }

  public void setColor(int c) {
    theColor = c;
  }
  
  public void update(){
    for (TramoStatus t: tramos) {
      t.update();
    }
  }
  
   public void draw() {
    pushStyle();
     for (int i = 0; i < M - 1; i ++) {
      int p0 = (idx + i) % M;
      int p1 = (idx + i + 1) % M;
      PVector pos0 = tracks[p0];
      PVector pos1 = tracks[p1];
      stroke(setAlpha(i));
      if (pos0 != null && pos1 != null)
        line(pos0.x, pos0.y, pos1.x, pos1.y);
    }
   
    fill(theColor);
    if (inTrack()) stroke(255);
    else noStroke();

    ellipseMode(CENTER);
    ellipse(pos.x, pos.y, 18/dZ, 18/dZ);
    fill(0);
    textSize(12/dZ);
    textAlign(CENTER);
    noStroke();
    float ascent = textAscent();
    text(id, pos.x, pos.y + 5/dZ);

    popStyle();
  }
  
   public int setAlpha(int i) {
    return color(red(theColor), 
    green(theColor), 
    blue(theColor), 
    map(i, 0, M - 1, 50, 255) );
  }
  
  public float dist(PVector p){
    return this.pos.dist(p);
  }
  
  public boolean inTrack() {
    for (TramoStatus t: tramos)
      if (t.inTrack) return true;
    return false;
  }
  public void registerTramo(Tramo t) {
    TramoStatus tramo = new TramoStatus(this, t);
    tramos.add(tramo);
  }
  
  public TramoStatus getTramoStatus(int id){
    for (TramoStatus tt: tramos)  
       if(tt.getId() == id)
         return tt;
       
    return null;
  }
  
  
  public void drawLoop(){
    for(TramoStatus t: tramos){
       if(t.finish)
        t.drawLoop();
    } 
  }
  public void loadLoops(){
    for(TramoStatus t: tramos){
      t.loadLoop();
    }
  }
  public void removeLoops(){
    for(TramoStatus t: tramos){
      t.removeLoop();
    }
  }
  
  public int drawInfo(int tramoId, int x, int y, int opacity) {
    TramoStatus t = getTramoStatus(tramoId);
    
    
    if(t == null)
      return -1;
    int s = 11;
    pushStyle();
    fill(255, 200);
    stroke(255);
    strokeWeight(1);
    rect(x - 5, y, ANCHO, s * 5);
    fill(0, opacity);
    textSize(s * 0.8f);
    textAlign(LEFT);
    text("CAR: " + name + " ID: " + id + " SPEED: " + PApplet.parseInt(speed) + " km/h" 
        + " IDLE: " 
        +  PApplet.parseInt((frameCount - lastActiveFrame)/frameRate) 
        + " s", x, y + s);
     
    pushStyle();
   
    String status = "";
    if (t.finish){
      status = "DONE";    
      fill(0, 255, 0, opacity);
    }
    else if(t.running){
      status = "RUNNING";
      fill(255, 255, 0, opacity);
    }
    else if(t.inTrack){
      status = "WAITING";
      fill(0, 255, 255, opacity);
    }
    else{
      status = "OUT";
      fill(0, opacity);
    }
    text("TRAMO: " + t.getId()  + " STATUS: " + status, x, y + 2*s);
    popStyle(); 
  
    float dst =  t.getDistanceFromStart();   
    if(status != "OUT"){
      text("DIST: " + PApplet.parseInt(dst), x, y + s * 3);
    }
    if(status == "RUNNING" || status == "DONE"){
      float cTime = t.getTotalTime();
      text("TIME: " + PApplet.parseInt(cTime) + " AVG: " + PApplet.parseInt(dst/cTime) + " m/s", x, y + s * 4);
      
    }
  
    popStyle();
    
    return s*5;
   
  }
        


}  

int[] carColors = {
  0xffFF244C, 0xffFF24F5, 0xff7724FF, 
  0xff244AFF, 0xff24BBFF, 0xff24FFBF, 
  0xff24FF3B, 0xffD2FF24, 0xffFFB624, 
  0xffFF3624
};

class Cars {
  ArrayList<Car> cars;
  Tramos ts; 

  Cars() {
    cars = new ArrayList<Car>();
    
  }
  public void loadCars(String fileName){
    String lines[] = loadStrings(fileName);
    try{
      for (int i = 0 ; i < lines.length; i++) {
         String[] tokens = splitTokens(lines[i], ",");
         int id = PApplet.parseInt(tokens[0]);
         String name = tokens[1];
         Car c = new Car(id, name);
         add(c);
         println("Car added: " + name + " " + id);
      }
    }
    catch(Exception e){
      println("ERROR: reading cars");
    }
  }
  public void add(Car c) {
    c.setColor(carColors[c.id % carColors.length]);
    cars.add(c);
    registerTramo(c, ts);
  }

  public void update() {
      for (Car c: cars)
        c.update();
  }

  public void addData(int id, float x, float y, float s, int d) {
    for (Car c: cars) {
      if (c.id == id) {
        c.addPoint(x, y, s, d);
        return;
      }
    }
  }


  public void draw() {
    for (Car c: cars)
      c.draw();
  }

  public void registerTramos(Tramos ts) {
    this.ts = ts;
  }

  public void registerTramo(Car c, Tramos ts) {
    for (Tramo t: ts.tramos)
      c.registerTramo(t);
  }

  public void displayInfo(int tramoId, int x, int y, int opacity) {
    for (Car c: cars) {
      int nextY = y + c.drawInfo(tramoId, x, y, opacity);
      y = nextY;
    }
  }
  
  
  
  public void drawLoop(){
     for (Car c: cars)
       c.drawLoop();
  }
  public void loadLoops(){
    for(Car c: cars){
      c.loadLoops();
    }
  }
  public void removeLoops(){
    for(Car c: cars)
      c.removeLoops();
    
  }
}

class LoopPoint {
  float time;
  float speed;
  int idx;
  String status;
  Tramo tramo;
  
  LoopPoint(Tramo t, int proyectionIndex, float time, float speed, String status) {
    this.status = status;
    this.time = time;
    this.speed = speed;
    this.idx = proyectionIndex;
    this.tramo = t;
  }
  public String toString(){
      String s = idx + "," + getRealIndex() + "," + PApplet.parseInt(time) + "," + (PApplet.parseInt(speed * 10) /10.0f) + "," + status + "," 
                + PApplet.parseInt(getPos().x) + "," + PApplet.parseInt(getPos().y) 
                + "," + PApplet.parseInt((getPos().x - ref.x)) 
                + "," + PApplet.parseInt((getPos().y - ref.y));
                
      return s;
  }
  public PVector getPos(){
    return tramo.getUtmPoint(idx);
  }
  
  public int getRealIndex(){
    return tramo.getRealIndex(idx);
  }
  public float getDistanceFromStart(){
    return tramo.getDistanceFromStart(idx);
  }
}

class LoopTrack {

  ArrayList<LoopPoint> loopTrack; 
  PrintWriter output, output2;
  String fileName;
  Car car;
  Tramo tramo;
  LoopPoint last;
  float accError;
 
   LoopTrack(Tramo t, Car c) {
    loopTrack = new ArrayList<LoopPoint>();
    String path = "/Users/miguel/Desktop/Unity Tracking/trackingScripts/unityTracking2/";
    fileName = "data/loops/Tramo_" + t.id + "_car_" + c.id;
    this.tramo = t;
    this.car = c;
  
    try{
      output = new PrintWriter(new FileOutputStream(new File(path + fileName + ".csv"), true)); 
      output2 = new PrintWriter(new FileOutputStream(new File(path + fileName + "_interpolated.csv"), true)); 
    }
    catch(FileNotFoundException e){
      println(e);
      output = createWriter(fileName + ".csv");   
      output2 = createWriter(fileName + "_interpolated.csv");    
    }
    accError = 0;
  }
  public void removeData(){
      println("aaa");
      output = createWriter(fileName + ".csv");   
      output2 = createWriter(fileName + "_interpolated.csv");     
  }
  
  public void add(int proyectionIndex, float time, float speed, String status) {
    speed = speed * 1000/3600;
    last = new LoopPoint(tramo, proyectionIndex, time, speed, status);
    loopTrack.add(last);
    writePoint(last); 
  }
  
  public LoopPoint loadLoop(){
    String lines[] = loadStrings(fileName + ".csv");
    if (lines.length == 0)
      return null;
    for (int i = 1; i < lines.length; i++) {
      String[] tokens = splitTokens(lines[i],",");
      int proyectionIndex = PApplet.parseInt(tokens[2]);
      float time = PApplet.parseFloat(tokens[3]);
      float speed = PApplet.parseFloat(tokens[4]);
      String status = tokens[5];
      last = new LoopPoint(tramo, proyectionIndex, time, speed, status);
      loopTrack.add(last);
    } 
    return last;
  }
  
  public void writePoint(LoopPoint last){
    float error = car.dist(last.getPos());
    float avg = calculateAvgSpeedOfLastPeriod();
    if(last.status == "start"){
      String s = "Car Id,Tramo Id,UTM Index,REAL Index,Car Time,Speed,Status,Utm X,Utm Y,Norm X,Norm Y,Avg Speed,Track Time,Distance,Remaining Distance,Error";
      output.println(s);
      output2.println(s);
    }
    String s = "";
    s += car.id;
    s += "," + tramo.id;
    s += "," + last.toString();
    s += "," + PApplet.parseInt(avg * 10) / 10.0f;
    s += "," + PApplet.parseInt(getTotalTime());
    s += "," + PApplet.parseInt(getDistanceFromStart());
    s += "," + PApplet.parseInt((tramo.getTotalLength() - getDistanceFromStart()));
    s += "," + PApplet.parseInt(error);
   
    if(last.status == "running")
      accError += error;
     
    output.println(s);
    
    writeInterpolation(avg);
    output2.println(s);
    
    output.flush();
    output2.flush();
    
    if(last.status == "ended"){
      output.close();
      output2.close();
      //println(car.id + " ERROR: " + accError / (loopTrack.size() - 2));
    }
  }
  

  public void writeInterpolation(float avg){
    if(loopTrack.size() < 2) return;
      LoopPoint prev = loopTrack.get(loopTrack.size() - 2);
      for(int i = prev.idx + 1; i < last.idx; i ++){
        float localDst = tramo.getDistanceFromStart(i) - prev.getDistanceFromStart();
        float localTime = (localDst/avg);
        float time = localTime + prev.time - loopTrack.get(0).time;
        String s = ",,,";
        s += i;
        s += ",,,,,,,,";
        s += "," + PApplet.parseInt(time);
        s += "," + PApplet.parseInt(tramo.getDistanceFromStart(i));
        s += "," + PApplet.parseInt((tramo.getTotalLength() - tramo.getDistanceFromStart(i)));
        output2.println(s);
      }
  }

  public void draw(){
    if(loopTrack == null) return;
    if(loopTrack.size() < 1) return;
    
    for(int i = 1; i < loopTrack.size(); i ++){
      LoopPoint lp = loopTrack.get(i);
      LoopPoint prev = loopTrack.get(i - 1);
      int x0 = PApplet.parseInt(prev.getPos().x);
      int y0 = PApplet.parseInt(prev.getPos().y); 
      int x1 = PApplet.parseInt(lp.getPos().x);
      int y1 = PApplet.parseInt(lp.getPos().y); 
      pushStyle();
      strokeWeight(6);
      stroke(255, 255, 0);
      line(x0, y0, x1, y1);
      popStyle();
    
    }
  } 
  
  public float getDistanceFromStart() {
    if(loopTrack == null) return 0;
    if(loopTrack.size() == 0) return 0;
    return last.getDistanceFromStart();
  }
   
  public float getTotalTime() {
    if(loopTrack == null) return 0;
    if(loopTrack.size() == 0) return 0;
    return last.time - loopTrack.get(0).time;
  }
    
   public float calculateAvgSpeedOfLastPeriod() {
    if (loopTrack.size() > 1) {
      LoopPoint prev = loopTrack.get(loopTrack.size() - 2);
      if (last.time - prev.time == 0) return 0;
      return (last.getDistanceFromStart() - prev.getDistanceFromStart())/(last.time - prev.time);
    }
    else {
      return -1;
    }
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
    float s = theOscMessage.get(3).floatValue() ;
    int d = theOscMessage.get(4).intValue();
    cars.addData(id, x, y, s, d);
    return;
  }
  
  if (theOscMessage.checkAddrPattern("/reset")==true) {
    cars = new Cars();
    cars.registerTramos(tramos);
    cars.loadCars("cars.txt");
    cars.removeLoops();
    return;
  }
  
  println("### received an osc message. with address pattern "+
    theOscMessage.addrPattern()+" typetag "+ theOscMessage.typetag());
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

int trackThreshold = 30;
int endThreshold = 1000;

class TramoStatus {
  Tramo t;
  Car car;

  boolean inTrack = false;
  boolean running = false;
  boolean finish = false;

  int proyection, pProyection;
  LoopTrack loopTrack;
  
  TramoStatus(Car c, Tramo t) {
    this.t = t;
    this.car = c;
    
    reset();
    
  }

  public void reset() {
    inTrack = false;
    running = false;
    finish = false;
  }

  public int updateProyection(PVector pos) {
    return t.getClosest(pos);
  }

  public boolean updateInTrack() {
    return car.dist(t.getUtmPoint(proyection)) < trackThreshold;
  }

  public boolean updateStart() {  
    if (inTrack && 
      !running && 
      proyection > t.getStartIndex()
      ) {
      return true;
    }
    return false;
  }
  
  public boolean updateEnd() {
    
    if (running 
        && proyection > t.getEndIndex()) 
      return true;
    
    return false;
  
  }

  public void update() {
    if(finish) return;
    pProyection = proyection;
    proyection = updateProyection(car.pos);
    if(proyection == pProyection) return;
    inTrack = updateInTrack();
    
    if (!running) {
        running = updateStart(); 
        if (running) {
           loopTrack = new LoopTrack(t, car);  
           loopTrack.add(pProyection, car.pTime, 0, "start");
        }
    }
    if(running){
      finish = updateEnd(); 
      if (finish) {         
        loopTrack.add(proyection, car.time, car.speed, "ended");
        inTrack = false;
        running = false;
      }
      else{
        loopTrack.add(proyection, car.time, car.speed, "running");
      }
    }
  }
  
  public int getId(){
    return t.id;
  }
  
    
  public void drawLoop(){
    if(loopTrack != null)  
      loopTrack.draw();
  }
  public float getDistanceFromStart() {
    if(loopTrack == null) return 0;
    return loopTrack.getDistanceFromStart();
  }
   public float getTotalTime() {
    if(loopTrack == null) return 0;
    return loopTrack.getTotalTime();
  }
  
  public void loadLoop(){
    
    println("Reading loop: " + car.id + " tramo " + t.id);
    if(loopTrack == null) 
          loopTrack = new LoopTrack(t, car);  
          
    LoopPoint last = loopTrack.loadLoop();
    if(last == null) return;
    
    if(last.status.equals("running")){
      inTrack = true;
      running = true;
      finish = false;
    }
    if(last.status.equals("start")){
      inTrack = true;
      running = true;
      finish = false;
    }
    if(last.status.equals("ended")){
      finish = true;
      inTrack = false;
      running = false;
    }
    proyection = last.idx;
    car.time = last.time;
    car.speed = last.speed;
    car.pos = t.getUtmPoint(proyection);
  }

  public void removeLoop(){
     if(loopTrack != null) 
         loopTrack.removeData();
  }

}

class Tramos {
  ArrayList<Tramo> tramos;
  int focus = -1;
  String fileName;
  
  Tramos(String fileName) {
    tramos = new ArrayList<Tramo>();
    loadTramos(fileName);
    this.fileName = fileName;
  }
  
  public void loadTramos(String fileName){
    String lines[] = loadStrings(fileName);
    try{
      for (int i = 0 ; i < lines.length; i++) {
         String[] tokens = splitTokens(lines[i], ",");
         String tramoName = tokens[0];
         String utm = tokens[1];
         String real = tokens[2];
         int start = PApplet.parseInt(tokens[3]);
         int end = -abs(PApplet.parseInt(tokens[4]));
         add(new Tramo(tramoName, utm, real, start, end));
         
      }
    }
    catch(Exception e){
      println("ERROR: reading tramos");
    }
   
  }
  public void write(){
    PrintWriter output = createWriter("data/" + fileName);  
     for (Tramo t: tramos)
        output.println(t.toString());
    output.close();
  }
  public void add(Tramo t) {
    t.setId(tramos.size());
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
  
  public int size(){
    return tramos.size();
  }
  
  public void draw() {
    for (Tramo t: tramos){
      if(t.inFocus()){
        t.draw(255);
      }
      else{
        t.draw(50);
      }
      
    } 
  }
  public void addStart(){
    for (Tramo t: tramos)
      if(t.inFocus())  
        t.addStart();
  }
  
  public void addEnd(){
    for (Tramo t: tramos)
      if(t.inFocus())  
        t.addEnd();
  }
   public void subStart(){
    for (Tramo t: tramos)
      if(t.inFocus())  
        t.subStart();
  }
  
  public void subEnd(){
    for (Tramo t: tramos)
      if(t.inFocus())  
        t.subEnd();
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
    if (key == 'l'){
       cars.loadLoops();
       println("Loading loops..."); 
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

class TramoPoint {
  PVector pos;
  float dst;

  TramoPoint(PVector pos, float dst) {
    this.dst = dst;
    this.pos = pos;
  }
}

class Track {
  ArrayList<TramoPoint> data;
  TramoPoint end, start;
  float totalDst = -1;
  String fileName;
  int startIndex, endIndex;
  Track() {
  }

  public void loadData(String fileName, PVector ref) {
    this.fileName = fileName;
    String lines[] = loadStrings(fileName);
    float dst = 0;
    data = new ArrayList<TramoPoint>();
    for (int i = 0 ; i < lines.length; i++) {
      String[] tokens = splitTokens(lines[i]);
      PVector pos = new PVector(PApplet.parseFloat(tokens[0]) + ref.x, PApplet.parseFloat(tokens[1]) + ref.y);
      if (i > 1)
        dst += data.get(i - 1).pos.dist(pos);
      data.add(new TramoPoint(pos, dst));
    }
    if (lines.length > 0) {
      start = data.get(0);
      end = data.get(data.size() - 1);
    }
    this.totalDst = dst;
  }

  public void setStart(int s) {
    startIndex = s;
    start = data.get(startIndex);
  }

  public void setEnd(int e) {
    endIndex = data.size() - 1 + e;
    end = data.get(endIndex);
  }
  
  public int getEndIndex(){
    return endIndex;
  }
  public int getStartIndex(){
    return startIndex;
  }

  public void loadData(String fileName) {
    loadData(fileName, new PVector(0, 0));
  }

  public void draw() {
    for (int i = 0 ; i < data.size() - 1; i++) {
      float x0 = data.get(i).pos.x;
      float y0 = data.get(i).pos.y;
      float x1 = data.get(i + 1).pos.x;
      float y1 = data.get(i + 1).pos.y;
      point(x0, y0);
      line(x0, y0, x1, y1);
    }
    pushStyle();
    fill(0, 255, 0);
    noStroke();
    ellipse(start.pos.x, start.pos.y, 20, 20);
    fill(0, 255, 255);
    noStroke();
    ellipse(end.pos.x, end.pos.y, 20, 20); 
    popStyle();
  }

  public PVector getStart() {
    return start.pos;
  }

  public PVector getEnd() {
    return end.pos;
  }

  public int getClosest(PVector pos) {
    float minDist = 10000000;
    int proyection = -1;
    int i = 0;
    for (TramoPoint p: data) {
      float d = pos.dist(p.pos);
      if (d < minDist) {
        proyection = i;
        minDist = d;
      }
      i ++;
    }
    return proyection;
  }
  public PVector get(int i) {
    return data.get(i).pos;
  }
  public float getDistance(int i) {
    return data.get(i).dst;
  }

  public int size() {
    return data.size();
  }
  public float getTotalLength() {
    return end.dst - start.dst;
  }
}

class Tramo {
  Track utm, real;
  boolean bFocus = false;
  int id = -1;
  String name = "";
  int start, end;

  Tramo(String name, String utmFile, String realFile, int start, int end) {
    utm = new Track();
    utm.loadData(utmFile);
    this.start = start;
    this.end = end;
    
    real = new Track();
    real.loadData(realFile, utm.get(0));
    
    setStartEnd();
    this.name = name;
  }
  
  public void setStartEnd(){
    utm.setStart(start);
    utm.setEnd(end);
    real.setStart(real.getClosest(utm.getStart()));
    real.setEnd(real.getClosest(utm.getEnd()) - real.size());
  }

  public boolean inFocus() {
    return bFocus;
  }
  public void setFocus(boolean b) {
    bFocus = b;
  }

  public void setId(int id) {
    this.id = id;
  }

  public PVector getStart() {
    return utm.getStart();
  }
  public PVector getEnd() {
    return utm.getEnd();
  }

  public void draw(int opacity) {
    stroke(255, opacity);
    utm.draw();
    stroke(255, 0, 255, opacity / 4);
    real.draw();
  }


  public int getClosest(PVector pos) {
    return utm.getClosest(pos);
  }

  public PVector getUtmPoint(int i) {
    return utm.get(i);
  }
  public int getRealIndex(int idx){
    return real.getClosest(utm.get(idx));
  }
  public float getDistanceFromStart(int i) {
    return utm.getDistance(i);
  }
  public float getTotalLength() {
    return utm.getTotalLength();
  }
  
  public void addStart() {
    start += 1;
    setStartEnd();
  }

  public void addEnd() {
    end -= 1;
    setStartEnd();
  }

  public void subStart() {
    start -= 1;
    if (start < 0) start = 0;
    setStartEnd();
  }

  public void subEnd() {
    end += 1;
    if (end > 0) end = 0;
    setStartEnd();
  }
  public String toString() {
    return name + "," + utm.fileName + "," + real.fileName + "," + start + "," + end;
  }
   public int getEndIndex(){
    return utm.getEndIndex();
  }
  public int getStartIndex(){
    return utm.getStartIndex();
  }

}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "unityTracking2" });
  }
}
