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
float numSecPerChange = 0.2;
float secondsPassed = 0;
boolean triggerChange = false;
float timeChangeOne = 100;


void setup() {
  size(1300, 1000);

  // set initial rectangle colors
  loadPixels();
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
      int k = j*width + i;
      float[] rectDim = getRectDim(i, j);
      pixels[k] = getRectColor(rectDim[0], rectDim[1], rectDim[2], 0);
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
        color oldColor = getRectColor(rectDim[0], rectDim[1], rectDim[2], 0);
        color newColor = getRectColor(rectDim[0], rectDim[1], rectDim[2], 1);
        pixels[k] = lerpColor(oldColor, newColor, secondsPassed/timeChangeOne);
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

color getRectColor(float rectNum, float xPerc, float yPerc, int state) {
  if (rectNum == 1) {
    if (state == 0) return lerpColor(red, pink, yPerc);
    else if (state == 1) return lerpColor(blue, darkGreen, xPerc);   
  } else if (rectNum == 2) {
    if (state == 0) return lerpColor(blue, magenta, yPerc);
    else if (state == 1) return lerpColor(yellow, blue, xPerc);
  } else if (rectNum == 3) {
    if (state == 0) return lerpColor(purple, pink, yPerc);
    else if (state == 1) return lerpColor(mustard, magenta, xPerc);
  }
  return color(0, 0, 0);
}