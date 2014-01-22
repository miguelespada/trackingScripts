import processing.core.*; 
import processing.xml.*; 

import java.sql.Timestamp; 
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

public class unityTracking extends PApplet {

float dX;
float dY;
float dZ;

SQL mysql;

Cars cars; 
Tramos tramos;
RealTime rt;

String host = "";
int trackThreshold;
int M = 20;


float lastActivity;
float lastProcess;
boolean bProcess = false;

public void setup() {

  size(900, 700);
  initServices();
  initSystem();
}

public void initServices() {

  loadSettings();
  try {
    mysql = new SQL(new MySQL(this, 
    loadSetting("localDBhost", ""), 
    loadSetting("localDBname", ""), 
    loadSetting("localDBuser", ""), 
    loadSetting("localDBpass", "")), 
    new MySQL(this, 
    loadSetting("remoteDBhost", ""), 
    loadSetting("remoteDBname", ""), 
    loadSetting("remoteDBuser", ""), 
    loadSetting("remoteDBpass", "")));
  }
  catch(Exception e) {
    println(e);
  }


  dX = loadSetting("dX", 0);
  dY = loadSetting("dY", 0);
  dZ = loadSetting("dZ", 0.05f);
  host = loadSetting("host", "");
  trackThreshold = loadSetting("trackThreshold", 30);
  initializeKeys();
}

public void initSystem() {
  cars = new Cars();
  cars.loadCars();
  
  tramos = new Tramos();
  tramos.registerCars(cars);
  
  tramos.setTramo(loadSetting("focus", 0));
  rt = new RealTime();
}

public void draw() {
  if (millis() > lastActivity + 20000) {
    background(50);    
    frameRate(1);
  }
  else {
    frameRate(30);
    background(0);
  }
  if(millis() > lastProcess + 2000 && !keyPressed && keyCodes[SHIFT] == false) {
      if(bProcess){
       
    
        mysql.process();
        
      }
      lastProcess = millis();
  }

  pushMatrix();
  translate(width/2, height/2);
  scale(dZ);
  translate(-width/2, -height/2);
  scale(1, -1);
  translate(dX-tramos.getX(), dY-tramos.getY());

  strokeWeight(1/dZ);
  tramos.draw();  
  cars.draw();
  popMatrix();
  
  pushMatrix();
  
  cars.displayInfo(10, 2, 255);
  popMatrix();
  
  cars.drawCurrentClassification(255, 120);
  cars.drawFinalClassification(width - 150, 120);

  tramos.drawInfo(width - 300, height - 200);
  drawInfo(255, 20);
  
}

public void drawInfo(int x, int y){
  pushStyle();
  fill(255);
  textSize(12);
  translate(x, y);
  text("Center: (" + PApplet.parseInt(dX) + " / " + PApplet.parseInt(dY) + " / " + PApplet.parseInt(dZ*10000) + ")", 0, 20);
  text("fps: " + PApplet.parseInt(frameRate), 0,  40);
  text("Resolution: " + PApplet.parseInt(width/(1000.0f* dZ))  + " km", 0,  60);
    text("In Track Threshold: " + trackThreshold + " m", 0, 80);

  noStroke();
  fill(255, 0, 0);
  if(bProcess) 
    fill(0, 255, 0);
  ellipse(7.5f, 0, 15, 15);
  popStyle();
}

int ANCHO = 220;
int ALTO = 50;

class Car {
  int theColor;
  PVector pos;
  int id; 
  float speed;
  String status = "NO DATA";
  TramoStatus ts;
  
  PVector tracks[];
  int idx;
  int time, pTime;
  int lastActiveFrame;
  boolean fresh;
  String name;
  int x, y;
  
  Car(int id, String name) {
    this.name = name;
    this.id = id;
    reset();
  }
  
  public void reset(){
    this.pos = new PVector(0, 0);
    tracks = new PVector[M];
    idx = 0;
    time = 0;
    pTime = 0;
    lastActiveFrame = -1;
    fresh = false;
    if(ts != null)
      ts.reset();
  }
  
  public void addPoint(float x, float y, float s, int t, String status){
    if(time == t) return;
    fresh = true; 
    lastActiveFrame = frameCount;
    addPos(x, y);
    speed = s;
    pTime = time;
    time = t;
    this.status = status;
    update();
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
      ts.update();
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
    if (ts.inTrack) stroke(255);
    else noStroke();

    ellipseMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    scale(1, -1);
    ellipse(0, 0, 18/dZ, 18/dZ);
    fill(0);
    textSize(12/dZ);
    textAlign(CENTER);
    noStroke();
    float ascent = textAscent();
    text(id, 0, 5/dZ);
    popMatrix();

    popStyle();
  }
  
   public int setAlpha(int i) {
    return color(red(theColor), 
    green(theColor), 
    blue(theColor), 
    map(i, 0, M - 1, 50, 255) );
  }
  
  public void registerTramo(Tramo t) {
    ts = new TramoStatus(this, t);
  }
  
  public int drawInfo(int x, int y, int opacity) {
    this.x = x;
    this.y = y;
    int s = ALTO/5;
    
    int idle = PApplet.parseInt((frameCount - lastActiveFrame)/frameRate);
    
    if(ts == null) return -1;
    pushStyle();
    
    fill(255 - constrain((idle * 3), 0, 100), 200);
      
    stroke(theColor);
    strokeWeight(2);
    rect(x - 5, y, ANCHO, ALTO-4);
    fill(0, opacity);
  
    textSize(s * 0.9f);
    textAlign(LEFT);
    if(!status.equals("WRC")) fill(150, 0, 0);
    text( id + " - " + name  + " tramo: " + ts.t.id +  " " + status, x, y + s);
     
    pushStyle();
   
    String status = "";
    if (ts.finish){
      status = "DONE";    
      fill(0, 255, 0, opacity);
    }
    else if(ts.running){
      status = "RUNNING";
      fill(255, 255, 0, opacity);
    }
    else if(ts.inTrack){
      status = "WAITING";
      fill(0, 255, 255, opacity);
    }
    else{
      status = "OUT";
      fill(0, opacity);
    }
    text("SPEED: " + PApplet.parseInt(speed) + "km/h " + "STATUS: " + status, x, y + 2*s);
    
    popStyle(); 
    float dst =  ts.getDistanceFromStart(); 
    
    if(status != "OUT"){
      text("DIST: " + PApplet.parseInt(dst), x, y + s * 3);
    }
    if(status == "RUNNING" || status == "DONE"){
      float cTime = ts.getTotalTime();
      text("TIME: " + PApplet.parseInt(cTime)/60 + ":" + PApplet.parseInt(cTime)%60  + " AVG: " + PApplet.parseInt(dst/cTime) + " m/s", x, y + s * 4);
    }
    
    popStyle();
    
    return ALTO;
  }
}  

class Cars {
  ArrayList<Car> cars;
  Tramo tramo;
  
  Cars() {
    cars = new ArrayList<Car>();
  }
  
  public void reset(){
    for (Car c: cars) c.reset();
  }
  
  public void loadCars(){
    mysql.loadCars();
  }
  
  public void add(Car c) {
    cars.add(c);
  }

  public void update() {
     for (Car c: cars) c.update();
  }

  public void addData(int id, float x, float y, float s, int d, String status) {
    for (Car c: cars) {
      if (c.id == id) {
        c.addPoint(x, y, s, d, status);
        return;
      }
    }
  }


  public void draw() {
    for (Car c: cars)
      c.draw();
  }

  public void registerTramo(Tramo t) {
    this.tramo = t;
    for (Car c: cars)      
      c.registerTramo(tramo);
  }

  public void displayInfo(int x, int y, int opacity) {
    for (Car c: cars) {
      int nextY = y + c.drawInfo(x, y, opacity);
      y = nextY;
    }
  }
  
  public ArrayList<Car> getRunningCars() {
    ArrayList<Car> active = new ArrayList<Car>();
    for (Car c: cars) if (c.ts.running) active.add(c);
    return active;
  }
  
  public ArrayList<Car> calculateCurrentClassification() {
    ArrayList<Car> activeCars = getRunningCars();
    ArrayList<Car> classification = new ArrayList<Car>();
    
    for (Car c: activeCars) {
      int i = 0;
      float d = c.ts.getDistanceFromStart();
      while (i < classification.size ()) {
        if (d > classification.get(i).ts.getDistanceFromStart())
          break;
        else
          i ++;
      }
      classification.add(i, c);
    }
    return classification;
  }
  
  public void drawCurrentClassification(int x, int y) {
    ArrayList<Car> classification = calculateCurrentClassification();
    pushStyle();
    stroke(255);
    fill(255);
    textSize(10);
    String s = "" ;
    for (Car c: classification) {      
      float cTime = c.ts.getTotalTime();
     /*if(cTime < 0 ){
       println(c.id + " " + cTime + " " + c.ts.loopTrack.last.time + " " + c.ts.loopTrack.loopTrack.get(0).time);
       exit();
     } */
      float dst = c.ts.getDistanceFromStart();
      s += c.id + "   " + PApplet.parseInt(dst) + "m, " + PApplet.parseInt(cTime)/60 + ":" + PApplet.parseInt(cTime)%60 + ", " + PApplet.parseInt((dst/cTime) * 3.6f) + " km/h";
      s += "\n";
    }
    text(s, x, y);
    popStyle();
  }
  
   public ArrayList<Car> getFinalizedCars() {
    ArrayList<Car> active = new ArrayList<Car>();
    for (Car c: cars) 
      if (c.ts.finish)  active.add(c);
    
    return active;
  }  
    
   public ArrayList<Car> calculateFinalClassification() {
    ArrayList<Car> activeCars = getFinalizedCars();
    ArrayList<Car> classification = new ArrayList<Car>();
    
    for (Car c: activeCars) {
      int i = 0;
      float d = c.ts.getTotalTime();
      while (i < classification.size ()) {
        if (d < classification.get(i).ts.getTotalTime())
          break;
        else
          i ++;
      }
      classification.add(i, c);
    }
    return classification;
  }
  
 
   public void drawFinalClassification(int x, int y) {
    ArrayList<Car> classification = calculateFinalClassification();
    pushStyle();
    stroke(255);
    fill(255);
    textSize(10);
    String s = "" ;
    for (Car c: classification) {
      float cTime = c.ts.getTotalTime();
      float dst = c.ts.getDistanceFromStart();
      s += c.id + " " + PApplet.parseInt(cTime)/60 + ":" + PApplet.parseInt(cTime)%60 + ", " + PApplet.parseInt((dst/cTime) * 3.6f) + " km/h";
      s += "\n";
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
      String s = idx + "," + idx + "," + PApplet.parseInt(time) + "," + (PApplet.parseInt(speed * 10) /10.0f) + ",'" + status + "'," 
                + PApplet.parseInt(getPos().x) + "," + PApplet.parseInt(getPos().y) 
                + "," + PApplet.parseInt((getPos().x - tramo.getX())) 
                + "," + PApplet.parseInt((getPos().y - tramo.getY()));
                
      return s;
  }
  public PVector getPos(){
    return tramo.get(idx);
  }
  
  public float getDistanceFromStart(){
    return tramo.getDistanceFromStart(idx);
  }
  public int getIndex(){
    return idx;
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
  
  public boolean checkAvgSpeed(int proyectionIndex, float time, float speed){
    last = new LoopPoint(tramo, proyectionIndex, time, speed, "none");
    float avg = calculateAvgSpeedOfLastPeriod();
    return avg < 40 && avg >= 10;
  }
  
  public void add(int proyectionIndex, float time, float speed, String status) {
    speed = speed * 1000/3600;
    last = new LoopPoint(tramo, proyectionIndex, time, speed, status);
    float avg = calculateAvgSpeedOfLastPeriod();
    loopTrack.add(last);
    writePoint(last); 
  }
  
  
  
  public void writePoint(LoopPoint last){
    float error = car.pos.dist(last.getPos());
    
    float avg = calculateAvgSpeedOfLastPeriod();
   
    String s = "";
    s += car.id;
    s += "," + str(tramo.id);
    s += "," + last.toString();
    s += "," + PApplet.parseInt(avg * 10) / 10.0f;
    s += "," + PApplet.parseInt(getTotalTime());
    s += "," + PApplet.parseInt(getDistanceFromStart());
    s += "," + PApplet.parseInt((tramo.getTotalLength() - getDistanceFromStart()));
    s += "," + PApplet.parseInt(error);
   
    if(last.status == "running")
      accError += error;
    
    mysql.insertTrack(s, true);
     
    
    writeInterpolation(avg);
  }
  

  public void writeInterpolation(float avg){
    if(loopTrack.size() < 2) return;
      LoopPoint prev = loopTrack.get(loopTrack.size() - 2); 
      
      boolean started = true;
      if(prev.status.equals("start"))
        started = false;
        
      for(int i = prev.getIndex() + 1; i < last.getIndex(); i ++){
        if(tramo.getDistanceFromStart(i) < 0){
          continue;
        }
         
        float localDst = tramo.getDistanceFromStart(i) - prev.getDistanceFromStart();
        float localTime = (localDst/avg);
        float time = localTime + prev.time - loopTrack.get(0).time;
        
        if(!started){ 
           loopTrack.get(0).time += time; //encendemos el cron\u00f3metro
           time = 0;
           started = true;
        }
        
        String s = car.id + "," + str(tramo.id) ; 
        s += "," + i;
        s += "," + (PApplet.parseInt(avg * 10)/10.0f);
        s += "," + (PApplet.parseInt(time * 10) /10.0f);
        s += "," + PApplet.parseInt(tramo.getDistanceFromStart(i));
        s += "," + PApplet.parseInt((tramo.getTotalLength() - tramo.getDistanceFromStart(i)));
       
        mysql.insertTrack(s, false);

        if(i >= tramo.getEndIndex()){
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
    if(loopTrack.size() == 0) return 0;
    return last.getDistanceFromStart();
  }
   
  public float getTotalTime() {
    if(loopTrack.size() == 0) return 0;
    return last.time - loopTrack.get(0).time;
  }
    
   public float calculateAvgSpeedOfLastPeriod() {
    if (loopTrack.size() > 1) {
      LoopPoint prev = loopTrack.get(loopTrack.size() - 2);
      if (last.time == prev.time) return 0;
      return (last.getDistanceFromStart() - prev.getDistanceFromStart())/(last.time - prev.time);
    }
    else {
      return -1;
    }
  }
  
  
  


}



class RealTime{
 
   java.util.Date date, current;
   boolean running;
   long offset;
   String prev;  
   
   RealTime(){ 
       reset();
       running = false;
   }
   public void reset(){
       this.date = new java.util.Date();  
       this.current = new java.util.Date(); 
       this.prev = null;
       offset = 00000;
   }
   public void toggle(){
     running = !running;
     
     if(running) {
       cars.reset();
       mysql.removeTracks();
       prev = null;
     }
     
   }
   public void offset(int i){
     offset += (i * 1000);
   }
   
   public void setEnd(){
     offset = tramos.getTotalTime();
   }
   
   public String getPrevElapsed(){
     if (prev == null){
      Timestamp d =  new Timestamp(tramos.getInitTime());
      prev = d.toString();
     } 
     return prev;
   }
   
   public void setPrevElapsed(String d){
     prev = d;
   }
   
   public String getElapsed(){
     if(running)
       current = new java.util.Date() ; 
       
     if(current.getTime() - date.getTime() + offset  > tramos.getTotalTime()) 
       running = false;
       
     Timestamp d =  new Timestamp( current.getTime() - date.getTime() + tramos.getInitTime() + offset );
     return d.toString(); 
   }
}


class sqlData {
  int carId;
  float x, y;
  float speed;
  int  time;
  String status;
  sqlData() {}
}

class SQL {
  MySQL msql;
  MySQL remote;
  
  SQL(MySQL msql, MySQL remote) { 
    this.msql = msql; 
    this.remote = remote;
    msql.connect();
    println("Connected to local DB");
    remote.connect();
    println("Connected to remote DB");
  }
  public void loadCars() {
    msql.query( "SELECT * FROM cars  WHERE active = 1 ORDER BY carId");
    while (msql.next ())
    {
        int id = msql.getInt("carId");
         String name = msql.getString("name");
         String theColor = msql.getString("color");;
         Car c = new Car(id, name);
         c.setColor(theColor);
         cars.add(c);
    }
   
   }
 public int loadTramos() {
   msql.query( "SELECT count(*) as n FROM tramos ");
   while (msql.next()){
     return msql.getInt("n");
   }
   return 0;
 }
 public Tramo loadTramo(int focus){
    msql.query( "SELECT * FROM tramos");
    int i = 0;
    while (msql.next ())
    {  
         if(i < focus) {
           i += 1;
           continue;
         }
         String prueba = msql.getString("prueba");
         int id = msql.getInt("id");
         String fileName =  prueba + "/" + str(id) + "/" + str(id) + "_utm.txt";
         int start =  msql.getInt("start");
         int end = -abs(msql.getInt("end"));
         String initTime = msql.getString("initTime");
         String endTime = msql.getString("endTime");
         return new Tramo(prueba, id, fileName, start, end, initTime, endTime);
     }
     return null;
 }
  public void updateTramoStartEnd(int id, int start, int end){
      msql.execute( "UPDATE tramos SET start = " + str(start) + " WHERE id ="+ str(id));
      msql.execute( "UPDATE tramos SET end = " + str(end) + " WHERE id ="+ str(id));
  }
  
  
  public void setInit(int id, String timeStamp){
         msql.execute( "UPDATE tramos SET initTime = '" + timeStamp + "' WHERE id = "+ str(id));
  }
  public void setEnd(int id, String timeStamp){
         msql.execute( "UPDATE tramos SET endTime = '" + timeStamp + "' WHERE id = "+ str(id));
  }
  
  public void remove() {
   
    String iDate =  tramos.initDate();
    String eDate =  tramos.endDate();
    
    msql.query("DELETE FROM tracks WHERE tramoId = " + str(tramos.tramo.id));
    String q = "UPDATE data SET processed = 0 WHERE timeStamp > '" + iDate+ "' " + " and  timeStamp < '" + eDate+ "'" ;
    println(q);
    remote.query(q);
  }
  public void removeTracks(){
    String q = "DELETE FROM tracks WHERE tramoId = " + str(tramos.tramo.id);
     msql.query(q);
     println(q);

  }
  
  public void updateDiferido() {
    String iDate =  rt.getPrevElapsed();
    String eDate =  rt.getElapsed();
    rt.setPrevElapsed(eDate);
    String q = "UPDATE data SET processed = 0 WHERE timeStamp > '" + iDate+ "' " + " and  timeStamp < '" + eDate+ "'" ;
    
     println(q);
    remote.query(q);
  }
  
  public void process() {
    if(rt.running) updateDiferido();
    
    String iDate =  tramos.initDate();
    String eDate =  tramos.endDate();
    remote.query( "SELECT count(*) as n FROM data WHERE processed = 0 and timeStamp > '" 
                + iDate+ "' " + " and  timeStamp < '" + eDate+ "'" );
    
    while (remote.next ()){
      int total = remote.getInt("n");
      println("Processing... " + total + " rows");
      break;
    }
    String q = "SELECT * FROM data WHERE processed = 0 and timeStamp > '" 
                    + iDate+ "' " + " and  timeStamp < '" + eDate+ "'";
    println(q);
    remote.query(q);
    ArrayList<sqlData> data = new ArrayList<sqlData>();
    while (remote.next ())
    {
      sqlData s = new sqlData();
      s.carId= remote.getInt("carId"); 
      s.x = remote.getFloat("x"); 
      s.y = remote.getFloat("y"); 
      s.speed = remote.getFloat("speed"); 
      try{
        s.time = PApplet.parseInt(remote.getString("time").substring(5, 10));
      }catch(Exception e){
        s.time = PApplet.parseInt(remote.getString("time"));
        print(e);
        continue;
      }
      s.status =  remote.getString("status");
      data.add(s);
    }

    for (sqlData s: data) 
      cars.addData(s.carId, s.x, s.y, s.speed, s.time, s.status);
    
    remote.execute( "UPDATE data SET processed = 1");
    
  }
  
  public void insertTrack(String s, boolean full) {
    if (full)
      msql.query("INSERT INTO tracks VALUES (" + s  + ")");  
    else
      msql.query("INSERT INTO tracks (CarId, TramoId, realIndex, avgSpeed, trackTime, trackDistance, remainingDistance) VALUES (" + s  + ")");
  }
  public void insertResult(int carId, int tramoId, float time){
    String q = "DELETE FROM results WHERE tramoId = " + str(tramoId) + " and carId = " + str(carId);
    msql.query(q);
    String s = str(carId) + "," + str(tramoId) + "," + str(time) + ",'" + PApplet.parseInt(time)/60 + ":" + PApplet.parseInt(time)%60 + "'"; 
    q = "INSERT INTO results (CarId, TramoId, time, timeString) VALUES (" + s + ")";
    msql.query(q);

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
  float startTime = 0;
  float endTime = 0;
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
    return car.pos.dist(t.get(proyection)) < trackThreshold;
  }

  public boolean updateStart() {  
    if (inTrack && 
      !running && 
      proyection > t.getStartIndex()
      ) {
      startTime = car.time;
      return true;
    }
    return false;
  }
  
  public boolean updateEnd() {
    if (running 
        && proyection > t.getEndIndex()){
      endTime = car.time;
      return true;
    }
    return false;
  }

 public void update() {
    if(finish) return;
    pProyection = proyection;
    proyection = updateProyection(car.pos);
    if(proyection < pProyection) 
      return;
    
    if(running && !loopTrack.checkAvgSpeed(proyection, car.time, car.speed))
      return;
   
    
    
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
        mysql.insertResult(car.id, t.id,  getTotalTime());
      }
      else{
        loopTrack.add(proyection, car.time, car.speed, "running");
      }
    }
   
  }
 
  public float getDistanceFromStart(){
    if(loopTrack == null) return t.getDistanceFromStart(proyection);
    return loopTrack.getDistanceFromStart();
  }
  public float getTotalTime() {
    return loopTrack.getTotalTime();
 
  }
  

}



class Tramos {
  int n;
  int focus;
  Tramo tramo;
  Cars cars;
  
  Tramos() {
    this.n = mysql.loadTramos();
  }
  
  public void setTramo(int i) {
    if(n == 0) {
      tramo = null;
      println("[ERROR] no existen tramos;");
      return;
    }
    if(i >= n) i = 0;
    else this.focus = i;
    loadTramo(focus);
    rt = new RealTime();
    cars.registerTramo(tramo);
  }
  
  public void loadTramo(int i){
    tramo = mysql.loadTramo(i);
    
  }
  
  public void changeFocus(int i) {
    focus = (focus + i) % n;
    if(focus < 0) focus = n - 1;
    setTramo(focus);
  }
  
  public int size(){
     return n;
  }
  public void drawInfo(int x, int y){
    tramo.drawInfo(x, y);
    pushStyle();
    fill(255);
    textSize(12);
    pushMatrix();
    translate(x, y);
    text("Elapsed: " + rt.getElapsed(), 0, 120);
    popMatrix();
    popStyle();
    
  }
  public float getX(){
    return tramo.getX();
  }
  
  public float getY(){
    return tramo.getY();
  }
  public void draw(){
    tramo.draw();
  }
   public void addStart(int i) {
    tramo.addStart(i);
  }

  public void addEnd(int i) {
    tramo.addEnd(i);
  }
  public void setInitTime(){
    tramo.setInitTime();
  }
  
  public void setEndTime(){
    tramo.setEndTime();
  }
  public long getInitTime(){
    return tramo.getInitTime().getTime();
  }
   public long getEndTime(){
    return tramo.getEndTime().getTime();
  }
  
  public long getTotalTime(){
    return  tramo.getEndTime().getTime() - tramo.getInitTime().getTime();
  }
  public void registerCars(Cars cars){
     this.cars = cars;
    
  }
  public String initDate(){
    return (new Timestamp(getInitTime())).toString();
  }
   public String endDate(){
    return (new Timestamp(getEndTime())).toString();
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

public void keyReleased() {
  if (key == CODED && keyCode >=0 && keyCode < 255) 
    keyCodes[keyCode] = false;
  
  else if (key >= 0 && key < 255) 
    keys[key] = false;
}

public void keyPressed() {
  lastActivity  =millis();
 
  if (key == CODED && keyCode >=0 && keyCode < 255) 
    keyCodes[keyCode] = true;
    
  if (key >= 0 && key < 255) 
    keys[key] = true;
  
  if (key == CODED && keyCode == UP) {
      if(keys['e']) tramos.addEnd(1);
      if(keys['i']) tramos.addStart(1);
      if(keys['t']) {
        trackThreshold += 1;
        saveSetting("trackThreshold", trackThreshold);
      }
      if(keys['1']) {
        tramos.changeFocus(1);
        saveSetting("focus", tramos.focus);
         dX = 0;
        dY = 0;
        saveSetting("dX", dX);
        saveSetting("dY", dY);
      }
    } 
    else if (key == CODED &&  keyCode == DOWN) {
      if(keys['e']) tramos.addEnd(-1);
      if(keys['i']) tramos.addStart(-1);
      if(keys['t']) {
        trackThreshold -= 1;
        saveSetting("trackThreshold", trackThreshold);
      }
      if(keys['1']) {
        tramos.changeFocus(-1);
        saveSetting("focus", tramos.focus); 
        dX = 0;
        dY = 0;
        saveSetting("dX", dX);
        saveSetting("dY", dY);
      }
    } 

    
    if(key == 'I')
      tramos.setInitTime();
    else if(key == 'E')
      tramos.setEndTime();
    else if(key == 'q')
      rt.toggle();
    else if(key == 'M')
      rt.offset(60);
    else if(key == 'R'){
      cars.reset();
      mysql.remove();
      rt.running = false;
    }
     if(key == 'C'){
        dX = 0;
        dY = 0;
        dZ = 0.05f;
        saveSetting("dX", dX);
        saveSetting("dY", dY);
        saveSetting("dZ", dZ);
    }
    
   if (key == ' ') {
       bProcess = !bProcess;
    }
    
    
}


public void mouseDragged() {
  lastActivity  =millis();
  if(keyCodes[ALT]){
    dZ += (pmouseY - mouseY) / (height * 10.0f);
    if (dZ <= 0.001f) dZ = 0.001f;
    saveSetting("dZ", dZ);

  }
  else {
    if(keyCodes[SHIFT]){
      dX -= (pmouseX - mouseX) / dZ;
      dY += (pmouseY - mouseY) / dZ;
      saveSetting("dX", dX);
      saveSetting("dY", dY);
    }
  }
}
public void mouseClicked(){   
  lastActivity  =millis();
}

class TramoPoint {
  PVector pos;
  float dst;
  TramoPoint(PVector pos, float dst) {
    this.dst = dst;
    this.pos = pos;
  }
}

class Tramo {
  int id = -1;
  String prueba;
  ArrayList<TramoPoint> data;
  int start, end;
  java.util.Date initTime, endTime;

  Tramo(String prueba, int id, String fileName, int start, int end, String initTime, String endTime) {
    loadData(fileName);
    this.id = id;
    this.prueba = prueba;
    this.start = start;
    this.end = end;
    updateStartEnd();
    if(initTime == null) 
      setInitTime();
    else
      this.initTime = new Date(Timestamp.valueOf(initTime).getTime());
    
    if(endTime == null)
      setEndTime();
    else
      this.endTime = new Date(Timestamp.valueOf(endTime).getTime());
  }

  public void loadData(String fileName) {
    String lines[] = loadStrings(host + "Tramos/"+ fileName);
    float dst = 0;
    data = new ArrayList<TramoPoint>();
    PVector pos, pPos = null;
    for (int i = 0 ; i < lines.length; i++) {
      String[] tokens = splitTokens(lines[i]);
      pos = new PVector(PApplet.parseFloat(tokens[1]), PApplet.parseFloat(tokens[0]));
      if (pPos != null) dst += pos.dist(pPos);
      else dst = 0;
      pPos = pos;
      data.add(new TramoPoint(pos, dst));
    }
    println(fileName + " loaded");
  }
  public void drawInfo(int x, int y){
    pushStyle();
    fill(255);
    textSize(12);
    pushMatrix();
    translate(x, y);
    fill(120, 155, 249);
    text(prueba + " " + id, 0, 0);
    fill(255);
    text("Longitud: " +  PApplet.parseInt(getRealLength()) + " / " + PApplet.parseInt(getTotalLength()), 0, 20);
    text("UTM coords: (" + getX() + " / " + getY() + ")", 0, 40);
    text("Init time: " + initTime, 0,  60);
    text("End time: " + endTime, 0,  80);
    popMatrix();
    popStyle();
  }
  
  public void draw() {
    stroke(255);
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
    ellipse(getStart().pos.x,getStart().pos.y, 5/dZ, 5/dZ);
    fill(0, 255, 255);
    noStroke();
    ellipse(getEnd().pos.x ,getEnd().pos.y, 5/dZ, 5/dZ); 
    popStyle();

  }
  
  public float getTotalLength(){
     return data.get(data.size() - 1).dst;
  }
  
  public float getRealLength(){
    return getEnd().dst - getStart().dst;
  }
  
  public float getX(){
    return data.get(0).pos.x;
  }
  
  public float getY(){
    return data.get(0).pos.y;
  }
   public void addStart(int i) {
    start += i;
    updateStartEnd();
  }

  public void addEnd(int i) {
    end -= i;
    updateStartEnd();
  }
  
  public TramoPoint getStart() {
    return data.get(start);
  }

  public TramoPoint getEnd() {
    return data.get(data.size() -1 + end);
  }
  
   public void updateStartEnd(){
      if (start < 1) start = 1;
      if (end > -1) end = -1;
      
      mysql.updateTramoStartEnd(id, start, end);
  }
  
  public void setInitTime(){	 
      java.util.Date date= new java.util.Date();  
      initTime = new Timestamp(date.getTime());
      mysql.setInit(id, initTime.toString());
  }
  
  public void setEndTime(){
      java.util.Date date= new java.util.Date();  
      endTime = new Timestamp(date.getTime());
      mysql.setEnd(id, endTime.toString());
  }
   public java.util.Date getInitTime(){
    return initTime;
  }
  
   public java.util.Date getEndTime(){
    return endTime;
  }
  
  public int getClosest(PVector pos) {
    float minDist = 10000000;
    int idx = -1;
    int i = 0;
    for (TramoPoint p: data) {
      float d = pos.dist(p.pos);
      if (d < minDist) {
        idx = i;
        minDist = d;
      }
      i ++;
    }
    return idx;
  }
  
  public int getStartIndex(){
    return start;
  }
   public int getEndIndex(){
    return data.size() - 1 + end;
  }
   public PVector get(int i) {
    return data.get(i).pos;
  }
  public float getDistanceFromStart(int i) {
    return data.get(i).dst - getStart().dst;
  }
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "unityTracking" });
  }
}
