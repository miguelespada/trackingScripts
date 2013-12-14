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
     reset();
     this.tramo = t;
   } 
   
   void reset(){
     loopTrack = new ArrayList<LoopPoint>();
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
   
   
}
