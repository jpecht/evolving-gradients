// Constants //<>//
int Y_AXIS = 1;
int X_AXIS = 2;

// colors from 0 to 7: red, orange, yellow, green, cyan, blue, purple
color[] lightestColors = {color(255,170,170), color(255,219,170), color(255,240,170), color(232,246,164), color(136,204,136), color(113,142,164), color(136,124,175), color(166,111,166)};
color[] lightColors = {color(212,106,106), color(212,167,106), color(212,194,106), color(188,205,103), color(85,170,85), color(73,109,137), color(97,81,146), color(138,69,138)};
color[] medColors = {color(170,57,57), color(170,121,57), color(170,151,57), color(145,164,55), color(45,136,45), color(41,80,109), color(64,48,117), color(111,37,111)};
color[] darkColors = {color(128,21,21), color(128,82,21), color(128,109,21), color(106,123,21), color(17,102,17), color(18,54,82), color(38,23,88), color(83,14,83)};
color[] darkestColors = {color(85,0,0), color(85,49,0), color(85,70,0), color(68,82,0), color(0,68,0), color(4,32,55), color(19,7,58), color(55,0,55)};

// color palettes
color[] lowtemp = {color(157,20,25), color(159,33,42), color(127,44,63), color(103,47,75), color(95,57,95), color(82,56,101), color(70,60,114), color(51,60,121), color(47,63,128)};

// primary color palettes (d3.category20c)
color[] primPurple = {color(117,107,177),color(158,154,200),color(188,189,220),color(218,218,235)};
color[] primGreen = {color(49,163,84),color(116,196,118),color(161,217,155),color(199,233,192)};
color[] primOrange = {color(230,85,13),color(253,141,60),color(253,174,107),color(253,208,162)};
color[] primBlue = {color(49,130,189),color(107,174,214),color(158,202,225),color(198,219,239)};
color[] primGray = {color(99,99,99),color(150,150,150),color(189,189,189),color(217,217,217)};

// secondary color palettes (d3.category20b)
color[] secBlue = {color(57,59,121),color(82,84,163),color(107,110,207),color(156,158,222)};
color[] secGreen = {color(99,121,57),color(140,162,82),color(181,207,107),color(206,219,156)};
color[] secYellow = {color(140,109,49),color(189,158,57),color(231,186,82),color(231,203,148)};
color[] secRed = {color(132,60,57),color(173,73,74),color(214,97,107),color(231,150,156)};
color[] secPurple = {color(123,65,115),color(165,81,148),color(206,109,189),color(222,158,214)};

// rectangle dimensions
float rectOneX = 0, rectOneY = 0;
float rectOneWidth = 1300, rectOneHeight = height/3;
float rectTwoX = 0, rectTwoY = 300;
float rectTwoWidth = 1300, rectTwoHeight = 400;
float rectThrX = 0, rectThrY = 700;
float rectThrWidth = 1300, rectThrHeight = 300;

// line dimensions
int[][][] lineDimCollection;
int lineStates = 20;
int maxLines = 5;
int minLineDistance = 10, maxLineDistance = 50;
int maxLineMoveDistance = 10;
color lineColor = color(50, 50, 50);

// shape dimensions
int[][][] shapeDimCollection;
int shapeStates = 30;
int maxShapes = 5;
int maxShapeSize = 100;
String[] shapeTypes = {"circle", "square"};
color[][] shapeColors = {lowtemp, secPurple, lowtemp, secYellow, lowtemp};

// how often color change is occurring
float dt = 0.2; // how often the change is processed, decrease for more resolution
float phaseDuration = (5*60/dt); // transitions will be at every (phaseDuration*dt) seconds
float seconds = 0;
boolean triggerChange = false;
int colorStates = 10;


void setup() {
  //size(1300, 1000);
  fullScreen();
  
  // set up rectangle dimensions
  rectOneWidth = width; rectOneHeight = height/3;
  rectTwoWidth = width; rectTwoHeight = height/3;
  rectThrWidth = width; rectThrHeight = height/3;
  rectTwoY = height/3; rectThrY = 2*height/3;
  
  // pre-configure all line and shape states
  createLineDimensions(lineStates, maxLines);
  createShapeDimensions(shapeStates, maxShapes);

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
    // calculate current color change state step
    int currState = floor(seconds / phaseDuration);
    currState = currState % colorStates;
        
    // calculate interpolation coefficient for background color
    float timePerc = (seconds % phaseDuration) / phaseDuration;
    
    loadPixels();
    
    // paint background
    for (int j = 0; j < height; j++) {
      for (int i = 0; i < width; i++) {
        int k = j*width + i;
        color oldColor = getBackgroundColor(i, j, currState);
        color newColor = getBackgroundColor(i, j, currState + 1);
        pixels[k] = lerpColor(oldColor, newColor, timePerc);
      }
    }
    
    // calculate interpolation coefficient for line and shape color
    float sTimePerc = 0.5 + 0.5*cos(PI*seconds/phaseDuration);
    println("State #" + currState + ", timePerc: " + sTimePerc);

    
    // paint the lines
    int[][] allLineDims = lineDimCollection[ceil(float(currState % maxLines)/2)];
    for (int l = 0; l < allLineDims.length; l++) {
      int[] lineDims = allLineDims[l];
      //color nowLineColor = lerpColor(lineColor, lowtemp[lineDims[4]], sTimePerc);
      if (lineDims[0] == X_AXIS) {
        for (int i = 0; i < width; i++) {
          int k = (lineDims[1])*width + i;
          color transColor = lerpColor(pixels[k], lineColor, sTimePerc);
          pixels[k - int((1-sTimePerc)*lineDims[3])*width] = transColor;
          pixels[k + width*lineDims[2]] = transColor;
        }
      } else if (lineDims[0] == Y_AXIS) {
        for (int j = 0; j < height; j++) {
          int k = j*width + lineDims[1];          
          color transColor = lerpColor(pixels[k], lineColor, sTimePerc);          
          pixels[k - int((1-sTimePerc)*lineDims[3])] = transColor;
          pixels[k + lineDims[2]] = transColor;
        }
      }
    }
    
    // paint the shapes
    int shapeCollectionIndex = ceil(float(currState)/2) % shapeDimCollection.length;
    int[][] allShapeDims = shapeDimCollection[shapeCollectionIndex];
    for (int l = 0; l < allShapeDims.length; l++) {
      int[] shapeDims = allShapeDims[l];
      //String shapeType = shapeTypes[shapeDims[0]];
      String shapeType = "square";
      if (shapeType == "circle") {
        int radius = shapeDims[3] / 2;
        int cx = shapeDims[1] + radius;
        int cy = shapeDims[2] + radius;
        color[] shapeColorPalette = shapeColors[currState % shapeColors.length];
        if (shapeDims[4] >= shapeColorPalette.length) shapeDims[4] = shapeColorPalette.length - 1;
        color shapeColor = shapeColorPalette[shapeDims[4]];
        
        for (float deg = 90; deg < 270; deg += 0.25) {
          int x1 = int(cx + radius * cos(deg));
          int x2 = int(cx + radius * abs(cos(deg)));
          int y = int(cy + radius * sin(deg));
          for (int x = x1; x <= x2; x++) {
            int k = y*width + x;
            pixels[k] = lerpColor(pixels[k], shapeColor, sTimePerc);
          }
        }
      } else if (shapeType == "square") {
        int x = shapeDims[1];
        int y = shapeDims[2];
        int dim = shapeDims[3];
        color shapeColor = lowtemp[shapeDims[4]];
        for (int dx = 0; dx < dim; dx++) {
          for (int dy = 0; dy < dim; dy++) {
            // interpolate colors
            int k = (y+dy)*width + (x+dx);
            color oldColor = getBackgroundColor(x+dx, y+dy, currState);
            color newColor = getBackgroundColor(x+dx, y+dy, currState + 1);
            color transColor = lerpColor(oldColor, newColor, timePerc);
            pixels[k] = lerpColor(transColor, shapeColor, sTimePerc);
          }
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
    if (state == 0 || state == 10) return lerpColor(lowtemp[0], lowtemp[3], yPerc); // rough
    else if (state == 1) return lerpColor(secPurple[1], secPurple[2], yPerc); // smooth
    else if (state == 2) return lerpColor(secBlue[1], secBlue[3], yPerc); // rough
    else if (state == 3) return lerpColor(secGreen[2], secGreen[3], yPerc); // smooth
    else if (state == 4) return lerpColor(secYellow[1], secYellow[3], yPerc); // rough
    else if (state == 5) return lerpColor(secRed[0], secRed[1], yPerc); // smooth
    else if (state == 6) return lerpColor(lowtemp[6], lowtemp[4], yPerc); // rough
    else if (state == 7) return lerpColor(secBlue[3], secBlue[2], yPerc); // smooth
    else if (state == 8) return lerpColor(secYellow[0], secYellow[3], yPerc); // rough
    else if (state == 9) return lerpColor(secRed[2], secRed[1], yPerc); // smooth
  } else if (rectNum == 2) {
    if (state == 0 || state == 10) return lerpColor(lowtemp[3], lowtemp[5], yPerc);
    else if (state == 1) return lerpColor(secPurple[2], secPurple[1], yPerc);
    else if (state == 2) return lerpColor(secBlue[3], secRed[3], yPerc);
    else if (state == 3) return lerpColor(secGreen[3], secGreen[3], yPerc);
    else if (state == 4) return lerpColor(secYellow[3], secRed[3], yPerc);
    else if (state == 5) return lerpColor(secRed[1], secRed[2], yPerc);
    else if (state == 6) return lerpColor(lowtemp[4], lowtemp[2], yPerc);
    else if (state == 7) return lerpColor(secBlue[2], secPurple[1], yPerc);
    else if (state == 8) return lerpColor(secYellow[3], secGreen[2], yPerc);
    else if (state == 9) return lerpColor(secRed[1], secRed[1], yPerc);
  } else if (rectNum == 3) {
    if (state == 0 || state == 10) return lerpColor(lowtemp[5], lowtemp[8], yPerc);
    else if (state == 1) return lerpColor(secPurple[1], secPurple[0], yPerc); 
    else if (state == 2) return lerpColor(secRed[3], secRed[1], yPerc);
    else if (state == 3) return lerpColor(secGreen[3], secGreen[2], yPerc);
    else if (state == 4) return lerpColor(secRed[3], secRed[1], yPerc);
    else if (state == 5) return lerpColor(secRed[2], secRed[3], yPerc);
    else if (state == 6) return lerpColor(lowtemp[2], lowtemp[0], yPerc);
    else if (state == 7) return lerpColor(secPurple[1], secPurple[0], yPerc);
    else if (state == 8) return lerpColor(secGreen[2], secBlue[1], yPerc);
    else if (state == 9) return lerpColor(secRed[1], secRed[2], yPerc);
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
  lineDimCollection = new int[numStates][maxLines][5]; // axis, coordinate, distance, firstlinemovement, color index
  for (int i = 0; i < numStates; i++) {
    for (int j = 0; j < maxLines; j++) {
      int axis = int(random(2)) + 1;
      lineDimCollection[i][j][0] = axis;
      int distance = int(random(minLineDistance, maxLineDistance));
      int movement = int(random(maxLineMoveDistance));
      if (axis == X_AXIS) {
        int coord = int(random(height - distance));
        lineDimCollection[i][j][1] = coord;
      } else if (axis == Y_AXIS) {
        lineDimCollection[i][j][1] = int(movement + random(width-distance-movement));
      }
      lineDimCollection[i][j][2] = distance;
      lineDimCollection[i][j][3] = movement;
      lineDimCollection[i][j][4] = int(random(lowtemp.length));
    }
  }
}

void createShapeDimensions(int numStates, int maxShapes) {
  shapeDimCollection = new int[numStates][maxShapes][5]; // shapetype, x coord, y coord, distance, color index
  for (int i = 0; i < numStates; i++) {
    for (int j = 0; j < maxShapes; j++) {
      shapeDimCollection[i][j][0] = int(random(shapeTypes.length)); // shape type
      int distance = int(random(maxShapeSize));
      shapeDimCollection[i][j][1] = int(random(width - distance));
      shapeDimCollection[i][j][2] = int(random(height - distance));
      shapeDimCollection[i][j][3] = distance;
      shapeDimCollection[i][j][4] = int(random(shapeColors[i % shapeColors.length].length));
    }
  }
}