int trackThreshold = 30;
class TramoStatus {
  Tramo t;
  boolean inTrack = false;
  boolean running = false;
  boolean finish = false;

  float pdStart = 1000000;
  float dStart = 1000000;
  float pdEnd = 1000000;
  float dEnd = 1000000;
  int startTime = 0;
  int endTime = 0;
  int carTime = 0;
  PVector proyection;
  
  LoopTrack loopTrack;
  

  TramoStatus(Tramo t) {
    this.t = t;
    loopTrack = new LoopTrack(this.t);
    reset();
  }
  
  void reset() {
    inTrack = false;
    running = false;
    finish = false;
    loopTrack.reset();
    startTime = 0;
    endTime = 0;
    proyection = new PVector();
    pdStart = 1000000;
    dStart = 1000000;
    pdEnd = 1000000;
    dEnd = 1000000;
  }
  
  void updateClosest(PVector pos) {
    float minDist = 10000000;
    for (int i = 0; i < t.n; i ++) {
      float d = pos.dist(t.data[i]);
      if (d < minDist) {
        proyection = t.data[i];
        minDist = d;
      }
    }
  }

  void updateInTrack(PVector pos) {
    updateClosest(pos);
    inTrack = (pos.dist(proyection) < trackThreshold);
  }
  
  void updateStart(Car car) {  
    dStart = car.pos.dist(t.start);   
    if (inTrack && 
      !running && 
      dStart + trackThreshold > pdStart && 
      car.speed > 30) {
        
      running = true;
      loopTrack.reset();
      loopTrack.add(t.start, car.pTime);
      startTime = car.pTime;
    }
    pdStart = dStart;
  }
  void updateEnd(Car car) {
    dEnd = car.pos.dist(t.end);
    if (!inTrack && running && dEnd < 500) 
     { 
      inTrack = false;
      running = false;
      finish = true;
      endTime = car.time;
    }
    pdEnd = dEnd;
  }

  void update(Car car) {
    updateInTrack(car.pos);
    updateStart(car);
    updateEnd(car); 
    //if (!inTrack) running = false;
    carTime = car.time;
    if(running)
      loopTrack.add(proyection, carTime);
    
  }

  String printStatus() {
    if (t.inFocus())
      return "(" + t.id + " " + int(inTrack) + ")"; 
    else
      return "";
  }
  
  void drawProyection(color c) {
    if (inTrack) {
      pushStyle();
      rectMode(CENTER);
      noStroke();
      fill(0);
      rect(proyection.x, proyection.y, 2/dZ, 2/dZ);
      popStyle();
    }
  }
  float calculateDistanceFromStart(){
    if(inTrack && !running)
      return 0;
    return loopTrack.calculateDistanceFromStart();
  }
  
  float getEndTime(){
    return endTime - startTime;
  }
  
  float getCurrentTime(){
    return carTime - startTime;
  }
  
  void sendCar(int id, float speed){
    if(t.inFocus() && inTrack){
      oscSendCar(id, int(proyection.x - t.start.x), int(proyection.y - t.start.y), speed);
    }
  }
}

