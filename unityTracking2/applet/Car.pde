int M = 20;
int ANCHO = 200;


class Car {
  color theColor;
  PVector pos;
  int id; 
  float speed;
  
  PVector tracks[];
  int idx;
  float time, pTime;
  int lastActiveFrame;
  boolean fresh;
  String name;
  
  ArrayList<TramoStatus> tramos;


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
    tramos = new ArrayList<TramoStatus>();
    
  }
  
  
  void addPoint(float x, float y, float s, int t){
    if(time == t) return;
    fresh = true; 
    lastActiveFrame = frameCount;
    addPos(x, y);
    speed = s;
    pTime = time;
    time = t;
  }

  void addPos(float x, float y) {
    pos = new PVector(x, y);
    tracks[idx] = pos;
    idx = (idx + 1) % M;
  }

  void setColor(color c) {
    theColor = c;
  }
  
  void update(){
    for (TramoStatus t: tramos) {
      t.update();
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
   
    fill(theColor);
    if (inTrack()) stroke(255);
    else noStroke();

    ellipseMode(CENTER);
    ellipse(pos.x, pos.y, 18/dZ, 18/dZ);
    fill(0);
    textSize(12/dZ);
    textAlign(CENTER);
    noStroke();
    float ascent = textAscent();
    text(id, pos.x, pos.y + 5/dZ);

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
  
  boolean inTrack() {
    for (TramoStatus t: tramos)
      if (t.inTrack) return true;
    return false;
  }
  void registerTramo(Tramo t) {
    TramoStatus tramo = new TramoStatus(this, t);
    tramos.add(tramo);
  }
  
  TramoStatus getTramoStatus(int id){
    for (TramoStatus tt: tramos)  
       if(tt.getId() == id)
         return tt;
       
    return null;
  }
  
  
  void drawLoop(){
    for(TramoStatus t: tramos){
       if(t.finish)
        t.drawLoop();
    } 
  }
  void loadLoops(){
    for(TramoStatus t: tramos){
      t.loadLoop();
    }
  }
  void removeLoops(){
    for(TramoStatus t: tramos){
      t.removeLoop();
    }
  }
  
  int drawInfo(int tramoId, int x, int y, int opacity) {
    TramoStatus t = getTramoStatus(tramoId);
    
    
    if(t == null)
      return -1;
    int s = 11;
    pushStyle();
    fill(255, 200);
    stroke(255);
    strokeWeight(1);
    rect(x - 5, y, ANCHO, s * 5);
    fill(0, opacity);
    textSize(s * 0.8);
    textAlign(LEFT);
    text("CAR: " + name + " ID: " + id + " SPEED: " + int(speed) + " km/h" 
        + " IDLE: " 
        +  int((frameCount - lastActiveFrame)/frameRate) 
        + " s", x, y + s);
     
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
    text("TRAMO: " + t.getId()  + " STATUS: " + status, x, y + 2*s);
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
    
    return s*5;
   
  }
        


}  
