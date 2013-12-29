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
  
  dX = loadSetting("dX", 6000);
  dY = loadSetting("dY", 7500);
  dZ = loadSetting("dZ", 0.05);
  int f = loadSetting("focus", 0);

  tramos = new Tramos("tramos.txt");
  ref = tramos.setFocus(f);
  
  cars = new Cars();
  cars.registerTramos(tramos);
  cars.loadCars("cars.txt");
  cars.loadLoops();
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
  
  popMatrix();
 
  cars.displayInfo(tramos.focus, 10, 20, 255);

}

