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
      String s = idx + "," + idx + "," + int(time) + "," + (int(speed * 10) /10.0) + ",'" + status + "'," 
                + int(getPos().x) + "," + int(getPos().y) 
                + "," + int((getPos().x - tramo.getX())) 
                + "," + int((getPos().y - tramo.getY()));
                
      return s;
  }
  PVector getPos(){
    return tramo.get(idx);
  }
  
  float getDistanceFromStart(){
    return tramo.getDistanceFromStart(idx);
  }
  int getIndex(){
    return idx;
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
  
  boolean checkAvgSpeed(int proyectionIndex, float time, float speed){
    last = new LoopPoint(tramo, proyectionIndex, time, speed, "none");
    float avg = calculateAvgSpeedOfLastPeriod();
    return avg < 40 && avg >= 10;
  }
  
  void add(int proyectionIndex, float time, float speed, String status) {
    speed = speed * 1000/3600;
    last = new LoopPoint(tramo, proyectionIndex, time, speed, status);
    float avg = calculateAvgSpeedOfLastPeriod();
    loopTrack.add(last);
    writePoint(last); 
  }
  
  
  
  void writePoint(LoopPoint last){
    float error = car.pos.dist(last.getPos());
    
    float avg = calculateAvgSpeedOfLastPeriod();
   
    String s = "";
    s += car.id;
    s += "," + str(tramo.id);
    s += "," + last.toString();
    s += "," + int(avg * 10) / 10.0;
    s += "," + int(getTotalTime());
    s += "," + int(getDistanceFromStart());
    s += "," + int((tramo.getTotalLength() - getDistanceFromStart()));
    s += "," + int(error);
   
    if(last.status == "running")
      accError += error;
    
    mysql.insertTrack(s, true);
     
    
    writeInterpolation(avg);
  }
  

  void writeInterpolation(float avg){
    if(loopTrack.size() < 2) return;
      LoopPoint prev = loopTrack.get(loopTrack.size() - 2); 
      
      boolean started = true;
      if(prev.status.equals("start"))
        started = false;
        
      for(int i = prev.getIndex() + 1; i < last.getIndex(); i ++){
        if(tramo.getDistanceFromStart(i) < 0){
          continue;
        }
         
        float localDst = tramo.getDistanceFromStart(i) - prev.getDistanceFromStart();
        float localTime = (localDst/avg);
        float time = localTime + prev.time - loopTrack.get(0).time;
        
        if(!started){ 
           loopTrack.get(0).time += time; //encendemos el cronómetro
           time = 0;
           started = true;
        }
        
        String s = car.id + "," + str(tramo.id) ; 
        s += "," + i;
        s += "," + (int(avg * 10)/10.0);
        s += "," + (int(time * 10) /10.0);
        s += "," + int(tramo.getDistanceFromStart(i));
        s += "," + int((tramo.getTotalLength() - tramo.getDistanceFromStart(i)));
       
        mysql.insertTrack(s, false);

        if(i >= tramo.getEndIndex()){
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
    if(loopTrack.size() == 0) return 0;
    return last.getDistanceFromStart();
  }
   
  float getTotalTime() {
    if(loopTrack.size() == 0) return 0;
    return last.time - loopTrack.get(0).time;
  }
    
   float calculateAvgSpeedOfLastPeriod() {
    if (loopTrack.size() > 1) {
      LoopPoint prev = loopTrack.get(loopTrack.size() - 2);
      if (last.time == prev.time) return 0;
      return (last.getDistanceFromStart() - prev.getDistanceFromStart())/(last.time - prev.time);
    }
    else {
      return -1;
    }
  }
  
  
  


}

