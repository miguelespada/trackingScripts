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
  Track() {
  }

  void loadData(String fileName, PVector ref) {
    this.fileName = fileName;
    String lines[] = loadStrings(fileName);
    float dst = 0;
    data = new ArrayList<TramoPoint>();
    for (int i = 0 ; i < lines.length; i++) {
      String[] tokens = splitTokens(lines[i]);
      PVector pos = new PVector(float(tokens[0]) + ref.x, float(tokens[1]) + ref.y);
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
    start = data.get(s);
  }

  void setEnd(int e) {
    end = data.get(data.size() - 1 + e);
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
    ellipse(start.pos.x, start.pos.y, 20, 20);
    fill(0, 255, 255);
    noStroke();
    ellipse(end.pos.x, end.pos.y, 20, 20); 
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
  float getDistance(int i) {
    return data.get(i).dst;
  }

  int size() {
    return data.size();
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
    utm = new Track();
    utm.loadData(utmFile);
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
    stroke(255, 0, 255, opacity / 4);
    real.draw();
  }


  int getClosest(PVector pos) {
    return utm.getClosest(pos);
  }

  PVector getUtmPoint(int i) {
    return utm.get(i);
  }
  float getDistanceFromStart(int i) {
    return utm.getDistance(i);
  }
  float getTotalLength() {
    return utm.getTotalLength();
  }
  
  void addStart() {
    start += 1;
    setStartEnd();
  }

  void addEnd() {
    end -= 1;
    setStartEnd();
  }

  void subStart() {
    start -= 1;
    if (start < 0) start = 0;
    setStartEnd();
  }

  void subEnd() {
    end += 1;
    if (end > 0) end = 0;
    setStartEnd();
  }
  String toString() {
    return name + "," + utm.fileName + "," + real.fileName + "," + start + "," + end;
  }
}

