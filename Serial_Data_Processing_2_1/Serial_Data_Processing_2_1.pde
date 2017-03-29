// Up to 8D - x, y, z, color (as grayscale, RGB, or r, g, and or b), alpha, line thickness

// Data is sent from some device over serial (USB) in a CSV format. (Or, select another data source? How bout some audioooooooo)
// Between commas, there must only be numbers, decimal points, and whitespace. The numbers cannot have whitespace within them.
// A given line can have any number of measurements, which can be plotted in various ways.
// Measurements can be plotted against eachother and/or time in 5 dimensions
//    -Vertical, Horizontal, Depth (up and down (y), left and right(x), and in and out of the screen(z))
//    -Point Size or Line Thickness
//    -Color
// Measurements can be displayed on screen and simultaneously stored in a text file.
// Any given trace seen on screen - a trace being a collection of points associated with a group of 1 or more measurements - is stored in a LinkedList.
// All of the LinkedLists - all of the traces - are stored in an ArrayList


// Start on a setup screen
// Read in measurements, tell the user how many there are, display the current values for each measurement (in order), include time
// Have a 'new trace' button
// Select dimensionality (1 to 5, or another option like FFT)
// Select the dimensions (vertical, horizontal, depth, color, line thickness)
// Associate 1 measurement with each dimension
// Ask for trace length if relevant
// Have quick setup options, like always offer individual plots vs time, if there are 3 measurements offer 3D plotting, 2 measurements offer 2D XY plotting

// Color provides options for a lot of different dimensions - black/white, RBG, separate R G and B values, as well as alpha - offering 1, 2, or up to 4 dimensions
// This might be pretty damn good for music visualization


// Add in a "Time" measurement option

import processing.serial.*; // For reading serial data
import java.util.*;

PFont f; // Declare PFont variable
float textX = 20; // X position of the text
float textY = 50; // Y position of the text
Serial mySerial; // Serial object for reading from the port
PrintWriter output; // For writing to a text file
String serialMessage = "Hi!"; // Text displayed on the GUI
String debugText = "Hi.";
int lf = 10;      // ASCII linefeed (newline)
int previousY = 0; // The previous measurement taken
int currentY = 0; // The most recent measurement
int strLen = 0; // Used for recording message length
boolean messageFlag = false; // Is there a new serial message?
ArrayList<Trace> traces = new ArrayList<Trace>(); // This will hold the LinkedLists of traces
int speed = 7; // How fast do we scroll/stretch the signal?
int page = 0; // Used to select which page of the GUI is shown
int numMeasurements; // The number of measurements in the most recent bunch of serial data
boolean measurementFlag; // Indicate whether or not there are new measurements
float[] measurements; // The newest measurements from serial, scaled to be between 0 and 1
String[] dimensionOptions = {"X","Grayscale","Y","RGB","Z","Red","Thickness","Green","Alpha","Blue"};
int defaultTraceLength; // The default number of points to display on screen
ArrayList<Integer> xTimeDim = new ArrayList<Integer>();; // Holds the 'measurements' for the 'time' dimension along the X axis
ArrayList<Integer> yTimeDim = new ArrayList<Integer>();; // Holds the 'measurements' for the 'time' dimension along the Y axis
ArrayList<Integer> zTimeDim = new ArrayList<Integer>();; // Holds the 'measurements' for the 'time' dimension along the Z axis

static final int MAX_DIMENSIONS = 10; // The number of dimensions available for plotting

// The 5 dimensions for display, plus any extra modes
static final int X_DIM = 0;
static final int GRAYSCALE = 1;
static final int Y_DIM = 2;
static final int RGB_COLOR = 3;
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
static final int SETTINGS_DISPLAY = 2; // Things like background color?
// Default values for each dimension, {"X","Grayscale","Y","RGB","Z","Red","Thickness","Green","Alpha","Blue"}
static final int[] DEFAULT_VALUES = {100, 150, 100, 100, 0, 0, 3, 0, 255, 0};
static final int DEFAULT_COLOR_FORMAT = GRAYSCALE;
static int MAX_INPUT = 3300; // The largest value that might get passed in
static int[] SCALING_FACTORS = {100, 255, 100, #FFFFFF, 2000, 255, 55, 255, 255, 255}; // The maximum value that each dimension can display

int bckgndColor = 175; // Background color


void setup() {
  size(1200, 600, P3D); // Set up GUI, width and height, create a 3D space
  defaultTraceLength = width; // Show a trace from end to end; this makes sense.
  stroke(150, 150, 50); // Color for drawing lines
  f = createFont("Arial",16,true); // Arial, 16 point, anti-aliasing on
  if (Serial.list().length > 0) { // Is anything on the serial ports?
    mySerial = new Serial( this, Serial.list()[0], 9600 ); // Open a serial port at the desired rate
    mySerial.bufferUntil(lf); // Fill buffer until there's a new line
  } else {
    debugText = "No serial ports avaliable."; // Prints an error to the console
  }    
  output = createWriter( "timedg.csv" );
  page = SETUP_DISPLAY; // Start on this page
  if (page == SETUP_DISPLAY) { // The screen where you can create new traces and determine how data will be organized.
    bckgndColor = 155;
    setupDisplay(); // 
  }
  SCALING_FACTORS[X_DIM] = int(0.95 * width); // Allow X measurements to use the full extent of the screen's width
  SCALING_FACTORS[Y_DIM] = int(0.95 * height); // Allow Y measurements to use the full extent of the screen's height
  defaultTraceLength = width; // By default, allow enough points for a trace to go the full width of the screen
  setTimeDimSpeed(X_DIM, 1); // Set up the 'time' dimension for the X axis
  setTimeDimSpeed(Y_DIM, 1); // Set up the 'time' dimension for the X axis
  setTimeDimSpeed(Z_DIM, 1); // Set up the 'time' dimension for the X axis
}

// Sets the values in the appropriate time-dimension arraylist such that data can appropriately displayed
// at the desired 'speed' (spacing)
void setTimeDimSpeed(int whichDim, int whatSpeed) {
  if (whichDim == X_DIM) {
    xTimeDim.clear(); // Empty out the list
    for (int i = 0; i < width; i += whatSpeed) { // Populate the list
      xTimeDim.add(i);
    }
  } else if (whichDim == Y_DIM) {
    yTimeDim.clear(); // Empty out the list
    for (int i = 0; i < height; i += whatSpeed) { // Populate the list
      yTimeDim.add(i);
    }
  } else if (whichDim == Z_DIM) {
    zTimeDim.clear(); // Empty out the list
    // Slight issue here! What's a good default length to stretch back into the screen?
    for (int i = 0; i < yTimeDim.size(); i += whatSpeed) { // Populate the list
      zTimeDim.add(i);
    }
  }
  Collections.reverse(zTimeDim); // Change from toward the user to away from the viewer
}


void draw() {
  guiManagement();
  if (page == TRACE_DISPLAY) { // The 'main' screen of the program. This is where the data is shown
    traceDisplay(); // Does everything necessary to display the main page  
  } else if (page == SETUP_DISPLAY) {
    if (measurementFlag) {
      availableMeasurementsDisplay(measurements);
    }
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
  textFont(f,36); // Font variable, font size override
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
         measurements[i] = float(receivedSerial[i].trim()) / MAX_INPUT; // Remove whitespace, convert the string value to a float, and scale to be between 0 and 1
       } catch (Exception e) {
         measurementFlag = false; // Things didn't work out; don't use this message.
         println("Error converting string data to integer. Measurement " + i + " [" + receivedSerial[i].trim() + "]");
       }
   }
 }
  //output.println( value ); // Write to the file
  //output.close(); // Close the file
} // Old


// Draw all relevant data to the GUI
//void plotData() {
//  for (LinkedList trace: traces) {
//    Iterator<Integer> traceItr = trace.iterator(); // To iterate over the points in a trace
//    int xVal = 0; // The x-axis variable
//    int prevY = 0; // The previous y value plotted
//    int currY = 0; // The current value being plotted
//    while(traceItr.hasNext()) { // Loop over the points
//      //point(xVal, traceItr.next(), 0); // Plot the point in 3D (x, y, z)
//      currY = traceItr.next(); // Get the current data point
//      line(xVal - speed, prevY, xVal, currY); // Plot a line from the last point to the current one
//      prevY = currY; // Store this point for future use
//      xVal = xVal + speed; // Increment to the next x position
//    }
//  }
//} // Old

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
  
  //text(serialMessage, textX, textY); // Display the text on screen
  //text(debugText, textX + 30, textY + 70); // Display the text on screen
}

// Everything that has to be done one time before switching to the Trace Display
void traceDisplaySetup() {
  bckgndColor = 255;
}

// :: Classes ::

// A trace is a collection of 1 or more datapoints to be drawn on the screen
class Trace {
  int[] whichMeasurements; // Store the indices of the measurements needed
  int traceLength; // How many datapoints should be kept on screen at any time?
  LinkedList<DataPoint> trace = new LinkedList<DataPoint>(); // This list holds all of the points that make up the trace
  int colorFormat; // Note whether we're using RGB, GRAYSCALE, or RED, GREEN, BLUE
  int timeDim; // Which dimension, if any, is using the 'time' data
    
  // Constructor
  Trace (int[] tempWhichMeasurements, int tempTraceLength, int tempColorFormat, int tempTimeDim) {
    colorFormat = tempColorFormat;
    whichMeasurements = tempWhichMeasurements;
    traceLength = tempTraceLength;
    timeDim = tempTimeDim;
    if (timeDim == X_DIM) { // Handle the use of the 'Time' dimension
      traceLength = xTimeDim.size();
    } else if (timeDim == Y_DIM) {
      traceLength = yTimeDim.size();
    } else if (timeDim == Z_DIM) {
      traceLength = xTimeDim.size();
    }
      
    println("There's a new trace, with the following measurements"); // Debug
    println(tempWhichMeasurements); // Debug
  }
  
  // Checks if there is new data and updates the trace to its most current form
  void update() {
    trace.add(new DataPoint(measurements, whichMeasurements)); // Add a new point to the end of the trace
    if (trace.size() > traceLength) { // Has it gotten too long?
      trace.remove(); // Remove the point at the front of the trace
    }
  }
  
  // Draws the trace in the appropriate format
  void drawTrace() {
    for (int i = 0; i < trace.size() - 1; i++) { // Loop through all of the points in the trace
      // Set the color according to the value in the previous point. This handles the GRAYSCALE, RGB, RED, GREEN, BLUE, and ALPHA dimensions
      if (colorFormat == GRAYSCALE || colorFormat == RGB_COLOR) {
        stroke(trace.get(i).getDimension(colorFormat), trace.get(i).getDimension(ALPHA)); 
      } else { 
        stroke(trace.get(i).getDimension(RED), trace.get(i).getDimension(GREEN), trace.get(i).getDimension(BLUE), trace.get(i).getDimension(ALPHA));
      }
      
      // Set the thickness, or weight, of this portion of the trace, based on the previous point. This handles the THICKNESS dimension.
      strokeWeight(trace.get(i).getDimension(THICKNESS));
      
      // Draw a line between 2 points in the trace. This handles the X, Y, and Z dimensions
      // The if statements handle whether there's actual data for the axis or whether it's a 'time' dimension
      if (timeDim == X_DIM) { // Using 'time' for the x-axis
        //println("X Time"); // DEBUG
        line(xTimeDim.get(i), trace.get(i).getDimension(Y_DIM), -trace.get(i).getDimension(Z_DIM), xTimeDim.get(i+1), trace.get(i+1).getDimension(Y_DIM), -trace.get(i+1).getDimension(Z_DIM));
      } else if (timeDim == Y_DIM) { // Using 'time' for the y-axis
        //println("Y Time"); // DEBUG
        line(trace.get(i).getDimension(X_DIM), yTimeDim.get(i), -trace.get(i).getDimension(Z_DIM), trace.get(i+1).getDimension(X_DIM), yTimeDim.get(i+1), -trace.get(i+1).getDimension(Z_DIM));
      } else if (timeDim == Z_DIM) { // Using 'time' for the z-axis
        //println("Z Time"); // DEBUG
        line(trace.get(i).getDimension(X_DIM), trace.get(i).getDimension(Y_DIM), -xTimeDim.get(i), trace.get(i+1).getDimension(X_DIM), trace.get(i+1).getDimension(Y_DIM), -xTimeDim.get(i+1));
      } else { // Not using 'time' for any axis
        //println("NO Time"); // DEBUG
        line(trace.get(i).getDimension(X_DIM), trace.get(i).getDimension(Y_DIM), -trace.get(i).getDimension(Z_DIM), trace.get(i+1).getDimension(X_DIM), trace.get(i+1).getDimension(Y_DIM), -trace.get(i+1).getDimension(Z_DIM));
      }
    }
  }
} // End Trace class ---------------------------------------------------------------------------------
    
// A datapoint contains MAX_DIMENSIONS values each representing different dimensions of the datapoint
class DataPoint { // This is distinct from the Point class
  int[] values; // 
  
  // Constructor
  DataPoint (float[] tempMeasurements, int[] tempWhichMeasurements) {
    values = new int[MAX_DIMENSIONS]; // Initialize the array that holds info about the point. We won't use MAX_DIMENSIONS values, but it's really convenient to make it this size.
    for (int i = 0; i < MAX_DIMENSIONS; i++) { // Loop through the dimensions
      if (tempWhichMeasurements[i] != -1 && tempWhichMeasurements[i] < tempMeasurements.length) { // -1 means this dimension is not used. If it's not in the measurements array, it is the 'time' option
        //println("Iterator: " + i + " Which measurement: " + tempWhichMeasurements[i] + " Value: " + tempMeasurements[tempWhichMeasurements[i]]); // Debug
        values[i] = int(tempMeasurements[tempWhichMeasurements[i]] * SCALING_FACTORS[i]); // Pick out the measurement we want, scale it for the dimension, set it as a parameter of this datapoint
        //text(dimensionOptions[i] + " " + values[i], 50*(i + 1), 150); // Debug
      } else if (tempWhichMeasurements[i] != -1) { // For the 'time' dimension
        // Do nothing, but this is here in case you want to do something for the 'time' measurement
      } else { // We aren't using this dimension, but we need to set it to something
        values[i] = DEFAULT_VALUES[i]; // We'll use the default values that we know are safe
      }
    }
  }
  
  // Returns the value for the requested dimension of this point
  int getDimension(int requestedDimension) {
    return(values[requestedDimension]); 
  }
}