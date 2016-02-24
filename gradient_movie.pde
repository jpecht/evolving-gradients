// Constants //<>//
int Y_AXIS = 1;
int X_AXIS = 2;

// rectangle dimensions
float rectOneX = 0, rectOneY = 0;
float rectOneWidth = 1300, rectOneHeight = 300;
float rectTwoX = 0, rectTwoY = 300;
float rectTwoWidth = 1300, rectTwoHeight = 400;
float rectThrX = 0, rectThrY = 700;
float rectThrWidth = 1300, rectThrHeight = 300;

// colors
color red = color(212, 106, 106);
color orange = color(212, 164, 106);
color brown = color(128, 79, 21);
color lightYellow = color(255, 253, 170);
color yellow = color(212, 210, 106);
color mustard = color(128, 125, 21);
color green = color(124, 185, 92);
color darkGreen = color(50, 111, 18);
color blue = color(16, 44, 92);
color darkBlue = color(25, 21, 97);
color purple = color(42, 17, 95);
color lightPurple = color(64, 12, 93);
color magenta = color(83, 9, 91);
color pink = color(111, 9, 67);

// how often color change is occurring
float numSecPerChange = 1;
int secondsPassed = 0;
boolean triggerChange = false;


void setup() {
  size(1300, 1000);

  // set initial rectangle colors
  loadPixels();
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
      int k = j*width + i;
      float[] rectDim = getRectDim(i, j);
      if (rectDim[0] == 1) {
        pixels[k] = lerpColor(red, pink, rectDim[2]);
      } else if (rectDim[0] == 2) {
        pixels[k] = lerpColor(blue, magenta, rectDim[2]);
      } else if (rectDim[0] == 3) {
        pixels[k] = lerpColor(purple, pink, rectDim[2]);
      }
    }
  }
  updatePixels();
}

void draw() {
  int ms = millis(); // get the milliseconds that have passed since run
  
  // trigger a change every second
  if (floor(ms / int(1000*numSecPerChange)) > secondsPassed) {
    secondsPassed = floor(ms / int(1000*numSecPerChange));
    triggerChange = true;
  }
  
  // change colors on every trigger
  if (triggerChange) {
    println(secondsPassed);
    
    loadPixels();
    for (int j = 0; j < height; j++) {
      for (int i = 0; i < width; i++) {
        int k = j*width + i;
        float[] rectDim = getRectDim(i, j);
        if (rectDim[0] == 1) {
          pixels[k] = lerpColor(pixels[k], lerpColor(blue, darkGreen, rectDim[2]), rectDim[1]);
        } else if (rectDim[0] == 2) {
          pixels[k] = lerpColor(pixels[k], lerpColor(yellow, brown, rectDim[2]), rectDim[1]);
        } else if (rectDim[0] == 3) {
          pixels[k] = lerpColor(pixels[k], lerpColor(mustard, magenta, rectDim[2]), rectDim[1]);
        }
      }
    }
    updatePixels();
    triggerChange = false;
  }
}

float[] getRectDim(int x, int y) {
  float rectNum = -1, xPerc = -1, yPerc = -1;
  if ((x >= rectOneX && x <= rectOneX + rectOneWidth) && (y >= rectOneY && y <= rectOneY + rectOneHeight)) {
    rectNum = 1;
    xPerc = (x - rectOneX) / rectOneWidth;
    yPerc = (y - rectOneY) / rectOneHeight;
  } else if ((x >= rectTwoX && x <= rectTwoX + rectTwoWidth) && (y >= rectTwoY && y <= rectTwoY + rectTwoHeight)) {
    rectNum = 2;
  } else if ((x >= rectThrX && x <= rectThrX + rectThrWidth) && (y >= rectThrY && y <= rectThrY + rectThrHeight)) {
    rectNum = 3;
  }
  float[] returnArray = {rectNum, xPerc, yPerc};
  return returnArray;
}



/* ---------------------------- Unused Functions -------------------------- */
color transitionGradient(color a1, color a2, color b1, color b2, float duration, float time, float x, float y) {
  float distance = sqrt(sq(x) + sq(y)) / sqrt(2);
  color startColor = lerpColor(a1, a2, distance);
  color endColor = lerpColor(b1, b2, distance);
  return lerpColor(startColor, endColor, time/duration);
}

void setGradient(float x, float y, float w, float h, color c1, color c2, int axis ) {
  noFill();

  if (axis == Y_AXIS) {  // Top to bottom gradient
    for (float i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);      
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  } else if (axis == X_AXIS) {  // Left to right gradient
    for (float i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
  }
}