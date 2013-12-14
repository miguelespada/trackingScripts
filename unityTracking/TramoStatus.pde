int trackThreshold = 30;
int endThreshold = 500;


class TramoStatus {
  Tramo t;
  
  boolean fresh = false;
  boolean inTrack = false;
  boolean running = false;
  boolean finish = false;

  float pdStart, dStart, pdEnd, dEnd;
  int startTime = 0;
  int endTime = 0;
  int carTime = 0;
  PVector proyection, pProyection;
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
    fresh = false;
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
  
  PVector updateProyection(PVector pos) {
    return t.getClosest(pos);
  }

  boolean updateInTrack(Car car) {
    return car.pos.dist(proyection) < trackThreshold;
  }
  
  boolean updateStart(Car car) {  
    dStart = t.distToStart(car.pos);
    if (inTrack && 
      !running && 
      dStart + trackThreshold > pdStart && 
      car.speed > 30) {
      return true;
    }
    pdStart = dStart;
    return false;
  }
  boolean updateEnd(Car car) {
    dEnd = t.distToEnd(car.pos);

    if (!inTrack && running && dEnd < endThreshold) 
     { 
      endTime = car.time;
      return true;
    }
    pdEnd = dEnd;
    return false;
  }

  void update(Car car) {
    pProyection.x =  proyection.x;
    pProyection.y =  proyection.y;
    
    proyection = updateProyection(car.pos);
    if(pProyection.equals(proyection)){
      fresh = false;
    }
    else{
      
      fresh = true;
      inTrack = updateInTrack(car);
      if(!running){
        running = updateStart(car); 
        if(running){  
          loopTrack.reset();
          startTime = car.pTime;
        } 
      }
      carTime = car.time;
      if(running){
        loopTrack.add(proyection, car.time, car.speed, 
                      getAvgSpeedOfLastPeriod(car.speed));
      }
      
      finish = updateEnd(car); 
      if(finish){
        inTrack = false;
        running = false;
      }
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
    if(inTrack && !running) return 0;
    return loopTrack.getDistanceFromStart();
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

