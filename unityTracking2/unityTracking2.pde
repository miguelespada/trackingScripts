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
float lastActivity;
SQL mySql, myRemoteSql;
void setup() {
  mySql = new SQL(new MySQL(this, "localhost:8889", "unity", "miguel", "miguel"),
                  new MySQL(this, "147.96.81.188", "unity", "root", "wtw6sb"));


  size(900, 700);
  smooth();
  loadSettings();

  initializeKeys();
  
  dX = loadSetting("dX", 0);
  dY = loadSetting("dY", 0);
  dZ = loadSetting("dZ", 0.05);
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
  
  frameRate(30);
 
}

void initSystem(){
  tramos = new Tramos(host + "Tramos/montecarlo.txt");
  ref = tramos.setFocus(focus);
  println("REF: " + ref.x + " " + ref.y);
  cars = new Cars();
  cars.registerTramos(tramos);
  cars.loadCars();
}

void draw() {
    if(millis() > lastActivity + 10000){
      background(25);    
      frameRate(1);
    }
    else{
      frameRate(30);
      background(0);
    }
    mySql.process();
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
    cars.drawCurrentClassification(focus, width - 200, 20);
    cars.drawFinalClassification(focus, width - 100, 20);
  
    drawInfo();
}

void drawInfo(){
  pushStyle();
  fill(255);
  textSize(12);
  text("Tramo: " + tramos.getFocusName(), width - 150, height - 60);
  text("Threshold: " + trackThreshold, width - 150, height - 100);
  text("dZ: " + dZ, width - 150, height - 120);
  popStyle();
}

