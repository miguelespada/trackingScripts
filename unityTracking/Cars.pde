class Cars {
  ArrayList<Car> cars;
  Tramo tramo;
  
  Cars() {
    cars = new ArrayList<Car>();
  }
  
  void reset(){
    for (Car c: cars) c.reset();
  }
  
  void loadCars(){
    mysql.loadCars();
  }
  
  void add(Car c) {
    cars.add(c);
  }

  void update() {
     for (Car c: cars) c.update();
  }

  void addData(int id, float x, float y, float s, int d, String status) {
    for (Car c: cars) {
      if (c.id == id) {
        c.addPoint(x, y, s, d, status);
        return;
      }
    }
  }


  void draw() {
    for (Car c: cars)
      c.draw();
  }

  void registerTramo(Tramo t) {
    this.tramo = t;
    for (Car c: cars)      
      c.registerTramo(tramo);
  }

  void displayInfo(int x, int y, int opacity) {
    for (Car c: cars) {
      int nextY = y + c.drawInfo(x, y, opacity);
      y = nextY;
    }
  }
  
  ArrayList<Car> getRunningCars() {
    ArrayList<Car> active = new ArrayList<Car>();
    for (Car c: cars) if (c.ts.running) active.add(c);
    return active;
  }
  
  ArrayList<Car> calculateCurrentClassification() {
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
  
  void drawCurrentClassification(int x, int y) {
    ArrayList<Car> classification = calculateCurrentClassification();
    pushStyle();
    stroke(255);
    fill(255);
    textSize(10);
    String s = "" ;
    for (Car c: classification) {      
      float cTime = c.ts.getTotalTime();
      float dst = c.ts.getDistanceFromStart();
      s += c.id + "   " + int(dst) + "m, " + int(cTime)/60 + ":" + int(cTime)%60 + ", " + int((dst/cTime) * 3.6) + " km/h";
      s += "\n";
    }
    text(s, x, y);
    popStyle();
  }
  
   ArrayList<Car> getFinalizedCars() {
    ArrayList<Car> active = new ArrayList<Car>();
    for (Car c: cars) 
      if (c.ts.finish)  active.add(c);
    
    return active;
  }  
    
   ArrayList<Car> calculateFinalClassification() {
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
  
 
   void drawFinalClassification(int x, int y) {
    ArrayList<Car> classification = calculateFinalClassification();
    pushStyle();
    stroke(255);
    fill(255);
    textSize(10);
    String s = "" ;
    for (Car c: classification) {
      float cTime = c.ts.getTotalTime();
      float dst = c.ts.getDistanceFromStart();
      s += c.id + " " + int(cTime)/60 + ":" + int(cTime)%60 + ", " + int((dst/cTime) * 3.6) + " km/h";
      s += "\n";
    }
    text(s, x, y);
    popStyle();
  }

  
}

