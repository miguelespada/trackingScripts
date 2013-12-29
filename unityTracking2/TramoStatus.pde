int trackThreshold = 30;
int endThreshold = 1000;

class TramoStatus {
  Tramo t;
  Car car;

  boolean inTrack = false;
  boolean running = false;
  boolean finish = false;

  float pdStart, dStart, pdEnd, dEnd;
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
    
    pdStart = 1000000;
    dStart = 1000000;
    pdEnd = 1000000;
    dEnd = 1000000;
  }

  int updateProyection(PVector pos) {
    return t.getClosest(pos);
  }

  boolean updateInTrack() {
    return car.dist(t.getUtmPoint(proyection)) < trackThreshold;
  }

  boolean updateStart() {  
    //dStart =  car.dist(t.getStart());
    if (inTrack && 
      !running && 
      //dStart + trackThreshold > pdStart
      proyection > t.start
      ) {
      return true;
    }
   // pdStart = dStart;
    return false;
  }
  
  boolean updateEnd() {
    
    //dEnd = car.dist(t.getEnd());
    if (!inTrack 
        && running 
        && proyection > t.end) 
      return true;
    
   // pdEnd = dEnd;
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
    
    println("Reading loop: " + car.id + " tramo " + t.id);
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
  //  dEnd = car.dist(t.getEnd());
  //  dStart =  car.dist(t.getStart());
    car.pos = t.getUtmPoint(proyection);
    
  }

  void removeLoop(){
     if(loopTrack != null) 
         loopTrack.removeData();

  }

}

