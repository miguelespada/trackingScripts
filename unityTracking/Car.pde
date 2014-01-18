int ANCHO = 220;
int ALTO = 50;

class Car {
  color theColor;
  PVector pos;
  int id; 
  float speed;
  String status = "NO DATA";
  
  PVector tracks[];
  int idx;
  int time, pTime;
  int lastActiveFrame;
  boolean fresh;
  String name;
  int x, y;
  boolean enabled = true;
  
  ArrayList<TramoStatus> statuses;


  Car(int id, String name) {
    this.name = name;
    this.id = id;
    this.pos = new PVector(0, 0);
    tracks = new PVector[M];
    idx = 0;
    time = 0;
    pTime = 0;
    lastActiveFrame = -1;
    fresh = false;
    statuses = new ArrayList<TramoStatus>();
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
    
    for (TramoStatus t: statuses) {
      t.update();
      if(t.t.id == tramos.getFocusId() ) {
        enabled = t.running;
      }
    }
   
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
   
   //z line(ref.x, ref.y, pos.x, pos.y);
    
    fill(theColor);
    if(!enabled) fill(theColor, 100);
    if (inTrack()) stroke(255);
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
  
  float dist(PVector p){
    return this.pos.dist(p);
  }
  
  boolean isInTramo(int tramoId){
    for (TramoStatus t: statuses){
      if (t.inTrack && t.t.id == tramoId) return true;
    }
    return false;
  }
  boolean finished(int tramoId){
    for (TramoStatus t: statuses){
      if (t.finish && t.t.id == tramoId) return true;
    }
    return false;
  }
  
  boolean inTrack() {
    for (TramoStatus t: statuses)
      if (t.inTrack) return true;
    return false;
  }
  void registerTramo(Tramo t) {
    TramoStatus tramo = new TramoStatus(this, t);
    statuses.add(tramo);
  }
  
  TramoStatus getTramoStatus(int id){
    for (TramoStatus tt: statuses)  
       if(tt.getId() == id)
         return tt;
    return null;
  }
  
  
  void drawLoop(){
    for(TramoStatus t: statuses){
       if(t.finish)
        t.drawLoop();
    } 
  }
 
  
  int drawInfo(int tramoId, int x, int y, int opacity) {
    this.x = x;
    this.y = y;
    int s = ALTO/5;
    
    TramoStatus t = getTramoStatus(tramoId);
    int idle = int((frameCount - lastActiveFrame)/frameRate);
    
    if(t == null)
      return -1;
    pushStyle();
    
    
    fill(255 - constrain((idle * 3), 0, 100), 200);
      
    stroke(theColor);
    strokeWeight(2);
    rect(x - 5, y, ANCHO, ALTO-4);
    fill(0, opacity);
  
    textSize(s * 0.9);
    textAlign(LEFT);
    if(!status.equals("WRC")) fill(150, 0, 0);
    text( id + " - " + name +  " " + status, x, y + s);
     
    pushStyle();
   
    String status = "";
    if (t.finish){
      status = "DONE";    
      fill(0, 255, 0, opacity);
    }
    else if(t.running){
      status = "RUNNING";
      fill(255, 255, 0, opacity);
    }
    else if(t.inTrack){
      status = "WAITING";
      fill(0, 255, 255, opacity);
    }
    else{
      status = "OUT";
      fill(0, opacity);
    }
    text("SPEED: " + int(speed) + "km/h " + "STATUS: " + status, x, y + 2*s);
    popStyle(); 
  
    float dst =  t.getDistanceFromStart();   
    if(status != "OUT"){
      text("DIST: " + int(dst), x, y + s * 3);
    }
    if(status == "RUNNING" || status == "DONE"){
      float cTime = t.getTotalTime();
      text("TIME: " + int(cTime) + " AVG: " + int(dst/cTime) + " m/s", x, y + s * 4);
      
    }
  
    popStyle();
    
    return ALTO;
  }
  
   void mouseClicked() {
     if(mouseX > x && mouseX < x + ANCHO && 
       mouseY > y && mouseY < y + ALTO){
          if(keyCodes[SHIFT])
            enabled = !enabled; 
     }
   }
   String toString(){
     String s = "";
     s += str(id) + ",";
     s += name + ",";
     s += hex(theColor).substring(2,8);
     return s;
   }
   float getDistanceFromStart(int tramoId){
      for (TramoStatus t: statuses){
        if(t.t.id == tramoId)
          return t.getDistanceFromStart();
      }
      return -1;
   }
    float getTotalTime(int tramoId){
      for (TramoStatus t: statuses){
        if(t.t.id == tramoId)
          return t.getTotalTime();
      }
      return -1;
   }
}  

