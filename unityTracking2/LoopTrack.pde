class LoopPoint {
  float time;
  float speed;
  int idx;
  String status;
  Tramo tramo;
  
  LoopPoint(Tramo t, int proyectionIndex, float time, float speed, String status) {
    this.status = status;
    this.time = time;
    this.speed = speed;
    this.idx = proyectionIndex;
    this.tramo = t;
  }
  String toString(){
      String s = idx + "," + getRealIndex() + "," + int(time) + "," + (int(speed * 10) /10.0) + ",'" + status + "'," 
                + int(getPos().x) + "," + int(getPos().y) 
                + "," + int((getPos().x - ref.x)) 
                + "," + int((getPos().y - ref.y));
                
      return s;
  }
  PVector getPos(){
    return tramo.getUtmPoint(idx);
  }
  
  int getRealIndex(){
    return tramo.getRealIndex(idx);
  }
  float getRealDistanceFromStart(){
    return tramo.getRealDistanceFromStart(getRealIndex());
  }
}

class LoopTrack {

  ArrayList<LoopPoint> loopTrack; 
  String fileName;
  Car car;
  Tramo tramo;
  LoopPoint last;
  float accError;
 
   LoopTrack(Tramo t, Car c) {
    loopTrack = new ArrayList<LoopPoint>();
    fileName = host + "Loops/Tramo_" + t.id + "_car_" + c.id;
    this.tramo = t;
    this.car = c;
  
    accError = 0;
  }
  
  void add(int proyectionIndex, float time, float speed, String status) {
    speed = speed * 1000/3600;
    last = new LoopPoint(tramo, proyectionIndex, time, speed, status);
    loopTrack.add(last);
    writePoint(last); 
  }
  
  
  
  void writePoint(LoopPoint last){
    float error = car.dist(last.getPos());
    
    float avg = calculateAvgSpeedOfLastPeriod();
    
    String s = "";
    s += car.id;
    s += "," + tramo.id;
    s += "," + last.toString();
    s += "," + int(avg * 10) / 10.0;
    s += "," + int(getTotalTime());
    s += "," + int(getDistanceFromStart());
    s += "," + int((tramo.getRealTotalLength() - getDistanceFromStart()));
    s += "," + int(error);
   
    if(last.status == "running")
      accError += error;
    
    mySql.insertTrack(s, true);
     
    
    writeInterpolation(avg);
  }
  

  void writeInterpolation(float avg){
    if(loopTrack.size() < 2) return;
      LoopPoint prev = loopTrack.get(loopTrack.size() - 2); 
      
      boolean started = true;
      if(prev.status.equals("start"))
        started = false;
        
      for(int i = prev.getRealIndex() + 1; i < last.getRealIndex(); i ++){
        if(tramo.getRealDistanceFromStart(i) < 0){
          continue;
        }
         
        float localDst = tramo.getRealDistanceFromStart(i) - prev.getRealDistanceFromStart();
        float localTime = (localDst/avg);
        float time = localTime + prev.time - loopTrack.get(0).time;
        
        if(!started){ 
           loopTrack.get(0).time += time; //encendemos el cronómetro
           time = 0;
           started = true;
        }
        
        String s = car.id + "," + tramo.id ; 
        s += "," + i;
        s += "," + (int(avg * 10)/10.0);
        s += "," + (int(time * 10) /10.0);
        s += "," + int(tramo.getRealDistanceFromStart(i));
        s += "," + int((tramo.getRealTotalLength() - tramo.getRealDistanceFromStart(i)));
       
      mySql.insertTrack(s, false);

        if(i >= tramo.getRealEndIndex()){
          last.time = time + loopTrack.get(0).time; //apagamos el cronometro
          break; 
        }
      }
  }

  void draw(){
    if(loopTrack == null) return;
    if(loopTrack.size() < 1) return;
    
    for(int i = 1; i < loopTrack.size(); i ++){
      LoopPoint lp = loopTrack.get(i);
      LoopPoint prev = loopTrack.get(i - 1);
      int x0 = int(prev.getPos().x);
      int y0 = int(prev.getPos().y); 
      int x1 = int(lp.getPos().x);
      int y1 = int(lp.getPos().y); 
      pushStyle();
      strokeWeight(6);
      stroke(255, 255, 0);
      line(x0, y0, x1, y1);
      popStyle();
    
    }
  } 
  
  float getDistanceFromStart() {
    if(loopTrack == null) return 0;
    if(loopTrack.size() == 0) return 0;
    return last.getRealDistanceFromStart();
  }
   
  float getTotalTime() {
    if(loopTrack == null) return 0;
    if(loopTrack.size() == 0) return 0;
    return last.time - loopTrack.get(0).time;
  }
    
   float calculateAvgSpeedOfLastPeriod() {
    if (loopTrack.size() > 1) {
      LoopPoint prev = loopTrack.get(loopTrack.size() - 2);
      if (last.time == prev.time) return 0;
      return (last.getRealDistanceFromStart() - prev.getRealDistanceFromStart())/(last.time - prev.time);
    }
    else {
      return -1;
    }
  }
  
  
  


}

