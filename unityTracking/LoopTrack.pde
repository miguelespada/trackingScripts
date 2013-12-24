class LoopPoint {
  PVector pos;
  float time;
  float distance;
  float speed;
  float avgSpeed;
  int idx;
  LoopPoint() {
    pos = new PVector(0, 0);
    time = 0;
    distance = 0;
    speed = 0;
  }
  LoopPoint(PVector pos, float time, float distance, float speed, int idx) {
    this.pos = pos;
    this.time = time;
    this.distance = distance;
    this.speed = speed;
    this.avgSpeed = avgSpeed;
    this.idx = idx;
  }
}
class LoopTrack {

  ArrayList<LoopPoint> loopTrack;
  ArrayList<LoopPoint> loopTrackTeorico;
  LoopPoint pos;
  Tramo tramo;
  int drawIdx = 0;
  PrintWriter output;
  String fileName;
  Car car;
  LoopTrack(Tramo t, Car c) {
    loopTrack = new ArrayList<LoopPoint>();
    loopTrackTeorico = new ArrayList<LoopPoint>();
   // fileName = "/Users/miguel/Desktop/Unity Tracking/tracking_frontEnd/Assets/DXF/Tramo_" + t.id + "_car_" + c.id + ".csv";
    fileName = "data/Tramo_" + t.id + "_car_" + c.id + ".csv";
    reset();
    this.tramo = t;
    this.car = c;
  } 

  void reset() {
    loopTrack.clear();
    loopTrackTeorico.clear();
    pos = new LoopPoint();
    
    output = createWriter(fileName);

    
    
  }
 void add(String st) {
    output.println(car.id + ","  +  "*" + "," + st);
    output.flush();

  output.close();
 }
  void add(PVector p, int pIdx, float time, float speed, String st, float dstProyection) {
    if ((p.x != pos.pos.x && p.y != pos.pos.y) ) {
      float dst = tramo.getDistanceFromStart(p);
      pos = new LoopPoint(new PVector(p.x, p.y), time, dst, speed, pIdx);
      loopTrack.add(pos);
      if(st.equals("start")){
        output.println("car id, gps track, state, track idx, time, calculated speed, real speed, dst to end, distance, point x, point y, normalized x, normalized y, dst to projection");
      }
      float avg = calculateAvgSpeedOfLastPeriod();
      if(st.equals("running")){
        LoopPoint prev = loopTrack.get(loopTrack.size() - 2);
        
        for(int i = prev.idx + 1; i < pos.idx; i ++){
          loopTrackTeorico.add(new LoopPoint(tramo.get(i), 0, 0, avg, i)); 

          float localDst = tramo.getDistanceFromStart(tramo.get(i)) - prev.distance;
          float localTime = (localDst/avg);
          output.println(car.id + "," +  "-" + ","
              + st + "," 
              + i + ","
              + int((localTime + prev.time - getStartTime())*10)/10.0 + "," 
              + int(avg*100)/100.0 + "," 
              + "?" + ","
              + int((tramo.totalLength -  tramo.getDistanceFromStart(tramo.get(i)))) + ","
              + int(tramo.getDistanceFromStart(tramo.get(i)) ) + "," 
              + tramo.get(i).x + "," 
              + tramo.get(i).y + "," 
              + int((tramo.get(i).x - tramo.getStart().x)) + "," 
              + int((tramo.get(i).y - tramo.getStart().y)) + ","
              + "?");
        }
      }
      
      
      output.println(car.id + ","  +  "*" + ","
              + st + "," 
              + pIdx + ","
              + getCurrentTime() + "," 
              + int(avg*100)/100.0 + "," 
              + (speed * 1000/3600) + ","
              + int((tramo.totalLength - dst)) + ","
              + int(dst) + ","
              + p.x + "," 
              + p.y + "," 
              + int((p.x - tramo.getStart().x)) + "," 
              + int((p.y - tramo.getStart().y)) + ","
              + int(dstProyection)); 
      output.flush();

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
    for(int i = 1; i < loopTrackTeorico.size(); i ++){
      
      LoopPoint lp = loopTrackTeorico.get(i);
      LoopPoint prev = loopTrackTeorico.get(i - 1);
      float avg = lp.speed;
      int x0 = int(prev.pos.x);
      int y0 = int(prev.pos.y); 
      int x1 = int(lp.pos.x);
      int y1 = int(lp.pos.y); 
      pushStyle();
      int r = int(map(exp(avg), 0, exp(40), 50, 255));
      strokeWeight(6);
      stroke(0, r, 0, 270);
      line(x0, y0, x1, y1);
      popStyle();
    }
  }
  void sendLoop(int carId){
    /*
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
                        
      println(carId + "--- Sending loop " + st + " " + drawIdx + " " + 
                 avg + " " +
                 int(lp.pos.x - tramo.getStart().x) + " " +
                 int(lp.pos.y - tramo.getStart().y) );
      drawIdx += 1;
    }
    */
  }
  void resetLoop(){
    drawIdx = 0;
  }
}

