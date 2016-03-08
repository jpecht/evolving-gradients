import java.util.Arrays; //<>//

// Constants
int Y_AXIS = 1;
int X_AXIS = 2;

// color palettes
color[] lowtemp = {color(157,20,25), color(159,33,42), color(127,44,63), color(103,47,75), color(95,57,95), color(82,56,101), color(70,60,114), color(51,60,121), color(47,63,128)};
color[] lowtempCool = Arrays.copyOfRange(lowtemp, 4, lowtemp.length);

// secondary color palettes (d3.category20b)
color[] secBlue = {color(57,59,121),color(82,84,163),color(107,110,207),color(156,158,222)};
color[] secGreen = {color(99,121,57),color(140,162,82),color(181,207,107),color(206,219,156)};
color[] secYellow = {color(140,109,49),color(189,158,57),color(231,186,82),color(231,203,148)};
color[] secRed = {color(132,60,57),color(173,73,74),color(214,97,107),color(231,150,156)};
color[] secPurple = {color(123,65,115),color(165,81,148),color(206,109,189),color(222,158,214)};

// custom color palettes (darker, grayer)
color[] midPurple = {color(77,72,102),color(72,55,98),color(66,59,95),color(59,52,89),color(54,45,90)};
color[] midBlue = {color(70,78,99),color(63,72,96),color(57,67,92),color(50,60,87),color(44,55,88)};
color[] midCerulean = {color(63,84,92),color(57,80,89),color(51,76,86),color(44,71,81),color(37,70,82)};
color[] midBlend = combineColorArrays(midCerulean, combineColorArrays(midPurple, midBlue));

// custom color palettes (lighter, grayer)
color[] lightPurple = {color(108,102,137),color(97,89,133),color(87,77,128),color(76,65,125),color(67,55,123)};
color[] lightBlue = {color(99,108,134),color(86,98,129),color(75,88,125),color(63,79,122),color(53,71,120)}; 
color[] lightCerulean = {color(89,115,125),color(77,109,120),color(66,103,117),color(54,97,114),color(44,93,112)};
color[] lightBlend = combineColorArrays(lightCerulean, combineColorArrays(lightPurple, lightBlue));

color[] blendColors = combineColorArrays(lowtempCool,midBlend);


// rectangle dimensions
float rectOneX = 0, rectOneY, rectOneWidth, rectOneHeight;
float rectTwoX = 0, rectTwoY, rectTwoWidth, rectTwoHeight;
float rectThrX = 0, rectThrY, rectThrWidth, rectThrHeight;

// line dimensions
int[][][] lineDimCollection;
int lineShapeStates = 30;
int maxLines = 5;
int minLineDistance = 10, maxLineDistance = 65;
int maxLineMoveDistance = 10;
color lineColor = color(50, 50, 50);

// shape dimensions
int[][][] shapeDimCollection;
int maxShapes = 5; // number of shapes to be displayed on screen at a time
int minShapeSize = 20, maxShapeSize = 100; // diameter of shapes
int maxShapeGrowth = 0;
String[] shapeTypes = {"circle", "square"};
color[][] shapeColors = {lowtempCool, blendColors};
color shapeBorderColor = color(50, 50, 50);

// how often color change is occurring
float dt = 0.2; // how often the change is processed, decrease for more resolution
float phaseDuration = (0.2*60/dt); // transitions will be at every (phaseDuration*dt) seconds
float seconds = 0;
boolean triggerChange = false;
int colorStates = 10;


void setup() {
  //size(1300, 1000);
  fullScreen();
  
  // set up rectangle dimensions
  rectOneY = 0; rectOneWidth = width; rectOneHeight = height/3;
  rectTwoY = height/3; rectTwoWidth = width; rectTwoHeight = height/3;
  rectThrY = 2*height/3; rectThrWidth = width; rectThrHeight = height/3;
  
  // pre-configure all line and shape states
  createLineDimensions(lineShapeStates, maxLines);
  createShapeDimensions(lineShapeStates, maxShapes);

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
    int lineState = ceil(float(currState % lineShapeStates)/2);
    float sTimePerc = 0.5 + 0.5*cos(PI*seconds/phaseDuration);
    println("State #" + currState + ", lineState: " + lineState + ", timePerc: " + sTimePerc);

    
    // paint the lines
    int[][] allLineDims = lineDimCollection[lineState];
    for (int l = 0; l < allLineDims.length; l++) {
      int[] lineDims = allLineDims[l];
      //color nowLineColor = lerpColor(lineColor, lowtemp[lineDims[4]], sTimePerc);
      if (lineDims[0] == X_AXIS) {
        for (int i = 0; i < width; i++) {
          int k = (lineDims[1])*width + i;
          int movement = int((1-sTimePerc)*lineDims[3]);
          color transColor = lerpColor(pixels[k], lineColor, sTimePerc);
          pixels[k - movement*width] = transColor;
          pixels[k + width*lineDims[2]] = transColor;
        }
      } else if (lineDims[0] == Y_AXIS) {
        for (int j = 0; j < height; j++) {
          int k = j*width + lineDims[1];          
          int movement = int((1-sTimePerc)*lineDims[3]);
          color transColor = lerpColor(pixels[k], lineColor, sTimePerc);
          pixels[k - movement] = transColor;
          pixels[k + lineDims[2]] = transColor;
        }
      }
    }
    
    // paint the shapes
    int[][] allShapeDims = shapeDimCollection[lineState % shapeDimCollection.length];
  // shapetype, x coord, y coord, distance, distance-movement, color-index, lerp-index
    color[] shapeColorPalette = shapeColors[lineState % shapeColors.length];
    for (int l = 0; l < allShapeDims.length; l++) {
      int[] shapeDims = allShapeDims[l];
      String shapeType = shapeTypes[shapeDims[0]];
      
      int dim = shapeDims[3];
      float dimDistance = lerp(0, shapeDims[4], sTimePerc);
      dim += dimDistance;
      
      if (shapeType == "circle") {
        int radius = dim / 2;
        int cx = shapeDims[1] + radius;
        int cy = shapeDims[2] + radius;
        for (int y = cy-radius; y <= cy+radius; y++) {
          float dy = float(y-cy) / radius;
          float theta = asin(dy);
          int xr = int(radius * cos(theta));
          for (int x = cx-xr; x <= cx+xr; x++) {
            int k = y*width + x;
            
            // recalculate existing color (may be a line color causing lines to be in front)
            color oldColor = getBackgroundColor(x, y, currState);
            color newColor = getBackgroundColor(x, y, currState + 1);
            color transColor = lerpColor(oldColor, newColor, timePerc);
            
            // calculate if on border
            color shapeColor = lerpColor(shapeColorPalette[shapeDims[5]], shapeColorPalette[shapeDims[5]+1], float(shapeDims[6])/100);
            if (x == cx-xr || x == cx+xr) shapeColor = shapeBorderColor;
            
            pixels[k] = lerpColor(transColor, shapeColor, sTimePerc);
          }
        }
      } else if (shapeType == "square") {
        int x = shapeDims[1];
        int y = shapeDims[2];
        for (int dx = 0; dx < dim; dx++) {
          for (int dy = 0; dy < dim; dy++) {
            // interpolate colors
            int k = (y+dy)*width + (x+dx);
            
            // recalculate existing color (may be a line color causing lines to be in front)
            color oldColor = getBackgroundColor(x+dx, y+dy, currState);
            color newColor = getBackgroundColor(x+dx, y+dy, currState + 1);
            color transColor = lerpColor(oldColor, newColor, timePerc);
            
            // calculate if on border
            color shapeColor = lerpColor(shapeColorPalette[shapeDims[5]], shapeColorPalette[shapeDims[5]+1], float(shapeDims[6])/100);
            if (dx == 0 || dx == dim-1 || dy == 0 || dy == dim-1) shapeColor = shapeBorderColor;
            
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
    if (state == 0 || state == 10) return lerpColor(lowtemp[1], lowtemp[3], yPerc); // rough
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
    else if (state == 7) return lerpColor(secBlue[2], secPurple[2], yPerc);
    else if (state == 8) return lerpColor(secYellow[3], secGreen[2], yPerc);
    else if (state == 9) return lerpColor(secRed[1], secRed[1], yPerc);
  } else if (rectNum == 3) {
    if (state == 0 || state == 10) return lerpColor(lowtemp[5], lowtemp[8], yPerc);
    else if (state == 1) return lerpColor(secPurple[1], secPurple[0], yPerc); 
    else if (state == 2) return lerpColor(secRed[3], secRed[1], yPerc);
    else if (state == 3) return lerpColor(secGreen[3], secGreen[2], yPerc);
    else if (state == 4) return lerpColor(secRed[3], secRed[1], yPerc);
    else if (state == 5) return lerpColor(secRed[2], secRed[3], yPerc);
    else if (state == 6) return lerpColor(lowtemp[2], lowtemp[1], yPerc);
    else if (state == 7) return lerpColor(secPurple[2], secPurple[1], yPerc);
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
      if (j == maxLines - 1) axis = 3 - lineDimCollection[i][0][0]; // to prevent all lines in same direction
      lineDimCollection[i][j][0] = axis;
      int distance = int(random(minLineDistance, maxLineDistance));
      int movement = int(random(maxLineMoveDistance));
      if (axis == X_AXIS) {
        // range is from 0 to height
        lineDimCollection[i][j][1] = int(movement + random(height-distance-movement));
      } else if (axis == Y_AXIS) {
        // range is from movement to width
        lineDimCollection[i][j][1] = int(movement + random(width-distance-movement));
      }
      lineDimCollection[i][j][2] = distance;
      lineDimCollection[i][j][3] = movement;
      lineDimCollection[i][j][4] = int(random(lowtemp.length));
    }
  }
}

void createShapeDimensions(int numStates, int maxShapes) {
  // shapetype, x coord, y coord, distance, distance-movement, color-index, lerp-index
  shapeDimCollection = new int[numStates][maxShapes][7];
  for (int i = 0; i < numStates; i++) {
    for (int j = 0; j < maxShapes; j++) {
      shapeDimCollection[i][j][0] = int(random(shapeTypes.length)); // shape type
      int distance = int(random(minShapeSize, maxShapeSize));
      shapeDimCollection[i][j][1] = int(random(width - distance));
      shapeDimCollection[i][j][2] = int(random(height - distance));
      shapeDimCollection[i][j][3] = distance;
      shapeDimCollection[i][j][4] = int(random(2*maxShapeGrowth) - maxShapeGrowth);
      shapeDimCollection[i][j][5] = int(random(shapeColors[i % shapeColors.length].length - 1));
      shapeDimCollection[i][j][6] = int(random(0, 100));
    }
  }
}

color[] combineColorArrays(color[] array1, color[] array2) {
  color[] resultColors = new color[array1.length + array2.length];
  for (int i = 0; i < resultColors.length; i++) {
    if (i < array1.length) resultColors[i] = array1[i];
    else resultColors[i] = array2[i - array1.length];
  }
  return resultColors;
}