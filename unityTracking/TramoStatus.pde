int trackThreshold = 30;
int endThreshold = 500;

class TramoStatus {
  Tramo t;
  Car car;

  boolean inTrack = false;
  boolean running = false;
  boolean finish = false;

  float pdStart, dStart, pdEnd, dEnd;
  PVector proyection, pProyection;
  LoopTrack loopTrack;

  TramoStatus(Car c, Tramo t) {
    this.t = t;
    this.car = c;
    loopTrack = new LoopTrack(this.t);
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
  }

  PVector updateProyection(PVector pos) {
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

    if (!inTrack && running && dEnd < endThreshold) 
      return true;
    
    pdEnd = dEnd;
    return false;
  }

  void update() {
    if(finish) 
      return;
      
    pProyection.x =  proyection.x;
    pProyection.y =  proyection.y;

    proyection = updateProyection(car.pos);
    if (car.fresh = true) {
      inTrack = updateInTrack();
      if (!running) {
        running = updateStart(); 
        if (running) {
          oscSendReset(car.id);
          loopTrack.reset();
          println((pProyection.x - t.getStart().x) + " " +  (pProyection.y - t.getStart().y));
          loopTrack.add(pProyection, car.pTime, 0);
        }
        
        car.fresh = false;
      }
      
      if(running) {
        loopTrack.add(proyection, car.time, car.speed);
      }

      finish = updateEnd(); 
      if (finish) {
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
         println("Drawing normal " + getAvgSpeedOfLastPeriod(speed) + " " +
         int(proyection.x - t.getStart().x) + " " + 
          int(proyection.y - t.getStart().y));

    }
  }
  void drawLoop(){
    loopTrack.drawLoop(car.id);
  }
   void resetLoop(){
    loopTrack.resetLoop();
  }
}

