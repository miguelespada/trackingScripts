class LoopPoint {
  PVector pos;
  float time;
  float distance;
  float speed;
  float avgSpeed;
  LoopPoint() {
    pos = new PVector(0, 0);
    time = 0;
    distance = 0;
    speed = 0;
  }
  LoopPoint(PVector pos, float time, float distance, float speed) {
    this.pos = pos;
    this.time = time;
    this.distance = distance;
    this.speed = speed;
    this.avgSpeed = avgSpeed;
  }
}
class LoopTrack {

  ArrayList<LoopPoint> loopTrack;
  LoopPoint pos;
  Tramo tramo;
  int drawIdx = 0;

  LoopTrack(Tramo t) {
    loopTrack = new ArrayList<LoopPoint>();
    reset();
    this.tramo = t;
  } 

  void reset() {
    loopTrack.clear();
    pos = new LoopPoint();
  }

  void add(PVector p, float time, float speed) {
    if (p.x != pos.pos.x && p.y != pos.pos.y) {
      float dst = tramo.getDistanceFromStart(p);
      pos = new LoopPoint(new PVector(p.x, p.y), time, dst, speed);
      loopTrack.add(pos);
    }
  }

  float getDistanceFromStart() {
    return pos.distance;
  }

  float calculateAvgSpeedOfLastPeriod() {
    if (loopTrack.size() > 1) {
      LoopPoint prev = loopTrack.get(loopTrack.size() - 2);
      if (pos.time - prev.time == 0) return 0;

      return (pos.distance - prev.distance)/(pos.time - prev.time);
    }
    else {
      return -1;
    }
  }
  

  float getStartTime() {
    if(loopTrack.size() == 0) return 0;
    return loopTrack.get(0).time;
  }
  float getEndTime() {
    if(loopTrack.size() == 0) return 0;
    return loopTrack.get(loopTrack.size() - 1).time;
  }
  float getTotalTime() {
    return getEndTime() - getStartTime();
  }

  float getCurrentTime() {
    return pos.time - getStartTime();
  }
  void drawLoop(int carId){
    if(frameCount % 60 != 0) return;
    if(drawIdx < loopTrack.size()){
      LoopPoint lp = loopTrack.get(drawIdx);
      String st = "normal";
      if(drawIdx == 0)
        st = "first"; 
        
      float avg = 0;    
      if(drawIdx > 0 ) {
         LoopPoint prev = loopTrack.get(drawIdx - 1);
         if(lp.time - prev.time != 0)
           avg = (lp.distance - prev.distance)/(lp.time - prev.time);
      }
      oscSendCar(carId, int(lp.pos.x - tramo.getStart().x), 
                        int(lp.pos.y - tramo.getStart().y), 
                        avg, 
                        lp.speed, 
                        st);
                        
      println(carId + "--- Drawing loop " + st + " " + drawIdx + " " + 
                 avg + " " +
                 int(lp.pos.x - tramo.getStart().x) + " " +
                 int(lp.pos.y - tramo.getStart().y) );
      drawIdx += 1;
    }
  }
  void resetLoop(){
    drawIdx = 0;
  }
}

