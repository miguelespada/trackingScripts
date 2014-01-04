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

void setup() {


  size(800, 600);
  frameRate(30);
  smooth();
  loadSettings();

  initializeKeys();
  
  dX = loadSetting("dX", 6000);
  dY = loadSetting("dY", 7500);
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
  setupMySQL();
  
 
}
void initSystem(){
  
  
  tramos = new Tramos(host + "Tramos/tramos.txt");
  ref = tramos.setFocus(focus);
  
  cars = new Cars();
  cars.registerTramos(tramos);
  cars.loadCars(host + "Cars/cars.txt");
  cars.loadLoops();
}

void draw() {
  selectMySQL();
    
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

