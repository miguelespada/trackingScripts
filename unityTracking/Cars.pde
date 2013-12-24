int N = 25;
color[] carColors = {
  #FF244C, #FF24F5, #7724FF, 
  #244AFF, #24BBFF, #24FFBF, 
  #24FF3B, #D2FF24, #FFB624, 
  #FF3624
};

class Cars {
  Car cars[];
  Car solo = null;
  Cars() {
    cars = new Car[N];
    for (int i = 0; i < N; i++) {
      cars[i] = new Car(i);
      cars[i].setColor(carColors[i % carColors.length]);
    }
  }
  void update() {
    for (int i = 0; i < N; i++) {
      cars[i].update();
    }
    updateSolo();
  }
  void add(int id, float x, float y, float s, int d){
    if(cars[id].time == d) 
      return;
    cars[id].fresh = true; 
    cars[id].addPos(x, y);
    cars[id].speed = s;
    cars[id].pTime = cars[id].time;
    cars[id].time = d;
  }
  
  void updateSolo(){
    boolean isSolo = false;
    for(int i = 0; i < N; i++){
      if(cars[i].solo()){
        isSolo = true;
        if(solo == null)
          solo = cars[i];
        if(solo != cars[i])
          cars[i].unSolo();
      }
    }
    if(!isSolo) solo = null;
  }
  void draw() {
    if(solo != null)
       solo.draw();
    else{
      for (int i = 0; i < 25; i++) {
        if (cars[i].isActive()){
          cars[i].draw();
        }
          
      }
    }
  }

  
  void displayInfo(int x, int y) {
    for (int i = 0; i < 25; i++) {
      if (cars[i].isActive()) {
        int nextY = y + cars[i].drawInfo(x, y);
        cars[i].drawControls(x, y);
        y = nextY;
      }
    }
  }
  
  void registerTramo(Tramo t) {
    for (int i = 0; i < 25; i++) 
      cars[i].registerTramo(t);
  }
  
  void reset() {
    for (int i = 0; i < 25; i++) 
      cars[i].reset();
  }
  
  void mouseClicked() {
    for (int i = 0; i < 25; i++) 
      cars[i].mouseClicked();
  }
  
  ArrayList<Car> getActiveCars(int tramoId) {
    ArrayList<Car> active = new ArrayList<Car>();
    for (int i = 0; i < 25; i++) {
      if (cars[i].isInTramo(tramoId) && cars[i].enabled())
        active.add(cars[i]);
    }
    return active;
  }
  
  ArrayList<Car> getFinalizedCars(int tramoId) {
    ArrayList<Car> active = new ArrayList<Car>();
    for (int i = 0; i < 25; i++) {
      if (cars[i].finished(tramoId) && cars[i].enabled())
        active.add(cars[i]);
    }
    return active;
  }
  
  ArrayList<Car> getRunningOrFinishCars(int tramoId) {
    ArrayList<Car> active = new ArrayList<Car>();
    for (int i = 0; i < 25; i++) {
      if ((cars[i].finished(tramoId) 
         || cars[i].running(tramoId)) 
        && cars[i].enabled())
        active.add(cars[i]);
    }
    return active;
  }
  
  
  void sendActiveCars(int tramoId){
    ArrayList<Car> active = getActiveCars(tramoId);
    String s = "";
    for(Car c: active){
      s += c.id;
      s += " ";
    }
    oscSendActiveCars(s);
  
  }
  void drawLoop(int t){
    for (int i = 0; i < 25; i++) {
        if(cars[i].isActive())
          cars[i].drawLoop(t);
    }    
  }
  void sendLoop(int t){
    for (int i = 0; i < 25; i++) {
          cars[i].sendLoop(t);
    }    
  }
  void resetLoop(int t){
  for (int i = 0; i < 25; i++) 
      cars[i].resetLoop(t);
  }
}

