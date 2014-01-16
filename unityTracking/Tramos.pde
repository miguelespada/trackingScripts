class Tramos {
  ArrayList<Tramo> tramos;
  int focus = -1;
  
  Tramos() {
    tramos = new ArrayList<Tramo>();
  }
  void loadTramos(){
    mySql.loadTramos();
  }
  void add(Tramo t) {
    t.setId(tramos.size());
    tramos.add(t);
  }
  
  PVector setFocus(int i) {
    if(i >= tramos.size()) 
      i = 0;
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
  
  void draw() {
    for (Tramo t: tramos){
      if(t.inFocus()){
        t.draw(255);
      }
      else{
        if(showAll) t.draw(50);
      }
      
    } 
  }
  void addStart(){
    for (Tramo t: tramos)
      if(t.inFocus())  
        t.addStart();
  }
  
  void addEnd(){
    for (Tramo t: tramos)
      if(t.inFocus())  
        t.addEnd();
  }
   void subStart(){
    for (Tramo t: tramos)
      if(t.inFocus())  
        t.subStart();
  }
  
  void subEnd(){
    for (Tramo t: tramos)
      if(t.inFocus())  
        t.subEnd();
  }
  
  String getFocusName(){
    for (Tramo t: tramos)
      if(t.inFocus()) 
        return t.name;
    return "-";
  }
  int getFocusId(){
    for (Tramo t: tramos)
      if(t.inFocus()) 
        return t.id;
    return -1;
  }
  
  
}

