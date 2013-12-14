class Tramo {

  PVector data[];
  PVector end, start;
  int n;
  int id;
  boolean bFocus = false;
  ArrayList<Car> clasification;
  ArrayList<Car> finalClasification;

  Tramo(int id) {
    this.id = id;
    clasification = new ArrayList<Car>();
    finalClasification = new ArrayList<Car>();
  }
  
  boolean inFocus() {
    return bFocus;
  }
  
  void loadData(String fileName) {
    String lines[] = loadStrings(fileName);
    n = lines.length;
    data = new PVector[n];
    for (int i = 0 ; i < n; i++) {
      String[] tokens = splitTokens(lines[i]);
      data[i] = new PVector(int(tokens[0]), int(tokens[1]));
    }
    if (n > 0) {
      start = data[0];
      end = data[n - 1];
    }
  }
  void draw() {
    if (bFocus)
      stroke(255);
    else
      stroke(255, 50);

    for (int i = 0 ; i < n - 1; i++) {
      float x0 = data[i].x;
      float y0 = data[i].y;
      float x1 = data[i + 1].x;
      float y1 = data[i + 1].y;
      point(x0, y0);
      line(x0, y0, x1, y1);
    }
    pushStyle();
      fill(255, 0, 0);
      noStroke();
      ellipse(start.x, start.y, 10, 10);
      fill(0, 255, 0);
      noStroke();
      ellipse(end.x, end.y, 10, 10); 
    popStyle();
  }
  
  void setFocus(boolean b) {
    bFocus = b;
  }
  
  float calculateDistanceFromStart(PVector pos){
    float d = 0;
    for(int i = 1; i < n; i ++){
      PVector p0 = data[i - 1];
      PVector p1 = data[i];
      if(pos.x == p0.x && pos.y == p0.y)
        break;
      d += p0.dist(p1);
    }
    return d;
  }
  
  void calculateCurrentClassification(){
    ArrayList<Car> activeCars = cars.getActiveCars(id);
    clasification.clear();
    for(Car c: activeCars){
      int i = 0;
      float d = c.getActiveDistance();
      while(i < clasification.size()){
        if(d > clasification.get(i).getActiveDistance())
          break;
        else
          i ++;
      }
      clasification.add(i, c);
    }
  }
  
  void calculateFinalClassification(){
    ArrayList<Car> finalizedCars = cars.getFinalizedCars(id);
    finalClasification.clear();
    for(Car c: finalizedCars){
      int i = 0;
      float d = c.getEndTime();
      while(i < finalClasification.size()){
        if(d < finalClasification.get(i).getEndTime())
          break;
        else
          i ++;
      }
      finalClasification.add(i, c);
    }
  }
  
  
  void drawCurrentClassification(int x, int y){
    pushStyle();
    stroke(255);
    fill(255);
    textSize(10);
    String s = "TRAMO (dst) - " + id + "\n" ;
    for(Car c: clasification){
      s += c.id + "   " + int(c.getActiveDistance());
      s += " m \n";
    }
    text(s, x, y);
    popStyle();
  }
  
   void drawFinalClassification(int x, int y){
    pushStyle();
    stroke(255);
    fill(255);
    textSize(10);
    String s = "TRAMO (time) - " + id + "\n" ;
    for(Car c: finalClasification){
      s += c.id + "   " + int(c.getEndTime());
      s += " s \n";
    }
    text(s, x, y);
    popStyle();
  }
  
}

