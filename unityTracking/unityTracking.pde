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

void setup() {

  size(900, 700);
  initServices();
  initSystem();
}

void initServices() {

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
  dZ = loadSetting("dZ", 0.05);
  host = loadSetting("host", "");
  trackThreshold = loadSetting("trackThreshold", 30);
  initializeKeys();
}

void initSystem() {
  cars = new Cars();
  cars.loadCars();
  
  tramos = new Tramos();
  tramos.registerCars(cars);
  
  tramos.setTramo(loadSetting("focus", 0));
  rt = new RealTime();
}

void draw() {
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

void drawInfo(int x, int y){
  pushStyle();
  fill(255);
  textSize(12);
  translate(x, y);
  text("Center: (" + int(dX) + " / " + int(dY) + " / " + int(dZ*10000) + ")", 0, 20);
  text("fps: " + int(frameRate), 0,  40);
  text("Resolution: " + int(width/(1000.0* dZ))  + " km", 0,  60);
    text("In Track Threshold: " + trackThreshold + " m", 0, 80);

  noStroke();
  fill(255, 0, 0);
  if(bProcess) 
    fill(0, 255, 0);
  ellipse(7.5, 0, 15, 15);
  popStyle();
}

