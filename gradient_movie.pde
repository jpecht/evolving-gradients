// Constants //<>//
int Y_AXIS = 1;
int X_AXIS = 2;
int rectWidth = 800, rectHeight = 150;
color b1, b2;
color topRectTop, topRectBot;
color midRectTop, midRectBot;
color botRectTop, botRectBot;

int numSecPerChange = 1;
int secondsPassed = 0;
boolean triggerChange = false;

void setup() {
  size(960, 600);

  // define colors
  b1 = color(200, 200, 200);
  b2 = color(0, 0, 0);
  topRectTop = color(80, 0, 14);
  topRectBot = color(120, 20, 38);
  midRectTop = color(255, 255, 230);
  midRectBot = color(216, 216, 134);
  botRectTop = color(8, 26, 39);
  botRectBot = color(1, 36, 58);

  // set background color
  setGradient(0, 0, width/2, height, b1, b2, X_AXIS);
  setGradient(width/2, 0, width/2, height, b2, b1, X_AXIS);

  // set rectangle colors
  setGradient(80, 50, rectWidth, rectHeight, topRectTop, topRectBot, Y_AXIS);
  setGradient(80, 225, rectWidth, rectHeight, midRectTop, midRectBot, Y_AXIS);
  setGradient(80, 400, rectWidth, rectHeight, botRectTop, botRectBot, Y_AXIS);
}

void draw() {
  int ms = millis(); // get the milliseconds that have passed since run
  
  // trigger a change every second
  if (ms % 1000*numSecPerChange > secondsPassed) {
    secondsPassed = ms % 1000*numSecPerChange;
    triggerChange = true;
  }
  
  // change colors on every trigger
  if (triggerChange) {
    loadPixels();
    for (int i = 0; i < width*height; i++) {
      pixels[i] += 2*random(1) - 1;
    }
    updatePixels();
  }
}

void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {
  noFill();

  if (axis == Y_AXIS) {  // Top to bottom gradient
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);      
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  } else if (axis == X_AXIS) {  // Left to right gradient
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
  }
}