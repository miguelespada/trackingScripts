import java.sql.Timestamp;

class RealTime{
 
   java.util.Date date, current;
   boolean running;
   long offset;
   String prev;  
   
   RealTime(){ 
       reset();
       running = false;
   }
   void reset(){
       this.date = new java.util.Date();  
       this.current = new java.util.Date(); 
       this.prev = null;
       offset = 00000;
   }
   void toggle(){
     running = !running;
     
     if(running) {
       cars.reset();
       prev = null;
     }
     
   }
   void offset(int i){
     offset += (i * 1000);
   }
   
   void setEnd(){
     offset = tramos.getTotalTime();
   }
   
   String getPrevElapsed(){
     if (prev == null){
      Timestamp d =  new Timestamp(tramos.getInitTime());
      prev = d.toString();
     } 
     return prev;
   }
   
   void setPrevElapsed(String d){
     prev = d;
   }
   
   String getElapsed(){
     if(running)
       current = new java.util.Date() ; 
       
     if(current.getTime() - date.getTime() + offset  > tramos.getTotalTime()) 
       running = false;
       
     Timestamp d =  new Timestamp( current.getTime() - date.getTime() + tramos.getInitTime() + offset );
     return d.toString(); 
   }
}
