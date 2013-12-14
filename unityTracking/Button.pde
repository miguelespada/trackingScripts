class Button {
  int x, y, a;
  boolean state = true;
  int id;
  String type;
  Button(String type, int id) {
    this.id = id;
    this.type = type;
    state = loadSetting(type + "_" + id, false);
  }
  
  void setPosition(int x, int y, int a) {
    this.x = x - a;
    this.y = y + a;
    this.a = a;
  } 

  void draw() {
    pushStyle();

    if (state)
      fill(53, 200, 87);
    else
      fill(200, 102, 48);

    noStroke();
    ellipseMode(CENTER);
    ellipse(x, y, a, a);
    popStyle();
  }
  void mouseClicked() {
    if (dist(mouseX, mouseY, x, y)  < a / 2) {
      state = !state;
      saveSetting(type + "_" + id, state);
    }
  }
  
  boolean getValue() {
    return state;
  }
  void setValue(boolean b) {
    state = b;
  }
}

