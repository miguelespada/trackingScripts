class Tramos {
  ArrayList<Tramo> tramos;
  int focus = -1;
  Tramos() {
    tramos = new ArrayList<Tramo>();
  }
  void add(int id, String name) {
    Tramo t = new Tramo(id);
    t.loadData(name);
    tramos.add(t);
  }
  PVector setFocus(int i) {
    this.focus = i;
    PVector r = null; 
    for (Tramo t: tramos) {
      if (t.id == focus) {
        t.setFocus(true);
        r = t.start;
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

  void register(Cars cars) {
    for (Tramo t: tramos)
      cars.registerTramo(t);
  }
  void draw() {
    for (Tramo t: tramos){
      t.draw();
      if(t.inFocus()){
        t.calculateCurrentClassification();
        t.calculateFinalClassification();
      }
    }
  }
  
  void drawCurrentClassification(int x, int y) {
    for (Tramo t: tramos){
      if(t.inFocus())
        t.drawCurrentClassification(x, y);
    }
  }
   void drawFinalClassification(int x, int y) {
    for (Tramo t: tramos){
      if(t.inFocus())
        t.drawFinalClassification(x, y);
    }
  }
  
}

