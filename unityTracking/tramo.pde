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
class Track{
  ArrayList<TramoPoint> data;
  TramoPoint end, start;
  float totalLength;
  int n;
  
  ArrayList<Car> clasification;
  ArrayList<Car> finalClasification;
  int id;
  
  Track(int id){
    clasification = new ArrayList<Car>();
    finalClasification = new ArrayList<Car>();
    this.id = id;
  }
  
  void loadData(String fileName, PVector ref) {
    String lines[] = loadStrings(fileName);
    n = lines.length;
    float dst = 0;
    data = new ArrayList<TramoPoint>();
    for (int i = 0 ; i < n; i++) {
      String[] tokens = splitTokens(lines[i]);
      PVector pos = new PVector(float(tokens[0]) + ref.x, float(tokens[1]) + ref.y);
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
  
  void loadData(String fileName) {
    loadData(fileName, new PVector(0, 0));
  }
  
  void draw(int opacity) {
    for (int i = 0 ; i < n - 1; i++) {
      float x0 = data.get(i).pos.x;
      float y0 = data.get(i).pos.y;
      float x1 = data.get(i + 1).pos.x;
      float y1 = data.get(i + 1).pos.y;
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
  }
  
   float getDistanceFromStart(PVector pos) {
    for (TramoPoint p: data) {
      if(p.pos.equals(pos))
        return p.dst;
    }
    return -1;
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
    String s = "" ;
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
    String s = "" ;
    for (Car c: finalClasification) {
      s += c.id + "   " + int(c.getEndTime()/10);
      s += " s \n";
    }
    text(s, x, y);
    popStyle();
  }
  
  int length(){
    return data.size();
  }
}

class Tramo {
  Track utm, real;
  int id;
  boolean bFocus = false;
  
  
  Tramo(int id, String utmFile, String realFile) {
    this.id = id;
    utm = new Track(id);
    utm.loadData(utmFile);
    
    real = new Track(id);
    real.loadData(realFile, utm.getStart());
  }
  boolean inFocus() {
    return bFocus;
  }
  void setFocus(boolean b) {
    bFocus = b;
  }

  void drawFinalClassification(int x, int y){
    utm.drawFinalClassification(x, y);
  }
   void drawCurrentClassification(int x, int y) {
    utm.drawCurrentClassification(x, y);
   }
   
  void calculateFinalClassification() {
    utm.calculateFinalClassification();
  }
  
  void calculateCurrentClassification() {
    utm.calculateCurrentClassification();
  }
  
  void draw(int opacity) {
     utm.draw(opacity);
     real.draw(opacity / 4);
  }
  
   float getDistanceFromStart(PVector pos) {
   return utm.getDistanceFromStart(pos);
  }
  
  PVector get(int i){
      return utm.get(i);
  }
  
  int getClosest(PVector pos){
   return utm.getClosest(pos);
  }
  
  float distToStart(PVector pos){
      return utm.distToStart(pos);
  }
  
  float distToEnd(PVector pos){
    return utm.distToEnd(pos);
  }
  
  PVector getStart(){
    return utm.getStart();
  }
  float getTotalLength(){
    return utm.totalLength;
  }
}

