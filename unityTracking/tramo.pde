class TramoPoint {
  PVector pos;
  float dst;
  float avgSpeed;
  TramoPoint(PVector pos, float dst) {
    this.dst = dst;
    this.pos = pos;
    avgSpeed = 0;
  }
}

class Tramo {

  ArrayList<TramoPoint> data;
  TramoPoint end, start;
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
  }
  void draw() {
    if (bFocus)
      stroke(255);
    else
      stroke(255, 50);

    for (int i = 0 ; i < n - 1; i++) {
      float x0 = data.get(i).pos.x;
      float y0 = data.get(i).pos.y;
      float x1 = data.get(i + 1).pos.x;
      float y1 = data.get(i + 1).pos.y;
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
  }

  void setFocus(boolean b) {
    bFocus = b;
  }

  float getDistanceFromStart(PVector pos) {
    for (TramoPoint p: data) {
      if (p.pos.x == pos.x && p.pos.y == pos.y)
        return p.dst;
    }
    return -1;
  }
  
  PVector getClosest(PVector pos){
   float minDist = 10000000;
   PVector proyection = null;
    for (TramoPoint p: data) {
      float d = pos.dist(p.pos);
      if (d < minDist) {
        proyection = p.pos;
        minDist = d;
      }
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

