int trackThreshold = 30;
int endThreshold = 100;

class TramoStatus {
  Tramo t;
  Car car;

  boolean inTrack = false;
  boolean running = false;
  boolean finish = false;

  float pdStart, dStart, pdEnd, dEnd;
  PVector proyection, pProyection;
  int proyectionIdx, pProyectionIdx;
  LoopTrack loopTrack;
  float error;
  int nE;

  TramoStatus(Car c, Tramo t) {
    this.t = t;
    this.car = c;
    loopTrack = new LoopTrack(this.t, this.car);
    reset();
  }

  void reset() {
    inTrack = false;
    running = false;
    finish = false;
    loopTrack.reset();
    proyection = new PVector();
    pProyection = new PVector();
    pdStart = 1000000;
    dStart = 1000000;
    pdEnd = 1000000;
    dEnd = 1000000;
     error = 0;
     nE = 0;
  }

  int updateProyection(PVector pos) {
    return t.getClosest(pos);
  }

  boolean updateInTrack() {
    return car.pos.dist(proyection) < trackThreshold;
  }

  boolean updateStart() {  
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
  boolean updateEnd() {
    dEnd = t.distToEnd(car.pos);

    if (!inTrack 
        && running 
        && proyectionIdx > t.length() * 0.9) 
      return true;
    
    pdEnd = dEnd;
    return false;
  }

  void update() {
    if(finish) 
      return;
      
    pProyection.x =  proyection.x;
    pProyection.y =  proyection.y;
    pProyectionIdx = proyectionIdx;

    proyectionIdx = updateProyection(car.pos);
    proyection = t.get(proyectionIdx);
    
    inTrack = updateInTrack();
     if (!running) {
        running = updateStart(); 
        if (running) {
          oscSendReset(car.id);
          loopTrack.reset();
          loopTrack.add(pProyection, pProyectionIdx, car.pTime, 0, "start", car.pos.dist(proyection) );
         
        }
      }
      
      if(running ){ 
         if(car.fresh){
           car.fresh = false;
           loopTrack.add(proyection, proyectionIdx, car.time, car.speed, "running", car.pos.dist(proyection) );
           error += car.pos.dist(proyection);
           nE += 1;
         }
      }
      finish = updateEnd(); 
      if (finish) {             
        loopTrack.add("end");    
        error -= car.pos.dist(proyection);
        nE -= 1;
        println("END " + car.id + " Error: " + error/nE);

        inTrack = false;
        running = false;
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
  float getDistanceFromStart() {
    if (inTrack && !running) return 0;
    return loopTrack.getDistanceFromStart();
  }

  float getTotalTime() {
    return loopTrack.getTotalTime();
  }

  float getCurrentTime() {
    return loopTrack.getCurrentTime();
  }
  
  float getEndTime() {
    return loopTrack.getEndTime();
  }
  
  float getAvgSpeedOfLastPeriod(float speed) {
    float avgSpeed = loopTrack.calculateAvgSpeedOfLastPeriod();
    if (avgSpeed == -1) avgSpeed = speed;
    return avgSpeed;
  }
  
  void sendCar(int id, float speed) {
    if (t.inFocus() && inTrack) {
//      oscSendCar(id, 
//      int(proyection.x - t.getStart().x), 
//      int(proyection.y - t.getStart().y), 
//      getAvgSpeedOfLastPeriod(speed), 
//      speed, "current");
//         println("Drawing normal " + getAvgSpeedOfLastPeriod(speed) + " " +
//         int(proyection.x - t.getStart().x) + " " + 
//          int(proyection.y - t.getStart().y));

    }
  }
  void drawLoop(){
    loopTrack.drawLoop(car.id);
  }
  void sendLoop(){
    loopTrack.sendLoop(car.id);
  }
   void resetLoop(){
    loopTrack.resetLoop();
  }
}

