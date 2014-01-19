

class Tramos {
  int n;
  int focus;
  Tramo tramo;
  Cars cars;
  
  Tramos() {
    this.n = mysql.loadTramos();
  }
  
  void setTramo(int i) {
    if(n == 0) {
      tramo = null;
      println("[ERROR] no existen tramos;");
      return;
    }
    if(i >= n) i = 0;
    else this.focus = i;
    loadTramo(focus);
    rt = new RealTime();
    cars.registerTramo(tramo);
  }
  
  void loadTramo(int i){
    tramo = mysql.loadTramo(i);
    
  }
  
  void changeFocus(int i) {
    focus = (focus + i) % n;
    if(focus < 0) focus = n - 1;
    setTramo(focus);
  }
  
  int size(){
     return n;
  }
  void drawInfo(int x, int y){
    pushStyle();
    fill(255);
    textSize(12);
    pushMatrix();
    translate(x, y);
    text("Tramos: (" + focus + "/" + n + ")", 0, 0);
    text("Elapsed: " + rt.getElapsed(), 0, 20);
    popMatrix();
    popStyle();
    
    tramo.drawInfo(x, y + 40);
  }
  float getX(){
    return tramo.getX();
  }
  
  float getY(){
    return tramo.getY();
  }
  void draw(){
    tramo.draw();
  }
   void addStart(int i) {
    tramo.addStart(i);
  }

  void addEnd(int i) {
    tramo.addEnd(i);
  }
  void setInitTime(){
    tramo.setInitTime();
  }
  
  void setEndTime(){
    tramo.setEndTime();
  }
  long getInitTime(){
    return tramo.getInitTime().getTime();
  }
   long getEndTime(){
    return tramo.getEndTime().getTime();
  }
  
  long getTotalTime(){
    return  tramo.getEndTime().getTime() - tramo.getInitTime().getTime();
  }
  void registerCars(Cars cars){
     this.cars = cars;
    
  }
}

