class Tramos {
  ArrayList<Tramo> tramos;
  int focus = -1;
  String fileName;
  
  Tramos(String fileName) {
    tramos = new ArrayList<Tramo>();
    loadTramos(fileName);
    this.fileName = fileName;
  }
  
  void loadTramos(String fileName){
    String lines[] = loadStrings(fileName);
    try{
      for (int i = 0 ; i < lines.length; i++) {
         String[] tokens = splitTokens(lines[i], ",");
         String tramoName = tokens[0];
         String utm = tokens[1];
         String real = tokens[2];
         int start = int(tokens[3]);
         int end = -abs(int(tokens[4]));
         add(new Tramo(tramoName, utm, real, start, end));
         
      }
    }
    catch(Exception e){
      println("ERROR: reading tramos");
    }
   
  }
  void write(){
    PrintWriter output = createWriter("data/" + fileName);  
     for (Tramo t: tramos)
        output.println(t.toString());
    output.close();
  }
  void add(Tramo t) {
    t.setId(tramos.size());
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
  
  
}

