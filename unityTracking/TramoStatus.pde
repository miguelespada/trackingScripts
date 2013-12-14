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
  PVector proyection, pProyection;
  
  LoopTrack loopTrack;
  boolean fresh = false;
  

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
    pProyection = new PVector();
    pdStart = 1000000;
    dStart = 1000000;
    pdEnd = 1000000;
    dEnd = 1000000;
  }
  
  void updateClosest(PVector pos) {
    proyection = t.getClosest(pos);
   
  }

  void updateInTrack(PVector pos) {
    updateClosest(pos);
    inTrack = (pos.dist(proyection) < trackThreshold);
  }
  
  void updateStart(Car car) {  
    dStart = t.distToStart(car.pos);
    if (inTrack && 
      !running && 
      dStart + trackThreshold > pdStart && 
      car.speed > 30) {
        
      running = true;
      loopTrack.reset();
      loopTrack.add(t.getStart(), car.pTime, car.speed, getAvgSpeedOfLastPeriod(car.speed));
      startTime = car.pTime;
    }
    pdStart = dStart;
  }
  void updateEnd(Car car) {
    dEnd = t.distToEnd(car.pos);

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
    pProyection.x =  proyection.x;
    pProyection.y =  proyection.y;
    updateInTrack(car.pos);
    if(pProyection.equals(proyection)){
      fresh = false;
    }
    else{
      fresh = true;
      updateStart(car); 
      carTime = car.time;
      if(running){
        loopTrack.add(proyection, carTime, car.speed, getAvgSpeedOfLastPeriod(car.speed));
      }
      updateEnd(car); 
    }
      
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
  float getAvgSpeedOfLastPeriod(float speed){
      float avgSpeed = loopTrack.calculateAvgSpeedOfLastPeriod();
      if (avgSpeed == -1) avgSpeed = speed;
      return avgSpeed;
  }
  void sendCar(int id, float speed){
    if(t.inFocus() && inTrack && fresh){
      oscSendCar(id, int(proyection.x - t.getStart().x), 
                     int(proyection.y - t.getStart().y), 
                     getAvgSpeedOfLastPeriod(speed), 
                     speed);
    }
  }
}

