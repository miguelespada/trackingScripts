PVector ref;

float dX;
float dY;
float dZ;
Cars cars; 
Tramos tramos;

void setup() {
  size(800, 600);
  frameRate(30);
  smooth();
  loadSettings();

  setupOsc();
  initializeKeys();

  tramos = new Tramos();
  Tramo t = new Tramo(0, "1_trackUtm.txt", "splineDeformadoUTM.txt");
  tramos.add(t);

  
  
  
 // tramos.add(0, "tramoDXFnorm2.txt");
//  tramos.add(1, "tramoDXFnorm2.txt");
//  tramos.add(2, "tramoDXFnorm3.txt");
 //  tramos.add(1, "bounding.txt");

  cars = new Cars();
  tramos.register(cars);

  dX = loadSetting("dX", 6000);
  dY = loadSetting("dY", 7500);
  dZ = loadSetting("dZ", 0.05);
  int f = loadSetting("focus", 0);
  f = 0;
  ref = tramos.setFocus(f);
}

void draw() {
  background(0);
  stroke(255);
  pushMatrix();
  scale(dZ);
  translate(dX -ref.x, dY -ref.y);
  strokeWeight(1/dZ);
  tramos.draw();
  cars.update();
  cars.draw();
  cars.drawLoop(tramos.focus);
  popMatrix();
  
  
 cars.displayInfo(tramos.focus, 10, 20, 255);
 
 tramos.drawCurrentClassification(tramos.focus, width - 200, 20);
 tramos.drawFinalClassification(tramos.focus, width - 100, 20);
 
  //cars.sendLoop(tramos.focus);
 cars.sendActiveCars(tramos.focus);
 
}

