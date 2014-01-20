class TramoPoint {
  PVector pos;
  float dst;
  TramoPoint(PVector pos, float dst) {
    this.dst = dst;
    this.pos = pos;
  }
}

class Tramo {
  int id = -1;
  String prueba;
  ArrayList<TramoPoint> data;
  int start, end;
  java.util.Date initTime, endTime;

  Tramo(String prueba, int id, String fileName, int start, int end, String initTime, String endTime) {
    loadData(fileName);
    this.id = id;
    this.prueba = prueba;
    this.start = start;
    this.end = end;
    updateStartEnd();
    if(initTime == null) 
      setInitTime();
    else
      this.initTime = new Date(Timestamp.valueOf(initTime).getTime());
    
    if(endTime == null)
      setEndTime();
    else
      this.endTime = new Date(Timestamp.valueOf(endTime).getTime());
  }

  void loadData(String fileName) {
    String lines[] = loadStrings(host + "Tramos/"+ fileName);
    float dst = 0;
    data = new ArrayList<TramoPoint>();
    PVector pos, pPos = null;
    for (int i = 0 ; i < lines.length; i++) {
      String[] tokens = splitTokens(lines[i]);
      pos = new PVector(float(tokens[1]), float(tokens[0]));
      if (pPos != null) dst += pos.dist(pPos);
      else dst = 0;
      pPos = pos;
      data.add(new TramoPoint(pos, dst));
    }
    println(fileName + " loaded");
  }
  void drawInfo(int x, int y){
    pushStyle();
    fill(255);
    textSize(12);
    pushMatrix();
    translate(x, y);
    fill(120, 155, 249);
    text(prueba + " " + id, 0, 0);
    fill(255);
    text("Longitud: " +  int(getRealLength()) + " / " + int(getTotalLength()), 0, 20);
    text("UTM coords: (" + getX() + " / " + getY() + ")", 0, 40);
    text("Init time: " + initTime, 0,  60);
    text("End time: " + endTime, 0,  80);
    popMatrix();
    popStyle();
  }
  
  void draw() {
    stroke(255);
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
    ellipse(getStart().pos.x,getStart().pos.y, 5/dZ, 5/dZ);
    fill(0, 255, 255);
    noStroke();
    ellipse(getEnd().pos.x ,getEnd().pos.y, 5/dZ, 5/dZ); 
    popStyle();

  }
  
  float getTotalLength(){
     return data.get(data.size() - 1).dst;
  }
  
  float getRealLength(){
    return getEnd().dst - getStart().dst;
  }
  
  float getX(){
    return data.get(0).pos.x;
  }
  
  float getY(){
    return data.get(0).pos.y;
  }
   void addStart(int i) {
    start += i;
    updateStartEnd();
  }

  void addEnd(int i) {
    end -= i;
    updateStartEnd();
  }
  
  TramoPoint getStart() {
    return data.get(start);
  }

  TramoPoint getEnd() {
    return data.get(data.size() -1 + end);
  }
  
   void updateStartEnd(){
      if (start < 1) start = 1;
      if (end > -1) end = -1;
      
      mysql.updateTramoStartEnd(id, start, end);
  }
  
  void setInitTime(){	 
      java.util.Date date= new java.util.Date();  
      initTime = new Timestamp(date.getTime());
      mysql.setInit(id, initTime.toString());
  }
  
  void setEndTime(){
      java.util.Date date= new java.util.Date();  
      endTime = new Timestamp(date.getTime());
      mysql.setEnd(id, endTime.toString());
  }
   java.util.Date getInitTime(){
    return initTime;
  }
  
   java.util.Date getEndTime(){
    return endTime;
  }
  
  int getClosest(PVector pos) {
    float minDist = 10000000;
    int idx = -1;
    int i = 0;
    for (TramoPoint p: data) {
      float d = pos.dist(p.pos);
      if (d < minDist) {
        idx = i;
        minDist = d;
      }
      i ++;
    }
    return idx;
  }
  
  int getStartIndex(){
    return start;
  }
   int getEndIndex(){
    return data.size() - 1 + end;
  }
   PVector get(int i) {
    return data.get(i).pos;
  }
  float getDistanceFromStart(int i) {
    return data.get(i).dst - getStart().dst;
  }
}

