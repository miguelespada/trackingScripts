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
      String s = idx + "," + getRealIndex() + "," + int(time) + "," + (int(speed * 10) /10.0) + "," + status + "," 
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
  float getDistanceFromStart(){
    return tramo.getDistanceFromStart(idx);
  }
  float getRealDistanceFromStart(){
    return tramo.getRealDistanceFromStart(getRealIndex());
  }
}

class LoopTrack {

  ArrayList<LoopPoint> loopTrack; 
  PrintWriter output, output2;
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
  
    try{
      output = new PrintWriter(new FileOutputStream(new File(fileName + ".csv"), true)); 
      output2 = new PrintWriter(new FileOutputStream(new File(fileName + "_interpolated.csv"), true)); 
    }
    catch(FileNotFoundException e){
      println(e);
      output = createWriter(fileName + ".csv");   
      output2 = createWriter(fileName + "_interpolated.csv");    
    }
    accError = 0;
  }
  void removeData(){
      output = createWriter(fileName + ".csv");   
      output2 = createWriter(fileName + "_interpolated.csv");     
  }
  
  void add(int proyectionIndex, float time, float speed, String status) {
    speed = speed * 1000/3600;
    last = new LoopPoint(tramo, proyectionIndex, time, speed, status);
    loopTrack.add(last);
    writePoint(last); 
  }
  
  LoopPoint loadLoop(){
    String lines[] = loadStrings(fileName + ".csv");
    if (lines.length == 0)
      return null;
    for (int i = 1; i < lines.length; i++) {
      String[] tokens = splitTokens(lines[i],",");
      int proyectionIndex = int(tokens[2]);
      float time = float(tokens[4]);
      float speed = float(tokens[5]);
      String status = tokens[6];
      last = new LoopPoint(tramo, proyectionIndex, time, speed, status);
      loopTrack.add(last);
    } 
    return last;
  }
  
  void writePoint(LoopPoint last){
    float error = car.dist(last.getPos());
    
    float avg = calculateAvgSpeedOfLastPeriod();
    
    if(last.status == "start"){
      String s = "Car Id,Tramo Id,UTM Index,REAL Index,Car Time,Speed,Status,Utm X,Utm Y,Norm X,Norm Y,Avg Speed,Track Time,Distance,Remaining Distance,Error";
      output.println(s);
      output2.println(s);
    }
    String s = "";
    s += car.id;
    s += "," + tramo.id;
    s += "," + last.toString();
    s += "," + int(avg * 10) / 10.0;
    s += "," + int(getTotalTime());
    s += "," + int(getDistanceFromStart());
    s += "," + int((tramo.getTotalLength() - getDistanceFromStart()));
    s += "," + int(error);
   
    if(last.status == "running")
      accError += error;
     
    output.println(s);
    
    writeInterpolation(avg);
    output2.println(s);
    
    output.flush();
    output2.flush();
    
    if(last.status == "ended"){
      output.close();
      output2.close();
      //println(car.id + " ERROR: " + accError / (loopTrack.size() - 2));
    }
  }
  

  void writeInterpolation(float avg){
    if(loopTrack.size() < 2) return;
      LoopPoint prev = loopTrack.get(loopTrack.size() - 2);
      for(int i = prev.getRealIndex() + 1; i < last.getRealIndex(); i ++){
        float localDst = tramo.getRealDistanceFromStart(i) - prev.getRealDistanceFromStart();
        float localTime = (localDst/avg);
        float time = localTime + prev.time - loopTrack.get(0).time;
        String s = ",,,";
        s += i;
        s += ",," + ",,,,,,";
        s += (int(avg * 10)/10.0);
        s += "," + int(time);
        s += "," + int(tramo.getRealDistanceFromStart(i));
        s += "," + int((tramo.getRealTotalLength() - tramo.getRealDistanceFromStart(i)));
        output2.println(s);
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

