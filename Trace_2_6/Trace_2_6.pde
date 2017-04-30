// Trace
// By Daniel Winker, using peasycam by Jonathan Feinberg and controlP5 by Andreas Schlegel

// Trace is a multi-dimensional real-time data plotter made for real world data
// Up to 8D - x, y, z, color (as grayscale, or r, g, and or b), alpha, line thickness

// Data is sent from some device over serial (USB) in a CSV format. (Or, select another data source? How about some audio)
// Between commas, there must only be numbers, decimal points, and whitespace. The numbers cannot have whitespace within them.
// A given line can have any number of measurements, which can be plotted in various ways.
// Measurements can be plotted against eachother and/or time in 5 dimensions
//    -Vertical, Horizontal, Depth (up and down (y), left and right(x), and in and out of the screen(z))
//    -Point Size or Line Thickness
//    -Color
// Measurements can be displayed on screen and simultaneously stored in a text file.
// Any given trace seen on screen - a trace being a collection of points associated with a group of 1 or more measurements - is stored in a LinkedList (internal to the Trace class).
// All of the Traces are stored in an ArrayList

// Start on a setup screen
// Read in measurements, tell the user how many there are, display the current values for each measurement (in order), include time
// Have a 'new trace' button
// Select the dimensions (vertical, horizontal, depth, color, line thickness)
// Associate 1 measurement with each dimension
// Ask for trace length if relevant
// Have quick setup options, like always offer individual plots vs time, if there are 3 measurements offer 3D plotting, 2 measurements offer 2D XY plotting

import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;
import processing.serial.*; // For reading serial data
import java.util.*;

// I sure do love global variables.

int dbgCounter = 0; //Debug

PFont defaultFont; // Declare PFont variable
Serial mySerial; // Serial object for reading from the port
PrintWriter output; // For writing to a text file
String serialMessage = "Hi!"; // Text displayed on the GUI
String debugText = "Hi.";
int lf = 10; // ASCII linefeed (newline)
boolean messageFlag = false; // Is there a new serial message?
ArrayList<Trace> traces = new ArrayList<Trace>(); // This will hold the LinkedLists of traces
int speed = 7; // How fast do we scroll/stretch the signal?
int page = 0; // Used to select which page of the GUI is shown
int numMeasurements; // The number of measurements in the most recent bunch of serial data
boolean measurementFlag; // Indicate whether or not there are new measurements
float[] measurements; // The newest measurements from serial, scaled to be between 0 and 1
String[] dimensionOptions = {"X","Grayscale","Y","","Z","Red","Thickness","Green","Alpha","Blue"};
int defaultTraceLength; // The default number of points to display on screen
ArrayList<Integer> xTimeDim = new ArrayList<Integer>(); // Holds the 'measurements' for the 'time' dimension along the X axis
ArrayList<Integer> yTimeDim = new ArrayList<Integer>(); // Holds the 'measurements' for the 'time' dimension along the Y axis
ArrayList<Integer> zTimeDim = new ArrayList<Integer>(); // Holds the 'measurements' for the 'time' dimension along the Z axis

// Variables for the axes
boolean xAxisOn = true; // By default, the axes are turned on
boolean yAxisOn = true; // By default, the axes are turned on
boolean zAxisOn = true; // By default, the axes are turned on
int axisTickSpacing = 100; // How far apart are tick marks on the axes?
int axesRed = 0;
int axesGreen = 0;
int axesBlue = 0;
int axesAlpha = 100; // Full opacity
int axesThickness = 2;
int oldWidth;
int oldHeight;

static final int MAX_DIMENSIONS = 10; // The number of dimensions available for plotting

// The 5 dimensions for display, plus any extra modes
static final int X_DIM = 0;
static final int GRAYSCALE = 1;
static final int Y_DIM = 2;
static final int BLANK = 3;
static final int Z_DIM = 4;
static final int RED = 5;
static final int THICKNESS = 6;
static final int GREEN = 7;
static final int ALPHA = 8;
static final int BLUE = 9;
static final int FFT = 10;
// The different pages of the GUI
static final int TRACE_DISPLAY = 0;
static final int SETUP_DISPLAY = 1;
static final int setupDisplayBckgndColor = 155;
// Default values for each dimension, {"X","Grayscale","Y","BLANK","Z","Red","Thickness","Green","Alpha","Blue"}
static final int[] DEFAULT_VALUES = {0, 150, 0, 100, 0, 0, 3, 0, 255, 0};
static final int DEFAULT_COLOR_FORMAT = BLANK;
static int NORMALIZATION_PARAM = 3300; // The largest value that might get passed in
static int[] SCALING_FACTORS = {100, 255, 100, #FFFFFF, 2000, 255, 55, 255, 255, 255}; // The maximum value that each dimension can display

int bckgndColor = 175; // Background color


void setup() {
  page = SETUP_DISPLAY; // Start on this page
  size(1200, 600, P3D); // Set up GUI, width and height, create a 3D space
  perspective(PI/3.0, width/height, ((height/2.0) / tan(PI*60.0/360.0))/10.0, ((height/2.0) / tan(PI*60.0/360.0)) * 100.0); // Extend draw distance
  surface.setResizable(true);
  stroke(150, 150, 50); // Color for drawing lines
  defaultFont = createFont("Arial",20,true); // Arial, 18 point, anti-aliasing on
  initializeCamera();
  if (page == SETUP_DISPLAY) { // The screen where you can create new traces and determine how data will be organized.
    bckgndColor = setupDisplayBckgndColor;
    setupDisplay(); // Everything you need to create traces
  }
  defaultTraceLength = width; // Show a trace from end to end; this makes sense.
  SCALING_FACTORS[X_DIM] = int(1.0 * width); // Allow X measurements to use the full extent of the screen's width
  SCALING_FACTORS[Y_DIM] = int(1.0 * height); // Allow Y measurements to use the full extent of the screen's height
  SCALING_FACTORS[Z_DIM] = SCALING_FACTORS[Y_DIM]; // Arbitrary decision for the Z dimension
  setTimeDimSpeed(X_DIM, speed); // Set up the 'time' dimension for the X axis
  setTimeDimSpeed(Y_DIM, speed); // Set up the 'time' dimension for the Y axis
  setTimeDimSpeed(Z_DIM, speed); // Set up the 'time' dimension for the Z axis
  screenResized(); // The screen has gone from not existing to existing - there are things to take care of.
}

// Sets the values in the appropriate time-dimension arraylist such that data can appropriately displayed
// at the desired 'speed' (spacing)
void setTimeDimSpeed(int whichDim, int whatSpeed) {
  if (whichDim == X_DIM) {
    xTimeDim.clear(); // Empty out the list
    for (int i = 0; i <= SCALING_FACTORS[X_DIM]; i += whatSpeed) { // Populate the list
      xTimeDim.add(i);
    }    
  } else if (whichDim == Y_DIM) {
    yTimeDim.clear(); // Empty out the list
    for (int i = 0; i <= SCALING_FACTORS[Y_DIM]; i += whatSpeed) { // Populate the list
      yTimeDim.add(i);
    }
  } else if (whichDim == Z_DIM) {
    zTimeDim.clear(); // Empty out the list
    for (int i = 0; i <= SCALING_FACTORS[Z_DIM]; i += whatSpeed) { // Populate the list
      zTimeDim.add(i);
    }
  }
  // If any of these arraylist's lengths have changed, then any trace's using 'time' measurements will need to correct their lengths
  for (Trace t : traces) { // Loop through all of the traces, correcting legnths
    t.correctLength();
  }
}

// Changes the upper limit on the desired axis (X, Y, or Z)
// Ensures tracelengths are updated as needed, as well as time-arrays, etc.
void setAxisLimit(int whichAxis, int newLimit) {
  SCALING_FACTORS[whichAxis] = newLimit;
  setTimeDimSpeed(whichAxis, speed); // This will adjust the 'time' lists for us; also handles traces using 'time'
  println("Adjusting axes"); // Debug
}

// Update anything that uses height and width
void screenResized() {
  traceDisplayCameraFocus[0] = width / 2;
  traceDisplayCameraFocus[1] = -height / 2;
  traceDisplayCameraFocus[2] = 0;
  camHandleScreenResize();
  perspective(PI/3.0, width/height, ((height/2.0) / tan(PI*60.0/360.0))/10.0, ((height/2.0) / tan(PI*60.0/360.0)) * 100.0); // Extend draw distance
}

void draw() {  
  if (dbgCounter++ > 100) { // Debug
    dbgCounter = 0; // Debug
    println("Here's where we're looking: " + cam.getLookAt()[0] + ", " + cam.getLookAt()[1] + ", " + cam.getLookAt()[2] + " with rotations: " + cam.getRotations()[0] + ", " + cam.getRotations()[1] + ", " + cam.getRotations()[2]); // Debug
  }
  guiManagement();
  if (page == TRACE_DISPLAY) { // The 'main' screen of the program. This is where the data is shown
    traceDisplay(); // Does everything necessary to display the main page 
  } else if (page == SETUP_DISPLAY) {
    drawSetup(); // Draws the SETUP_DISPLAY
    if (measurementFlag) {
      availableMeasurementsDisplay(measurements);
    }
  }
  // Handle screen resizing
  if (oldWidth != width || oldHeight != height) {
    println("Screen size " + oldWidth + ", " + oldHeight + " to " + width + ", " + height); // Debug
    screenResized(); 
    oldWidth = width;
    oldHeight = height;
  }
  parseSerial();
} // End draw() ----------------------------------------------------------------------------------------------------------------------------------------


// Called when bufferUntil reaches the 'until' (a newline, in the case of this code)
void serialEvent(Serial p) {
  serialMessage = p.readString(); // Store whatever message was sent
  messageFlag = true; // Indicate that we have a new message
}


// Take care of various GUI tasks (setup, colors, etc.) that have to be done for each frame
void guiManagement() {
  background(bckgndColor); // Create background and set background color
  textFont(defaultFont,36); // Font variable, font size override
  fill(0); // Specify color
  textAlign(LEFT); // Text alignment (L, R, C)
}

// Extract the measurements from the message sent
// Remove commas and whitespace, convert to integers
void parseSerial() {
 if (serialMessage != null && messageFlag) { // Did we really get something?
   messageFlag = false; // Note that we're using the message
   measurementFlag = true; // Indicate that there are new measurements
   String[] receivedSerial = split(serialMessage, ','); // Split the message on commas, store the substrings
   numMeasurements = receivedSerial.length;
   measurements = new float[numMeasurements]; // Well, we never actually declared this. Better do that before using it. Should probably replace this with either local vars only, or an arraylist
   // Loop through the data received, convert each number to an int, store in the measurements array
   for (int i = 0; i < numMeasurements; i++) {
     try {
         //measurements[i] = i;
         //Integer.parseInt(receivedSerial[i].trim());
         measurements[i] = float(receivedSerial[i].trim()) / NORMALIZATION_PARAM; // Remove whitespace, convert the string value to a float, and scale to be between 0 and 1
       } catch (Exception e) {
         measurementFlag = false; // Things didn't work out; don't use this message.
         println("Error converting string data to integer. Measurement " + i + " [" + receivedSerial[i].trim() + "]");
       }
   }
 }
}


// :: Pages ::
// The various different pages of the GUI
//
void traceDisplay() {    
  for (Trace t: traces) { // Loop through all of the traces
    if (measurementFlag) { // If there is a new measurement, then there's an update to be made
      t.update(); // Update the traces
    }
    t.drawTrace(); // Draw the traces
  }
  drawHUD();
  if(xAxisOn) {
    drawXAxis();
  }
  if (yAxisOn) {
    drawYAxis();
  }
  if (zAxisOn) {
    drawZAxis();
  }
}

// Everything that has to be done one time before switching to the Trace Display
void traceDisplaySetup() {
  println("Setting up Trace Display"); // Debug
  bckgndColor = traceDisplayBckgrnd;
  setupHUD();
}