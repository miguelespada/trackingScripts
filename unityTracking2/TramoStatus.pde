
class TramoStatus {
  Tramo t;
  Car car;

  boolean inTrack = false;
  boolean running = false;
  boolean finish = false;

  int proyection, pProyection;
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
    return car.dist(t.getUtmPoint(proyection)) < trackThreshold;
  }

  boolean updateStart() {  
    if (inTrack && 
      !running && 
      proyection > t.getStartIndex()
      ) {
      return true;
    }
    return false;
  }
  
  boolean updateEnd() {
    
    if (running 
        && proyection > t.getEndIndex()) 
      return true;
    
    return false;
  
  }

  void update() {
    if(finish) return;
    pProyection = proyection;
    proyection = updateProyection(car.pos);
    if(proyection == pProyection) return;
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
      }
      else{
        loopTrack.add(proyection, car.time, car.speed, "running");
      }
    }
  }
  
  int getId(){
    return t.id;
  }
  
    
  void drawLoop(){
    if(loopTrack != null)  
      loopTrack.draw();
  }
  float getDistanceFromStart() {
    if(loopTrack == null) return 0;
    return loopTrack.getDistanceFromStart();
  }
   float getTotalTime() {
    if(loopTrack == null) return 0;
    return loopTrack.getTotalTime();
  }
  
  void loadLoop(){
    if(loopTrack == null) 
        loopTrack = new LoopTrack(t, car);  
          
    LoopPoint last = loopTrack.loadLoop();
    if(last == null) return;
    
    if(last.status.equals("running")){
      inTrack = true;
      running = true;
      finish = false;
    }
    if(last.status.equals("start")){
      inTrack = true;
      running = true;
      finish = false;
    }
    if(last.status.equals("ended")){
      finish = true;
      inTrack = false;
      running = false;
    }
    proyection = last.idx;
    car.time = last.time;
    car.speed = last.speed;
    car.pos = t.getUtmPoint(proyection);
  }

  void removeLoop(){
     if(loopTrack != null) 
         loopTrack.removeData();
  }

}

