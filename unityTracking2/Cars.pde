
class Cars {
  ArrayList<Car> cars;
  Tramos ts; 
  String fileName;
  Cars() {
    cars = new ArrayList<Car>();
    
  }
  void loadCars(String fileName){
    this.fileName = fileName;
    String lines[] = loadStrings(fileName);
    try{
      for (int i = 0 ; i < lines.length; i++) {
         lines[i] = lines[i].replace(" ", "");
         String[] tokens = splitTokens(lines[i], ",");
         int id = int(tokens[0]);
         String name = tokens[1];
         String theColor = tokens[2];
         int enabled = int(tokens[3]);
         Car c = new Car(id, name);
         c.setColor(theColor);
         add(c);
         if(enabled == 1) 
           c.enabled = true;
         else
           c.enabled = false;
         logFile.println("Car added: " + name + " " + id);
      }
    }
    catch(Exception e){
      logFile.println("ERROR: reading cars");
    }
  }
  void writeCars(){
    PrintWriter output = createWriter(fileName);  
    for (Car c: cars){
        String s = c.toString();
        output.println(s);
     }
     output.close();
  
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
  void mouseClicked() {
    for(Car c: cars)
      c.mouseClicked();
    writeCars();
  }
  
  void enable() {
    for(Car c: cars)
      c.enabled = true;
    writeCars();
  }
  
  void disable() {
    for(Car c: cars)
      c.enabled = false;
    writeCars();
  }
  
  
  ArrayList<Car> getRunningCars(int tramoId) {
    ArrayList<Car> active = new ArrayList<Car>();
    for (Car c: cars) {
      if (c.isInTramo(tramoId))
        active.add(c);
    }
    return active;
  }
   ArrayList<Car> getFinalizedCars(int tramoId) {
    ArrayList<Car> active = new ArrayList<Car>();
    for (Car c: cars) {
      if (c.finished(tramoId))
        active.add(c);
    }
    return active;
  }  
  ArrayList<Car> calculateCurrentClassification(int tramoId) {
    ArrayList<Car> activeCars = getRunningCars(tramoId);
    ArrayList<Car> classification = new ArrayList<Car>();
    
    for (Car c: activeCars) {
      int i = 0;
      float d = c.getDistanceFromStart(tramoId);
      while (i < classification.size ()) {
        if (d > classification.get(i).getDistanceFromStart(tramoId))
          break;
        else
          i ++;
      }
      classification.add(i, c);
    }
    return classification;
  }
   ArrayList<Car> calculateFinalClassification(int tramoId) {
    ArrayList<Car> activeCars = getFinalizedCars(tramoId);
    ArrayList<Car> classification = new ArrayList<Car>();
    
    for (Car c: activeCars) {
      int i = 0;
      float d = c.getTotalTime(tramoId);
      while (i < classification.size ()) {
        if (d < classification.get(i).getTotalTime(tramoId))
          break;
        else
          i ++;
      }
      classification.add(i, c);
    }
    return classification;
  }
  void drawCurrentClassification(int tramoId, int x, int y) {
    ArrayList<Car> classification = calculateCurrentClassification(tramoId);
    pushStyle();
    stroke(255);
    fill(255);
    textSize(10);
    String s = "" ;
    for (Car c: classification) {
      s += c.id + "   " + int(c.getDistanceFromStart(tramoId));
      s += " m \n";
    }
    text(s, x, y);
    popStyle();
  }
   void drawFinalClassification(int tramoId, int x, int y) {
    ArrayList<Car> classification = calculateFinalClassification(tramoId);
    pushStyle();
    stroke(255);
    fill(255);
    textSize(10);
    String s = "" ;
    for (Car c: classification) {
      s += c.id + "   " + int(c.getTotalTime(tramoId));
      s += " s \n";
    }
    text(s, x, y);
    popStyle();
  }
}

