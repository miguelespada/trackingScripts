class TramoPoint {
  PVector pos;
  float dst;
  float accSpeed;
  float n = 0;
  
  TramoPoint(PVector pos, float dst) {
    this.dst = dst;
    this.pos = pos;
    this.accSpeed = 0;
    this.n = 0;
  }
  
  void addAvg(float avg){
    this.accSpeed += avg;  
    this.n += 1;
  }
  float getAvg(){
    return accSpeed/n;
  }
}

class Tramo {

  ArrayList<TramoPoint> data;
  TramoPoint end, start;
  int n;
  int id;
  boolean bFocus = false;
  float totalLength;

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
    data = new ArrayList<TramoPoint>();
    float dst = 0;
    for (int i = 0 ; i < n; i++) {
      String[] tokens = splitTokens(lines[i]);
      PVector pos = new PVector(int(tokens[0]), int(tokens[1]));
      if (i > 1)
        dst += data.get(i - 1).pos.dist(pos);
      data.add(new TramoPoint(pos, dst));
    }
    if (n > 0) {
      start = data.get(0);
      end = data.get(data.size() - 1);
    }
    this.totalLength = dst;
  }
  void draw() {
    int opacity = 255;
    if (!bFocus)
      opacity = 50;
    for (int i = 0 ; i < n - 1; i++) {
      float x0 = data.get(i).pos.x;
      float y0 = data.get(i).pos.y;
      float x1 = data.get(i + 1).pos.x;
      float y1 = data.get(i + 1).pos.y;
      float a = data.get(i).getAvg();
      stroke(255, opacity);
      point(x0, y0);
      line(x0, y0, x1, y1);
    }
    pushStyle();
    fill(255, 0, 0);
    noStroke();
    ellipse(start.pos.x, start.pos.y, 10, 10);
    fill(0, 255, 0);
    noStroke();
    ellipse(end.pos.x, end.pos.y, 10, 10); 
    popStyle();
    colorMode(RGB);
  }

  void setFocus(boolean b) {
    bFocus = b;
  }

  float getDistanceFromStart(PVector pos) {
    for (TramoPoint p: data) {
      if(p.pos.equals(pos))
        return p.dst;
    }
    return -1;
  }
  void propagateAverages(PVector i, PVector o, float avg){
     boolean found = false;
     
     for (TramoPoint p: data) {
      if(found || p.pos.equals(i))  
        found = true;
      
      if(found)
        p.addAvg(avg);  
      if(found && p.pos.equals(o))  
        found = false;
     }  
    
  }
  PVector get(int i){
    return data.get(i).pos;
  }
  
  int getClosest(PVector pos){
   float minDist = 10000000;
   int proyection = -1;
   int i = 0;
   for (TramoPoint p: data) {
      float d = pos.dist(p.pos);
      if (d < minDist) {
        proyection = i;
        minDist = d;
      }
      i ++;
    }
    return proyection;
  }
  float distToStart(PVector pos){
    return pos.dist(start.pos);
  }
  
  float distToEnd(PVector pos){
    return pos.dist(end.pos);
  }
  PVector getStart(){
    return start.pos;
  }

  void calculateCurrentClassification() {
    ArrayList<Car> activeCars = cars.getActiveCars(id);
    clasification.clear();
    for (Car c: activeCars) {
      int i = 0;
      float d = c.getActiveDistance();
      while (i < clasification.size ()) {
        if (d > clasification.get(i).getActiveDistance())
          break;
        else
          i ++;
      }
      clasification.add(i, c);
    }
  }

  void calculateFinalClassification() {
    ArrayList<Car> finalizedCars = cars.getFinalizedCars(id);
    finalClasification.clear();
    for (Car c: finalizedCars) {
      int i = 0;
      float d = c.getEndTime();
      while (i < finalClasification.size ()) {
        if (d < finalClasification.get(i).getEndTime())
          break;
        else
          i ++;
      }
      finalClasification.add(i, c);
    }
  }


  void drawCurrentClassification(int x, int y) {
    pushStyle();
    stroke(255);
    fill(255);
    textSize(10);
    String s = "TRAMO (dst) - " + id + "\n" ;
    for (Car c: clasification) {
      s += c.id + "   " + int(c.getActiveDistance());
      s += " m \n";
    }
    text(s, x, y);
    popStyle();
  }

  void drawFinalClassification(int x, int y) {
    pushStyle();
    stroke(255);
    fill(255);
    textSize(10);
    String s = "TRAMO (time) - " + id + "\n" ;
    for (Car c: finalClasification) {
      s += c.id + "   " + int(c.getEndTime());
      s += " s \n";
    }
    text(s, x, y);
    popStyle();
  }
}

