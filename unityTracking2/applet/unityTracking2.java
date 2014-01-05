import processing.core.*; 
import processing.xml.*; 

import oscP5.*; 
import netP5.*; 
import de.bezier.data.sql.*; 

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
int focus;
String host = "";
int trackThreshold;
int M;
PrintWriter logFile;

public void setup() {


  size(800, 600);
  frameRate(30);
  smooth();
  loadSettings();

  initializeKeys();
  
  dX = loadSetting("dX", 6000);
  dY = loadSetting("dY", 7500);
  dZ = loadSetting("dZ", 0.05f);
  focus = loadSetting("focus", 0);
  host = loadSetting("host", "");
  trackThreshold = loadSetting("trackThreshold", 30);
  M = loadSetting("estela", 10);
  
  
  try{
  logFile = new PrintWriter(new FileOutputStream(new File(host + "tracking.log"), true), true); 
  }
  catch(Exception e){}
  logFile.println("--- new sesion --- "); 
  
  setupOsc();
  initSystem();
  setupMySQL();
  
 
}
public void initSystem(){
  
  
  tramos = new Tramos(host + "Tramos/tramos.txt");
  ref = tramos.setFocus(focus);
  
  cars = new Cars();
  cars.registerTramos(tramos);
  cars.loadCars(host + "Cars/cars.txt");
}

public void draw() {
  processSQL();
  
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
  cars.drawCurrentClassification(focus, width - 200, 20);
  cars.drawFinalClassification(focus, width - 100, 20);

}

int ANCHO = 220;
int ALTO = 55;

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
  int x, y;
  boolean enabled = true;
  
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

  public void setColor(String c) {
    
    theColor = unhex("FF" + c);
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
    if(!enabled) fill(theColor, 100);
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
  
  public boolean isInTramo(int tramoId){
    for (TramoStatus t: tramos){
      if (t.inTrack && t.t.id == tramoId) return true;
    }
    return false;
  }
  public boolean finished(int tramoId){
    for (TramoStatus t: tramos){
      if (t.finish && t.t.id == tramoId) return true;
    }
    return false;
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
 
  public void removeLoops(){
    for(TramoStatus t: tramos){
      t.removeLoop();
    }
  }
  
  public int drawInfo(int tramoId, int x, int y, int opacity) {
    this.x = x;
    this.y = y;
    int s = ALTO/5;
    
    TramoStatus t = getTramoStatus(tramoId);
    int idle = PApplet.parseInt((frameCount - lastActiveFrame)/frameRate);
    
    if(t == null)
      return -1;
    pushStyle();
    
    
    fill(255 - constrain((idle * 3), 0, 100), 200);
      
    stroke(theColor);
    strokeWeight(2);
    rect(x - 5, y, ANCHO, ALTO-4);
    fill(0, opacity);
    
    pushStyle();
    noStroke();
    ellipseMode(CENTER);
    if(enabled) 
      fill(0, 255, 0);
    else
      fill(255, 0, 0);
    ellipse(x + ANCHO - 10 , y + 7, 8, 8);
    popStyle(); 
    textSize(s * 0.8f);
    textAlign(LEFT);
    
    text("CAR: " + name + " ID: " + id + " SPEED: " + PApplet.parseInt(speed) + "km/h", x, y + s);
     
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
    
    return ALTO;
  }
        
   public void mouseClicked() {
     if(mouseX > x && mouseX < x + ANCHO && 
       mouseY > y && mouseY < y + ALTO){
          enabled = !enabled;
     }
   }
   public String toString(){
     
     String s = "";
     s += str(id) + ",";
     s += name + ",";
     s += hex(theColor).substring(2,8) + ",";
     if(enabled)
       s += "1";
     else
       s += "0";
     return s;
   }
   public float getDistanceFromStart(int tramoId){
      for (TramoStatus t: tramos){
        if(t.t.id == tramoId)
          return t.getDistanceFromStart();
      }
      return -1;
   }
    public float getTotalTime(int tramoId){
      for (TramoStatus t: tramos){
        if(t.t.id == tramoId)
          return t.getTotalTime();
      }
      return -1;
   }


}  


class Cars {
  ArrayList<Car> cars;
  Tramos ts; 
  String fileName;
  Cars() {
    cars = new ArrayList<Car>();
    
  }
  public void loadCars(String fileName){
    this.fileName = fileName;
    String lines[] = loadStrings(fileName);
    try{
      for (int i = 0 ; i < lines.length; i++) {
         lines[i] = lines[i].replace(" ", "");
         String[] tokens = splitTokens(lines[i], ",");
         int id = PApplet.parseInt(tokens[0]);
         String name = tokens[1];
         String theColor = tokens[2];
         int enabled = PApplet.parseInt(tokens[3]);
         Car c = new Car(id, name);
         c.setColor(theColor);
         add(c);
         if(enabled == 1) 
           c.enabled = true;
         else
           c.enabled = false;
         logFile.println("Car added: " + name + " " + id);
      }
    }
    catch(Exception e){
      logFile.println("ERROR: reading cars");
    }
  }
  public void writeCars(){
    PrintWriter output = createWriter(fileName);  
    for (Car c: cars){
        String s = c.toString();
        output.println(s);
     }
     output.close();
  
  }
  public void add(Car c) {
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

  public void removeLoops(){
    for(Car c: cars)
      c.removeLoops();
    
  }
  public void mouseClicked() {
    for(Car c: cars)
      c.mouseClicked();
    writeCars();
  }
  
  public void enable() {
    for(Car c: cars)
      c.enabled = true;
    writeCars();
  }
  
  public void disable() {
    for(Car c: cars)
      c.enabled = false;
    writeCars();
  }
  
  
  public ArrayList<Car> getRunningCars(int tramoId) {
    ArrayList<Car> active = new ArrayList<Car>();
    for (Car c: cars) {
      if (c.isInTramo(tramoId))
        active.add(c);
    }
    return active;
  }
   public ArrayList<Car> getFinalizedCars(int tramoId) {
    ArrayList<Car> active = new ArrayList<Car>();
    for (Car c: cars) {
      if (c.finished(tramoId))
        active.add(c);
    }
    return active;
  }  
  public ArrayList<Car> calculateCurrentClassification(int tramoId) {
    ArrayList<Car> activeCars = getRunningCars(tramoId);
    ArrayList<Car> classification = new ArrayList<Car>();
    
    for (Car c: activeCars) {
      int i = 0;
      float d = c.getDistanceFromStart(tramoId);
      while (i < classification.size ()) {
        if (d > classification.get(i).getDistanceFromStart(tramoId))
          break;
        else
          i ++;
      }
      classification.add(i, c);
    }
    return classification;
  }
   public ArrayList<Car> calculateFinalClassification(int tramoId) {
    ArrayList<Car> activeCars = getFinalizedCars(tramoId);
    ArrayList<Car> classification = new ArrayList<Car>();
    
    for (Car c: activeCars) {
      int i = 0;
      float d = c.getTotalTime(tramoId);
      while (i < classification.size ()) {
        if (d < classification.get(i).getTotalTime(tramoId))
          break;
        else
          i ++;
      }
      classification.add(i, c);
    }
    return classification;
  }
  public void drawCurrentClassification(int tramoId, int x, int y) {
    ArrayList<Car> classification = calculateCurrentClassification(tramoId);
    pushStyle();
    stroke(255);
    fill(255);
    textSize(10);
    String s = "" ;
    for (Car c: classification) {
      s += c.id + "   " + PApplet.parseInt(c.getDistanceFromStart(tramoId));
      s += " m \n";
    }
    text(s, x, y);
    popStyle();
  }
   public void drawFinalClassification(int tramoId, int x, int y) {
    ArrayList<Car> classification = calculateFinalClassification(tramoId);
    pushStyle();
    stroke(255);
    fill(255);
    textSize(10);
    String s = "" ;
    for (Car c: classification) {
      s += c.id + "   " + PApplet.parseInt(c.getTotalTime(tramoId) * 10) /10.0f;
      s += " s \n";
    }
    text(s, x, y);
    popStyle();
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
      String s = idx + "," + getRealIndex() + "," + PApplet.parseInt(time) + "," + (PApplet.parseInt(speed * 10) /10.0f) + ",'" + status + "'," 
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
  public float getRealDistanceFromStart(){
    return tramo.getRealDistanceFromStart(getRealIndex());
  }
}

class LoopTrack {

  ArrayList<LoopPoint> loopTrack; 
  String fileName;
  Car car;
  Tramo tramo;
  LoopPoint last;
  float accError;
 
   LoopTrack(Tramo t, Car c) {
    loopTrack = new ArrayList<LoopPoint>();
    fileName = host + "Loops/Tramo_" + t.id + "_car_" + c.id;
    this.tramo = t;
    this.car = c;
  
    accError = 0;
  }
  public void removeData(){
    removeMySQL();
  }
  
  public void add(int proyectionIndex, float time, float speed, String status) {
    speed = speed * 1000/3600;
    last = new LoopPoint(tramo, proyectionIndex, time, speed, status);
    loopTrack.add(last);
    writePoint(last); 
  }
  
  
  
  public void writePoint(LoopPoint last){
    float error = car.dist(last.getPos());
    
    float avg = calculateAvgSpeedOfLastPeriod();
    
    String s = "";
    s += car.id;
    s += "," + tramo.id;
    s += "," + last.toString();
    s += "," + PApplet.parseInt(avg * 10) / 10.0f;
    s += "," + PApplet.parseInt(getTotalTime());
    s += "," + PApplet.parseInt(getDistanceFromStart());
    s += "," + PApplet.parseInt((tramo.getRealTotalLength() - getDistanceFromStart()));
    s += "," + PApplet.parseInt(error);
   
    if(last.status == "running")
      accError += error;
    
    insertMySQL(s);
     
    
    writeInterpolation(avg);
  }
  

  public void writeInterpolation(float avg){
    if(loopTrack.size() < 2) return;
      LoopPoint prev = loopTrack.get(loopTrack.size() - 2); 
      
      boolean started = true;
      if(prev.status.equals("start"))
        started = false;
        
      for(int i = prev.getRealIndex() + 1; i < last.getRealIndex(); i ++){
        if(tramo.getRealDistanceFromStart(i) < 0){
          continue;
        }
         
        float localDst = tramo.getRealDistanceFromStart(i) - prev.getRealDistanceFromStart();
        float localTime = (localDst/avg);
        float time = localTime + prev.time - loopTrack.get(0).time;
        
        if(!started){ 
           loopTrack.get(0).time += time; //encendemos el cron\u00f3metro
           time = 0;
           started = true;
        }
        
        String s = car.id + "," + tramo.id ; 
        s += "," + i;
        s += "," + (PApplet.parseInt(avg * 10)/10.0f);
        s += "," + (PApplet.parseInt(time * 10) /10.0f);
        s += "," + PApplet.parseInt(tramo.getRealDistanceFromStart(i));
        s += "," + PApplet.parseInt((tramo.getRealTotalLength() - tramo.getRealDistanceFromStart(i)));
        insertMySQL2(s);

        if(i >= tramo.getRealEndIndex()){
          last.time = time + loopTrack.get(0).time; //apagamos el cronometro
          break; 
        }
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
    return last.getRealDistanceFromStart();
  }
   
  public float getTotalTime() {
    if(loopTrack == null) return 0;
    if(loopTrack.size() == 0) return 0;
    return last.time - loopTrack.get(0).time;
  }
    
   public float calculateAvgSpeedOfLastPeriod() {
    if (loopTrack.size() > 1) {
      LoopPoint prev = loopTrack.get(loopTrack.size() - 2);
      if (last.time == prev.time) return 0;
      return (last.getRealDistanceFromStart() - prev.getRealDistanceFromStart())/(last.time - prev.time);
    }
    else {
      return -1;
    }
  }
  
  
  


}



OscP5 oscP5;

public void setupOsc() {
  oscP5 = new OscP5(this, 12000);
  logFile.println("OSC listening on port " + 12000);
}


public void oscEvent(OscMessage theOscMessage) {
  
  if (theOscMessage.checkAddrPattern("/reset")==true) {
    initSystem();
    cars.removeLoops();
    return;
  }
  
  println("### received an osc message. with address pattern "+
    theOscMessage.addrPattern()+" typetag "+ theOscMessage.typetag());
}


MySQL msql;
public void setupMySQL()
{
    String user     = "miguel";
    String pass     = "miguel";
    String database = "unity";
    msql = new MySQL( this, "localhost:8889", database, user, pass );
    msql.connect();
}

public void insertMySQL(String s){
   msql.query("INSERT INTO tracks VALUES (" + s  + ")");   
}
public void insertMySQL2(String s){
   msql.query("INSERT INTO tracks (CarId, TramoId, realIndex, avgSpeed, trackTime, trackDistance, remainingDistance) VALUES (" + s  + ")");   
}

public void removeMySQL(){
   msql.query("DELETE FROM tracks WHERE 1");   
}

public void processSQL(){
  msql.query( "SELECT * FROM data WHERE processed = 0 order by id LIMIT 1");
  while (msql.next())
   {
    int id = msql.getInt("id"); 
    int carId= msql.getInt("carId"); 
    float x = msql.getFloat("x"); 
    float y = msql.getFloat("y"); 
    float speed = msql.getFloat("speed"); 
    int time =  msql.getInt("time"); 
    cars.addData(carId, x, y, speed, time);
    println("Processing... " + id);
    msql.execute( "UPDATE data SET processed = 1 WHERE id ="+ str(id));
    break;
  }

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
         lines[i] = lines[i].replace(" ", "");
         String[] tokens = splitTokens(lines[i], ",");
         String tramoName = tokens[0];
         String utm = tokens[1];
         String real = tokens[2];
         int start = PApplet.parseInt(tokens[3]);
         int end = -abs(PApplet.parseInt(tokens[4]));
         add(new Tramo(tramoName, utm, real, start, end));
         logFile.println("Tramo added: " + tramoName);
      }
    }
    catch(Exception e){
      logFile.println("ERROR: reading tramos");
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
    
    if (key == 'a'){
       if(keyCodes[SHIFT])
         cars.disable();
       else 
         cars.enable();
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
    this.fileName = host + "Tramos/"+ fileName;
    String lines[] = loadStrings(this.fileName);
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

  public int size() {
    return data.size();
  }
  
  public float getDistance(int i) {
    return data.get(i).dst;
  }
  
  public float getDistanceFromStart(int i) {
    return data.get(i).dst - start.dst;
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
    
    logFile.println("Loading tramo: " +  name);
    utm = new Track();
    utm.loadData(utmFile);
    
    if (start < 1) start = 1;
    if (end > -1) end = -1;
    
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
    stroke(255, 255, 0, opacity / 2);
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
  
  public float getRealDistanceFromStart(int i) {
    return real.getDistanceFromStart(i);
  }
  public float getRealTotalLength() {
    return real.getTotalLength();
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
    if (start < 1) start = 1;
    setStartEnd();
  }

  public void subEnd() {
    end += 1;
    if (end > -1) end = -1;
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
  
   public int getRealEndIndex(){
    return real.getEndIndex();
  }
  
  public int getRealStartIndex(){
    return utm.getStartIndex();
  }

}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "unityTracking2" });
  }
}
