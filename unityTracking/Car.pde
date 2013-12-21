int M = 20;
int ANCHO = 200;

class Car {
  color theColor;
  PVector pos;
  int id; 
  PVector tracks[];
  int idx = 0;
  
  float speed = 0;
  int active = -1;
  ArrayList<TramoStatus> tramos;
  int time = -1;
  int pTime = -1;
  Button enabledButton;
  Button soloButton;
  boolean fresh = false;

  Car(int id) {
    this.pos = new PVector(0, 0);
    this.id = id;
    tracks = new PVector[M];
    tramos = new ArrayList<TramoStatus>();
    enabledButton = new Button("enable", id);
    soloButton = new Button("solo", id);
  }
  
  void reset() {
    for (TramoStatus t: tramos)
      t.reset();
    
    tracks = new PVector[M];
    fresh = false;
  }
  boolean isActive() {
    return active > 0 && int((frameCount - active)/frameRate) < 11;
  }
  
  
  void update() {  
    for (TramoStatus t: tramos) {
      t.update();
      if (enabledButton.getValue()){
        t.sendCar(id, speed *1000/3600);
      }
    }
  }

  void addPos(float x, float y) {
    pos = new PVector(x, y);
    tracks[idx] = pos;
    idx = (idx + 1) % M;
    active = frameCount;
  }

  void draw() {
    pushStyle();
    if (enabledButton.getValue()) {
      for (int i = 0; i < M - 1; i ++) {
        int p0 = (idx + i) % M;
        int p1 = (idx + i + 1) % M;
        PVector pos0 = tracks[p0];
        PVector pos1 = tracks[p1];
        stroke(setAlpha(i));
        if (pos0 != null && pos1 != null)
          line(pos0.x, pos0.y, pos1.x, pos1.y);
      }
    }
    if (enabledButton.getValue()) {
      fill(theColor);
      if (inTrack()) stroke(255);
      else noStroke();
    }
    else {
      fill(setAlpha(1));
      noStroke();
    }

    ellipseMode(CENTER);
    ellipse(pos.x, pos.y, 18/dZ, 18/dZ);
    fill(0);
    textSize(12/dZ);
    textAlign(CENTER);
    noStroke();
    float ascent = textAscent();
    text(id, pos.x, pos.y + 5/dZ);

    for (TramoStatus t: tramos)
      t.drawProyection(theColor);
    popStyle();
  }


  void setColor(color c) {
    theColor = c;
  }

  float dist(PVector p) {
    return pos.dist(p);
  }

  color setAlpha(int i) {
    return color(red(theColor), 
    green(theColor), 
    blue(theColor), 
    map(i, 0, M - 1, 50, 255) );
  }

  void drawControls(int x, int y) {
    int a = 10;
    int xx = ANCHO + x - 2 * a;
    
    enabledButton.setPosition(xx, y, a);
    enabledButton.draw();
    soloButton.setPosition(xx, y + 2 * a, a);
    soloButton.draw();
  }

  void mouseClicked() {
    enabledButton.mouseClicked();
    soloButton.mouseClicked();
  }

  int drawInfo(int x, int y) {
    int s = 12;
    pushStyle();
    fill(255, 200);
    stroke(255);
    strokeWeight(1);
    rect(x - 5, y, ANCHO, s * 5);
    fill(0);
    textSize(s * 0.8);
    textAlign(LEFT);
    text("Id: " + id + " idle time: " +  int((frameCount - active)/frameRate) + " s", x, y + s);
    text("Speed: " + int(speed) + " km/h", x, y + s * 2);

    String status = "";

    TramoStatus t = getActiveTramo();

    pushStyle();

    float dst =  t.getDistanceFromStart();   
    if (t.finish) {
      fill(0, 123, 0);
      text("Status: DONE", x, y + s * 3);
      float cTime = t.getTotalTime();
      float kmh = (dst / cTime) * 3.600;
      text("Time: " + int(cTime) + " Dist: " + int(dst) + " Avg " + int(kmh) + " km/h", x, y + s * 5);
    }
    else if (t.running) {
      fill(0, 0, 255);
      text("Status: RUNNING", x, y + s * 3);
      float cTime =  t.getCurrentTime(); 
      float avgSpeedLastPeriod = t.getAvgSpeedOfLastPeriod(speed);
      text( "Delta speed: " + int(avgSpeedLastPeriod * 3.6) + " km/h", x, y + s * 4);  
      float kmh = (dst / cTime) * 3.6;
      text("Time: " + int(cTime) + " Dist: " + int(dst) + " Avg " + int(kmh) + " km/h", x, y + s * 5);
    }
    else if (t.inTrack) {
      fill(0, 255, 0);
      text("Status: WAITING", x, y + s * 3);
      text("time: " + 0, x, y + s * 4);
    }
    else {
      fill(0);
      text("Status: OUT", x, y + s * 3);
    }

    popStyle();

    popStyle();
    return s*5;
  }
  void registerTramo(Tramo t) {
    TramoStatus tramo = new TramoStatus(this, t);
    tramos.add(tramo);
  }
  boolean inTrack() {
    for (TramoStatus t: tramos)
      if (t.inTrack) return true;
    return false;
  }

  TramoStatus getActiveTramo() {
    for (TramoStatus t: tramos)
      if (t.t.inFocus()) return t;
    return null;
  }
  boolean isInTramo(int id) {
      Tramo activeTramo = getActiveTramo().t;
      return activeTramo.id == id && getActiveTramo().inTrack;
  }
  
  float getActiveDistance(){
     TramoStatus t = getActiveTramo();
     return int(t.getDistanceFromStart());
  }
  
  boolean enabled(){
    return enabledButton.getValue();
  }
  
  boolean solo(){
    return soloButton.getValue();
  }
  void unSolo(){
    soloButton.setValue(false);
  }
  
  boolean finished(int tramoId){
    TramoStatus t = getActiveTramo();
    return t.finish && t.t.id == tramoId;
  }
  boolean running(int tramoId){
    TramoStatus t = getActiveTramo();
    return t.running && t.t.id == tramoId;
  }
  float getEndTime(){
    TramoStatus t = getActiveTramo();
    return t.getEndTime();
  }
  void drawLoop(int tId){
     for (TramoStatus t: tramos)
      if (t.t.id == tId) {
        t.drawLoop();
      }
  }
  void sendLoop(int tId){
     for (TramoStatus t: tramos)
      if (t.t.id == tId) {
        t.sendLoop();
      }
  }
  void resetLoop(int tId){
     for (TramoStatus t: tramos)
      if (t.t.id == tId) t.resetLoop();
  }
}  

