class Tramos {
  ArrayList<Tramo> tramos;
  int focus = -1;
  
  Tramos() {
    tramos = new ArrayList<Tramo>();
  }
  
  void add(Tramo t) {
    tramos.add(t);
  }
  
  PVector setFocus(int i) {
    this.focus = i;
    PVector r = null; 
    for (Tramo t: tramos) {
      if (t.id == focus) {
        t.setFocus(true);
        r = t.getStart();
      }
      else {
        t.setFocus(false);
      }
    }
    return r;
  }
  
  PVector nextFocus() {
    focus = (focus + 1) % tramos.size();
    return setFocus(focus);
  }
  int size(){
    return tramos.size();
  }
  void register(Cars cars) {
    for (Tramo t: tramos)
      cars.registerTramo(t);
  }
  
  void draw() {
    for (Tramo t: tramos){
      if(t.inFocus()){
        t.draw(255);
      }
      else{
        t.draw(50);
      }
      
    } 
  }
  
  
  void drawCurrentClassification(int id, int x, int y) {
    for (Tramo t: tramos){
      if(t.id == id){
        t.calculateCurrentClassification();
        t.drawCurrentClassification(x, y);
      }
    }
  }
  
  void drawFinalClassification(int id, int x, int y) {
    for (Tramo t: tramos){
      if(t.id == id){
        t.calculateFinalClassification();
        t.drawFinalClassification(x, y);
      }
    }
  }
  
}

