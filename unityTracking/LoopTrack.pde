class LoopPoint{
  PVector pos;
  float time;
  float distance;
  LoopPoint(PVector pos, float time, float distance){
    this.pos = pos;
    this.time = time;
    this.distance = distance;
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
     pos = new LoopPoint(new PVector(0, 0), 0, 0);
   }
   
   void add(PVector p, float time){
     if(p.x != pos.pos.x && p.y != pos.pos.y){
       float dst = tramo.calculateDistanceFromStart(p);
       pos = new LoopPoint(p, time, dst);
       loopTrack.add(pos);
     }
   }
   float calculateDistanceFromStart(){
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
