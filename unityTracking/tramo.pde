class TramoPoint {
  PVector pos;
  float dst;

  TramoPoint(PVector pos, float dst) {
    this.dst = dst;
    this.pos = pos;
  }
}

class Track {
  ArrayList<TramoPoint> data;
  TramoPoint end, start;
  float totalDst = -1;
  String fileName;
  int startIndex, endIndex;
  Track() {
  }

  void loadData(String fileName, PVector ref) {
    this.fileName = host + "Tramos/"+ fileName;
    String lines[] = loadStrings(this.fileName);
    float dst = 0;
    data = new ArrayList<TramoPoint>();
    for (int i = 0 ; i < lines.length; i++) {
      String[] tokens = splitTokens(lines[i]);
      PVector pos = new PVector(float(tokens[1]) + ref.x, float(tokens[0]) + ref.y);
      if (i > 1)
        dst += data.get(i - 1).pos.dist(pos);
      data.add(new TramoPoint(pos, dst));
    }
    if (lines.length > 0) {
      start = data.get(0);
      end = data.get(data.size() - 1);
    }
    this.totalDst = dst;
  }

  void setStart(int s) {
    startIndex = s;
    start = data.get(startIndex);
  }

  void setEnd(int e) {
    endIndex = data.size() - 1 + e;
  }
  
  int getEndIndex(){
    return endIndex;
  }
  int getStartIndex(){
    return startIndex;
  }

  void loadData(String fileName) {
    loadData(fileName, new PVector(0, 0));
  }

  void draw() {
    for (int i = 0 ; i < data.size() - 1; i++) {
      float x0 = data.get(i).pos.x;
      float y0 = data.get(i).pos.y;
      float x1 = data.get(i + 1).pos.x;
      float y1 = data.get(i + 1).pos.y;
      point(x0, y0);
      line(x0, y0, x1, y1);
    }
    pushStyle();
    fill(0, 255, 0);
    noStroke();
    ellipse(start.pos.x, start.pos.y, 5/dZ, 5/dZ);
    fill(0, 255, 255);
    noStroke();
    ellipse(end.pos.x, end.pos.y, 5/dZ, 5/dZ); 
    popStyle();
  }

  PVector getStart() {
    return start.pos;
  }

  PVector getEnd() {
    return end.pos;
  }

  int getClosest(PVector pos) {
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
  PVector get(int i) {
    return data.get(i).pos;
  }

  int size() {
    return data.size();
  }
  
  float getDistance(int i) {
    return data.get(i).dst;
  }
  
  float getDistanceFromStart(int i) {
    return data.get(i).dst - start.dst;
  }
  float getTotalLength() {
    return end.dst - start.dst;
  }
}

class Tramo {
  Track utm, real;
  boolean bFocus = false;
  int id = -1;
  String name = "";
  int start, end;

  Tramo(String name, String utmFile, String realFile, int start, int end) {
    
    logFile.println("Loading tramo: " +  name);
    utm = new Track();
    utm.loadData(utmFile);
    
    if (start < 1) start = 1;
    if (end > -1) end = -1;
    
    this.start = start;
    this.end = end;
    
    
    real = new Track();
    real.loadData(realFile, utm.get(0));
    
    setStartEnd();
    this.name = name;
  }
  
  void setStartEnd(){
    utm.setStart(start);
    utm.setEnd(end);
    real.setStart(real.getClosest(utm.getStart()));
    real.setEnd(real.getClosest(utm.getEnd()) - real.size());
    

  }

  boolean inFocus() {
    return bFocus;
  }
  void setFocus(boolean b) {
    bFocus = b;
  }

  void setId(int id) {
    this.id = id;
  }

  PVector getStart() {
    return utm.getStart();
  }
  PVector getEnd() {
    return utm.getEnd();
  }

  void draw(int opacity) {
    stroke(255, opacity);
    utm.draw();
    //stroke(255, 255, 0, opacity / 2);
    //real.draw();
  }


  int getClosest(PVector pos) {
    return utm.getClosest(pos);
  }

  PVector getUtmPoint(int i) {
    return utm.get(i);
  }
  int getRealIndex(int idx){
    return real.getClosest(utm.get(idx));
  }
  
  float getRealDistanceFromStart(int i) {
    return real.getDistanceFromStart(i);
  }
  float getRealTotalLength() {
    return real.getTotalLength();
  }
  
  void addStart() {
    start += 1;
    setStartEnd();
        mySql.updateTramoStartEnd(name, start, end);
  }

  void addEnd() {
    end -= 1;
    setStartEnd();
    mySql.updateTramoStartEnd(name, start, end);
  }

  void subStart() {
    start -= 1;
    if (start < 1) start = 1;
    setStartEnd();
        mySql.updateTramoStartEnd(name, start, end);
  }

  void subEnd() {
    end += 1;
    if (end > -1) end = -1;
    setStartEnd();
        mySql.updateTramoStartEnd(name, start, end);
  }
  String toString() {
    return name + "," + utm.fileName + "," + real.fileName + "," + start + "," + end;
  }
  
  int getEndIndex(){
    return utm.getEndIndex();
  }
  
  int getStartIndex(){
    return utm.getStartIndex();
  }
  
   int getRealEndIndex(){
    return real.getEndIndex();
  }
  
  int getRealStartIndex(){
    return utm.getStartIndex();
  }

}

