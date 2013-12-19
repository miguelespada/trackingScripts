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
  tramos.add(0, "0_trackUtm.txt");
  tramos.add(1, "1_trackUtm.txt");

  cars = new Cars();
  tramos.register(cars);

  dX = loadSetting("dX", 6000);
  dY = loadSetting("dY", 7500);
  dZ = loadSetting("dZ", 0.05);
  int f = loadSetting("focus", 0);

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
  popMatrix();

  cars.displayInfo(10, 20);
  tramos.drawCurrentClassification(width - 200, 20);
  tramos.drawFinalClassification(width - 100, 20);
 // cars.sendActiveCars(tramos.focus);
}

