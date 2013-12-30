
class Cars {
  ArrayList<Car> cars;
  Tramos ts; 

  Cars() {
    cars = new ArrayList<Car>();
    
  }
  void loadCars(String fileName){
    String lines[] = loadStrings(fileName);
    try{
      for (int i = 0 ; i < lines.length; i++) {
         String[] tokens = splitTokens(lines[i], ",");
         int id = int(tokens[0]);
         String name = tokens[1];
         String theColor = tokens[2];
         Car c = new Car(id, name);
         c.setColor(theColor);
         add(c);
         println("Car added: " + name + " " + id);
      }
    }
    catch(Exception e){
      println("ERROR: reading cars");
    }
  }
  void add(Car c) {
    cars.add(c);
    registerTramo(c, ts);
  }

  void update() {
      for (Car c: cars)
        c.update();
  }

  void addData(int id, float x, float y, float s, int d) {
    for (Car c: cars) {
      if (c.id == id) {
        c.addPoint(x, y, s, d);
        return;
      }
    }
  }


  void draw() {
    for (Car c: cars)
      c.draw();
  }

  void registerTramos(Tramos ts) {
    this.ts = ts;
  }

  void registerTramo(Car c, Tramos ts) {
    for (Tramo t: ts.tramos)
      c.registerTramo(t);
  }

  void displayInfo(int tramoId, int x, int y, int opacity) {
    for (Car c: cars) {
      int nextY = y + c.drawInfo(tramoId, x, y, opacity);
      y = nextY;
    }
  }
  
  
  
  void drawLoop(){
     for (Car c: cars)
       c.drawLoop();
  }
  void loadLoops(){
    for(Car c: cars){
      c.loadLoops();
    }
  }
  void removeLoops(){
    for(Car c: cars)
      c.removeLoops();
    
  }
}

