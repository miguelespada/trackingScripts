PVector ref;

float dX;
float dY;
float dZ;
String iDate, eDate;

Cars cars; 
Tramos tramos;
int focus;
String host = "";
int trackThreshold;
int M = 20;
float lastActivity, lastProcess;
SQL mySql, myRemoteSql;
boolean showAll = false;

void setup() {
  mySql = new SQL(new MySQL(this, "localhost:8889", "unity", "miguel", "miguel"),
                  new MySQL(this, "147.96.81.188", "unity", "root", "wtw6sb"));

  size(900, 700);
  loadSettings();

  initializeKeys();
  
  dX = loadSetting("dX", 0);
  dY = loadSetting("dY", 0);
  dZ = loadSetting("dZ", 0.05);
  focus = loadSetting("focus", 0);
  host = loadSetting("host", "");
  trackThreshold = loadSetting("trackThreshold", 30);
  initSystem();
}

void initSystem(){
  tramos = new Tramos(focus);
  println(tramos.size());
 /* ref = tramos.setFocus(focus);
  cars = new Cars();
  cars.registerTramos(tramos);
  cars.loadCars();*/
  
}

void draw() {
   /* if(millis() > lastActivity + 10000){
      background(50);    
      frameRate(1);
    }
    else{
      frameRate(30);
      background(0);
    }
    
    if(millis() > lastProcess + 1000 && !keyPressed) {
      mySql.process();
      lastProcess = millis();
      iDate = mySql.getInitTime(tramos.getFocusName());
      eDate = mySql.getEndTime(tramos.getFocusName());
    }
    
    stroke(255);
    pushMatrix();
    
    translate(width/2, height/2);
    scale(dZ);
    translate(-width/2, -height/2);
    scale(1, -1);
    translate(dX - ref.x, dY - ref.y);
    strokeWeight(1/dZ);
    tramos.draw();  
    cars.draw();
    popMatrix();
   
    cars.displayInfo(tramos.focus, 10, 2, 255);
    cars.drawCurrentClassification(tramos.getFocusId(), width - 200, 20);
    cars.drawFinalClassification(tramos.getFocusId(), width - 100, 20);
  
    drawInfo();*/
}

void drawInfo(){
  /*
  pushStyle();
  fill(255);
  textSize(12);
  translate(width - 300, height - 20);
  text("Tramo: " + tramos.getFocusName() + " (" + tramos.getFocusId() + "/" + tramos.size() + ")", 0, - 140);
  text("Resolution: " + int(width/(1000.0* dZ))  + " km", 0, - 120);
  text("Threshold: " + trackThreshold + " m", 0, - 100);
  
  text("Session init: " + iDate, 0,  - 80);
  text("Session end: " + eDate, 0,  - 60);
  text("(start/end): " + "(" + ref.x + "," + ref.y + ")", 0,  - 40);
  
  text("Initial coords: " + "(" +  tramos.getFocusStart() + "," + tramos.getFocusEnd() + ")", 0,  - 20);
  text(int(frameRate), 0,  0);
  popStyle();*/
}
