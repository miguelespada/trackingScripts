class Tramos {
  int n;
  int focus
  
  Tramos(int focus) {
    this.n = mySql.loadTramos();
    this.focus = focus;
    setFocus(focus);
  }
  
  Tramo setFocus(int i) {
    if(n == 0) return null;
    if(i >= n) i = 0;
    else this.focus = i;
    return loadTramo(focus);
  }
  
  PVector nextFocus() {
    focus = (focus + 1) % n;
    return setFocus(focus);
  }
  
  int size(){
     return n;
  }
}

