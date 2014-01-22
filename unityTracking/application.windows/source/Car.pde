int ANCHO = 220;
int ALTO = 50;

class Car {
  color theColor;
  PVector pos;
  int id; 
  float speed;
  String status = "NO DATA";
  TramoStatus ts;
  
  PVector tracks[];
  int idx;
  int time, pTime;
  int lastActiveFrame;
  boolean fresh;
  String name;
  int x, y;
  
  Car(int id, String name) {
    this.name = name;
    this.id = id;
    reset();
  }
  
  void reset(){
    this.pos = new PVector(0, 0);
    tracks = new PVector[M];
    idx = 0;
    time = 0;
    pTime = 0;
    lastActiveFrame = -1;
    fresh = false;
    if(ts != null)
      ts.reset();
  }
  
  void addPoint(float x, float y, float s, int t, String status){
    if(time == t) return;
    fresh = true; 
    lastActiveFrame = frameCount;
    addPos(x, y);
    speed = s;
    pTime = time;
    time = t;
    this.status = status;
    update();
  }

  void addPos(float x, float y) {
    pos = new PVector(x, y);
    tracks[idx] = pos;
    idx = (idx + 1) % M;
  }

  void setColor(String c) {
    theColor = unhex("FF" + c);
  }
  
  void update(){
      ts.update();
  }
  
  void draw() {
    pushStyle();
     for (int i = 0; i < M - 1; i ++) {
      int p0 = (idx + i) % M;
      int p1 = (idx + i + 1) % M;
      PVector pos0 = tracks[p0];
      PVector pos1 = tracks[p1];
      stroke(setAlpha(i));
      if (pos0 != null && pos1 != null)
        line(pos0.x, pos0.y, pos1.x, pos1.y);
    }
   
    
    fill(theColor);
    if (ts.inTrack) stroke(255);
    else noStroke();

    ellipseMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    scale(1, -1);
    ellipse(0, 0, 18/dZ, 18/dZ);
    fill(0);
    textSize(12/dZ);
    textAlign(CENTER);
    noStroke();
    float ascent = textAscent();
    text(id, 0, 5/dZ);
    popMatrix();

    popStyle();
  }
  
   color setAlpha(int i) {
    return color(red(theColor), 
    green(theColor), 
    blue(theColor), 
    map(i, 0, M - 1, 50, 255) );
  }
  
  void registerTramo(Tramo t) {
    ts = new TramoStatus(this, t);
  }
  
  int drawInfo(int x, int y, int opacity) {
    this.x = x;
    this.y = y;
    int s = ALTO/5;
    
    int idle = int((frameCount - lastActiveFrame)/frameRate);
    
    if(ts == null) return -1;
    pushStyle();
    
    fill(255 - constrain((idle * 3), 0, 100), 200);
      
    stroke(theColor);
    strokeWeight(2);
    rect(x - 5, y, ANCHO, ALTO-4);
    fill(0, opacity);
  
    textSize(s * 0.9);
    textAlign(LEFT);
    if(!status.equals("WRC")) fill(150, 0, 0);
    text( id + " - " + name  + " tramo: " + ts.t.id +  " " + status, x, y + s);
     
    pushStyle();
   
    String status = "";
    if (ts.finish){
      status = "DONE";    
      fill(0, 255, 0, opacity);
    }
    else if(ts.running){
      status = "RUNNING";
      fill(255, 255, 0, opacity);
    }
    else if(ts.inTrack){
      status = "WAITING";
      fill(0, 255, 255, opacity);
    }
    else{
      status = "OUT";
      fill(0, opacity);
    }
    text("SPEED: " + int(speed) + "km/h " + "STATUS: " + status, x, y + 2*s);
    
    popStyle(); 
    float dst =  ts.getDistanceFromStart(); 
    
    if(status != "OUT"){
      text("DIST: " + int(dst), x, y + s * 3);
    }
    if(status == "RUNNING" || status == "DONE"){
      float cTime = ts.getTotalTime();
      text("TIME: " + int(cTime)/60 + ":" + int(cTime)%60  + " AVG: " + int(dst/cTime) + " m/s", x, y + s * 4);
    }
    
    popStyle();
    
    return ALTO;
  }
}  

