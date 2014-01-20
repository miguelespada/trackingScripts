class TramoStatus {
  Tramo t;
  Car car;
  boolean inTrack = false;
  boolean running = false;
  boolean finish = false;
  int proyection, pProyection;
  float startTime = 0;
  float endTime = 0;
  LoopTrack loopTrack;
  
  
  TramoStatus(Car c, Tramo t) {
    this.t = t;
    this.car = c;
    reset();
  }

  void reset() {
    inTrack = false;
    running = false;
    finish = false;
  }


  int updateProyection(PVector pos) {
    return t.getClosest(pos);
  }

  boolean updateInTrack() {
    return car.pos.dist(t.get(proyection)) < trackThreshold;
  }

  boolean updateStart() {  
    if (inTrack && 
      !running && 
      proyection > t.getStartIndex()
      ) {
      startTime = car.time;
      return true;
    }
    return false;
  }
  
  boolean updateEnd() {
    if (running 
        && proyection > t.getEndIndex()){
      endTime = car.time;
      return true;
    }
    return false;
  }

 void update() {
    if(finish) return;
    pProyection = proyection;
    proyection = updateProyection(car.pos);
    if(proyection < pProyection) 
      return;
    
    if(running && !loopTrack.checkAvgSpeed(proyection, car.time, car.speed))
      return;
   
    
    
    inTrack = updateInTrack();
    
    if (!running) {
        running = updateStart(); 
        if (running) {
          loopTrack = new LoopTrack(t, car);  
          loopTrack.add(pProyection, car.pTime, 0, "start");
        }
    }
     if(running){
      finish = updateEnd(); 
      if (finish) {         
        loopTrack.add(proyection, car.time, car.speed, "ended");
        inTrack = false;
        running = false;
        mysql.insertResult(car.id, t.id,  getTotalTime());
      }
      else{
        loopTrack.add(proyection, car.time, car.speed, "running");
      }
    }
   
  }
 
  float getDistanceFromStart(){
    if(loopTrack == null) return t.getDistanceFromStart(proyection);
    return loopTrack.getDistanceFromStart();
  }
  float getTotalTime() {
    return loopTrack.getTotalTime();
 
  }
  

}

