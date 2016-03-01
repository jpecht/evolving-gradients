import java.util.ArrayList; //<>//

// Constants
int Y_AXIS = 1;
int X_AXIS = 2;

// rectangle dimensions
float rectOneX = 0, rectOneY = 0;
float rectOneWidth = 1300, rectOneHeight = 300;
float rectTwoX = 0, rectTwoY = 300;
float rectTwoWidth = 1300, rectTwoHeight = 400;
float rectThrX = 0, rectThrY = 700;
float rectThrWidth = 1300, rectThrHeight = 300;
int numRectStates = 7;

// line dimensions
int[][][] lineDimCollection;
int lineStates = 20;
int maxLines = 5;
int maxLineDistance = 50;
color lineColor = color(50, 50, 50);

// colors from 0 to 7: red, orange, yellow, green, cyan, blue, purple
color[] lightestColors = {color(255,170,170), color(255,219,170), color(255,240,170), color(232,246,164), color(136,204,136), color(113,142,164), color(136,124,175), color(166,111,166)};
color[] lightColors = {color(212,106,106), color(212,167,106), color(212,194,106), color(188,205,103), color(85,170,85), color(73,109,137), color(97,81,146), color(138,69,138)};
color[] medColors = {color(170,57,57), color(170,121,57), color(170,151,57), color(145,164,55), color(45,136,45), color(41,80,109), color(64,48,117), color(111,37,111)};
color[] darkColors = {color(128,21,21), color(128,82,21), color(128,109,21), color(106,123,21), color(17,102,17), color(18,54,82), color(38,23,88), color(83,14,83)};
color[] darkestColors = {color(85,0,0), color(85,49,0), color(85,70,0), color(68,82,0), color(0,68,0), color(4,32,55), color(19,7,58), color(55,0,55)};

// how often color change is occurring
float dt = 0.2; // increase dt to make animation go faster
float phaseDuration = 50;
float seconds = 0;
boolean triggerChange = false;


void setup() {
  //size(1300, 1000);
  fullScreen();
  
  createLineDimensions(lineStates, maxLines);

  // set initial rectangle colors
  loadPixels();
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
      int k = j*width + i;
      pixels[k] = getBackgroundColor(i, j, 0);
    }
  }
  updatePixels();
}

void draw() {
  int ms = millis(); // get the milliseconds that have passed since run
  
  // trigger a change every second
  if (floor(ms / int(1000*dt)) > seconds) {
    seconds = floor(ms / int(1000*dt));
    triggerChange = true;
  }
  
  // change colors on every trigger
  if (triggerChange) {
    println(seconds);
    
    // calculate current color change state step
    int currState = floor(seconds / phaseDuration);
    if (currState >= numRectStates) currState = numRectStates - 1;
    
    // calculate interpolation coefficient for color
    float timePerc = (seconds % phaseDuration) / phaseDuration;
    
    loadPixels();
    
    // paint background
    for (int j = 0; j < height; j++) {
      for (int i = 0; i < width; i++) {
        int k = j*width + i;
        float[] rectDim = getRectDim(i, j);
        color oldColor = getBackgroundColor(i, j, currState);
        color newColor = getBackgroundColor(i, j, currState + 1);
        pixels[k] = lerpColor(oldColor, newColor, timePerc);
      }
    }
    
    // paint the lines
    float lineTimePerc = cos(2*PI*seconds/phaseDuration);
    int[][] allLineDims = lineDimCollection[currState % maxLines];
    for (int l = 0; l < allLineDims.length; l++) {
      int[] lineDims = allLineDims[l];
      if (lineDims[0] == X_AXIS) {
        for (int i = 0; i < width; i++) {
          int k = lineDims[1]*width + i;
          
          // get next state color
          color newColor = getBackgroundColor(i, lineDims[1], currState + 1);
          
          // change color to incorporate line
          color transColor = lerpColor(lineColor, newColor, lineTimePerc); 
          pixels[k] = transColor;
          pixels[k + width*lineDims[2]] = transColor;
        }
      } else if (lineDims[0] == Y_AXIS) {
        for (int j = 0; j < height; j++) {
          int k = j*width + lineDims[1];
          
          // get next state color
          color newColor = getBackgroundColor(lineDims[1], j, currState + 1);
          
          // change color to incorporate line
          color transColor = lerpColor(lineColor, newColor, lineTimePerc); 
          pixels[k] = transColor;
          pixels[k + lineDims[2]] = transColor;
        }
      }
    }
    
    updatePixels();
    
    // reset trigger change
    triggerChange = false;
  }
}

/* -------------------------------------- Getter Functions ---------------------------------- */
color getBackgroundColor(int x, int y, int state) {
  float[] rectDim = getRectDim(x, y);
  float rectNum = rectDim[0];
  float xPerc = rectDim[1];
  float yPerc = rectDim[2];
  if (rectNum == 1) {
    if (state == 0) return lerpColor(lightestColors[0], darkestColors[0], yPerc);
    else if (state == 1) return lerpColor(lightestColors[1], darkestColors[1], xPerc);
    else if (state == 2) return lerpColor(lightestColors[2], darkestColors[3], yPerc);
    else if (state == 3) return lerpColor(lightColors[2], darkColors[3], yPerc);
    else if (state == 4) return lerpColor(lightestColors[2], medColors[3], yPerc);
    else if (state == 5) return lerpColor(lightestColors[5], lightColors[4], yPerc);
    else if (state == 6) return lerpColor(lightColors[6], medColors[3], yPerc);
  } else if (rectNum == 2) {
    if (state == 0) return lerpColor(darkestColors[0], lightestColors[4], yPerc);
    else if (state == 1) return lerpColor(darkestColors[3], lightestColors[3], xPerc);
    else if (state == 2) return lerpColor(darkestColors[3], lightColors[4], yPerc);
    else if (state == 3) return lerpColor(darkColors[3], medColors[3], yPerc);
    else if (state == 4) return lerpColor(medColors[3], darkColors[3], yPerc);
    else if (state == 5) return lerpColor(lightColors[4], medColors[3], yPerc);
    else if (state == 6) return lerpColor(medColors[3], darkColors[2], yPerc);
  } else if (rectNum == 3) {
    if (state == 0) return lerpColor(lightestColors[4], darkestColors[5], yPerc);
    else if (state == 1) return lerpColor(lightestColors[6], darkestColors[6], xPerc); 
    else if (state == 2) return lerpColor(lightColors[4], darkestColors[0], yPerc);
    else if (state == 3) return lerpColor(medColors[3], darkColors[3], yPerc);
    else if (state == 4) return lerpColor(darkColors[3], darkestColors[3], yPerc);
    else if (state == 5) return lerpColor(medColors[3], darkColors[1], yPerc);
    else if (state == 6) return lerpColor(darkColors[2], darkestColors[0], yPerc);
  }
  return color(0, 0, 0);
}

float[] getRectDim(int x, int y) {
  float rectNum = -1, xPerc = -1, yPerc = -1;
  if ((x >= rectOneX && x <= rectOneX + rectOneWidth) && (y >= rectOneY && y <= rectOneY + rectOneHeight)) {
    rectNum = 1;
    xPerc = (x - rectOneX) / rectOneWidth;
    yPerc = (y - rectOneY) / rectOneHeight;
  } else if ((x >= rectTwoX && x <= rectTwoX + rectTwoWidth) && (y >= rectTwoY && y <= rectTwoY + rectTwoHeight)) {
    rectNum = 2;
    xPerc = (x - rectTwoX) / rectTwoWidth;
    yPerc = (y - rectTwoY) / rectTwoHeight;
  } else if ((x >= rectThrX && x <= rectThrX + rectThrWidth) && (y >= rectThrY && y <= rectThrY + rectThrHeight)) {
    rectNum = 3;
    xPerc = (x - rectThrX) / rectThrWidth;
    yPerc = (y - rectThrY) / rectThrHeight;
  }
  float[] returnArray = {rectNum, xPerc, yPerc};
  return returnArray;
}

void createLineDimensions(int numStates, int maxLines) {
  lineDimCollection = new int[numStates][maxLines][3]; // axis, coordinate, distance
  for (int i = 0; i < numStates; i++) {
    for (int j = 0; j < maxLines; j++) {
      int axis = int(random(2)) + 1;
      lineDimCollection[i][j][0] = axis;
      if (axis == X_AXIS) {
        int coord = int(random(height - maxLineDistance));
        lineDimCollection[i][j][1] = coord;
      } else if (axis == Y_AXIS) {
        lineDimCollection[i][j][1] = int(random(width - maxLineDistance));
      }
      lineDimCollection[i][j][2] = int(random(maxLineDistance));
    }
  }
}