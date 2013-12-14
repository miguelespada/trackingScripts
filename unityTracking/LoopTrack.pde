class LoopPoint{
  PVector pos;
  float time;
  float distance;
  float speed;
  float avgSpeed;
  LoopPoint(){
    pos = new PVector(0, 0);
    time = 0;
    distance = 0;
    speed = 0;
    avgSpeed = 0;
  }
  LoopPoint(PVector pos, float time, float distance, float speed, float avgSpeed){
    this.pos = pos;
    this.time = time;
    this.distance = distance;
    this.speed = speed;
    this.avgSpeed = avgSpeed; 
  }
}
class LoopTrack{
 
   ArrayList<LoopPoint> loopTrack;
   LoopPoint pos;
   Tramo tramo;
   
   LoopTrack(Tramo t){
     loopTrack = new ArrayList<LoopPoint>();
     reset();
     this.tramo = t;
   } 
   
   void reset(){
     loopTrack.clear();
     pos = new LoopPoint();
   }
   
   void add(PVector p, float time, float speed, float avgSpeed){
     if(p.x != pos.pos.x && p.y != pos.pos.y){
       float dst = tramo.getDistanceFromStart(p);
       pos = new LoopPoint(p, time, dst, speed, avgSpeed);
       loopTrack.add(pos);
     }
   }
   float getDistanceFromStart(){
     return pos.distance; 
   }
   float calculateAvgSpeedOfLastPeriod(){
      if(loopTrack.size() > 1){
       LoopPoint prev = loopTrack.get(loopTrack.size() - 2);
       return (pos.distance - prev.distance)/(pos.time - prev.time);
     }
     else{
       return -1;
     }
   }
   
   
}
