// 5D - x, y, z, color, line thickness

// Data is sent from some device over serial (USB) in a CSV format.
// Between commas, there must only be numbers, decimal points, and whitespace. The numbers cannot have whitespace within them.
// A given line can have any number of measurements, which can be plotted in various ways.
// Measurements can be plotted against eachother and/or time in 5 dimensions
//    -Vertical, Horizontal, Depth (up and down, left and right, and in and out of the screen)
//    -Point Size or Line Thickness
//    -Color
// Measurements can be displayed on screen and simultaneously stored in a text file.
// Any given trace seen on screen - a trace being a collection of points associated with a group of 1 or more measurements - is stored in a LinkedList.
// All of the LinkedLists - all of the traces - are stored in an ArrayList


// ---Make a trace class
// A trace will know what linkedlists it's supposed to pull data from, and in what order, and where that data goes
// A trace will implement its own draw function?


import processing.serial.*; // For reading serial data
import java.util.*;

PFont f; // Declare PFont variable
float textX = 20; // X position of the text
float textY = 50; // Y position of the text
Serial mySerial; // Serial object for reading from the port
PrintWriter output; // For writing to a text file
String guiText = "Hi!"; // Text displayed on the GUI
String debugText = "Hi.";
int lf = 10;      // ASCII linefeed (newline)
int previousY = 0; // The previous measurement taken
int currentY = 0; // The most recent measurement
int strLen = 0; // Used for recording message length
boolean messageFlag = false; // Is there a new serial message?
ArrayList<LinkedList> traces = new ArrayList<LinkedList>(); // This will hold the LinkedLists of traces
LinkedList<Integer> trace1 = new LinkedList<Integer>(); // This linked list holds all points in a given trace
int speed = 7; // How fast do we scroll/stretch the signal?

void setup() {
  size(800, 800, P3D); // Set up GUI, width and height, create a 3D space
  stroke(150, 150, 50); // Color for drawing lines
  f = createFont("Arial",16,true); // Arial, 16 point, anti-aliasing on
  if (Serial.list().length > 0) { // Is anything on the serial ports?
    mySerial = new Serial( this, Serial.list()[0], 9600 ); // Open a serial port at the desired rate
    mySerial.bufferUntil(lf); // Fill buffer until there's a new line
  } else {
    debugText = "No serial ports avaliable."; // Prints an error to the console
  }    
  output = createWriter( "timedg.csv" );
}

void draw() {
  guiManagement(); // Take care of various GUI tasks like text alignment, setting colors, etc.
  
  parseSerial(); // Parse the message that was sent over serial
  
  text(guiText, textX, textY); // Display the text on screen
  text(debugText, textX + 30, textY + 70); // Display the text on screen
  
  plotData(); // Plot all recorded data to the GUI
} // End draw() --------------------------------------------------------------------------------------


// Called when bufferUntil reaches the 'until' (a newline, in the case of this code)
void serialEvent(Serial p) {
  guiText = p.readString(); // Store whatever message was sent
  messageFlag = true; // We have a new message
}


// Take care of various GUI tasks (setup, colors, etc.) that have to be done for each frame
void guiManagement() {
  background(255); // Create background and set background color
  textFont(f,36); // Font variable, font size override
  fill(0); // Specify color
  textAlign(LEFT); // Text alignment (L, R, C)
}


// Extract the measurements from the message sent
void parseSerial() {
 if (guiText != null && messageFlag) { // Did we really get something?
   messageFlag = false; // Note that we're using the message
   previousY = currentY; // Update the old measurement
   String[] measurements = split(guiText, ','); // Split the message on commas, store the substrings
   
   int numMeasurements = measurements.length;
   int numTraces = traces.size(); // How many traces should we have right now?
   while (numTraces < numMeasurements) { // Add traces until we have enough to display all of the measurements
     traces.add(new LinkedList<Integer>()); // Add a new trace (LinkedList) to the ArrayList of traces
     numTraces = traces.size(); // How many traces do we have right now?
   }
   println("NumTraces " + numTraces + "NumMeasurements " + numMeasurements);
   
   for(int traceItr = 0; traceItr < numTraces; traceItr++) { // Loop through all of the traces and add on their new measurements
     traces.get(traceItr).addLast(int(measurements[traceItr].trim())); // Put this measurement on the trace, at the end, after removing whitespace and converting to an integer
     if(traces.get(traceItr).size() * speed > width + 2*speed) { // Do we have more points than the screen is wide? There's some additional buffer space (2*speed) to ensure we go the full width with nothing missing at the edges
       traces.get(traceItr).remove(); // Removes the item at the front of the list
       // We don't need to store more points than we can display on the screen!
     }
   } 
 }
  //output.println( value ); // Write to the file
  //output.close(); // Close the file
}


// Draw all relevant data to the GUI
void plotData() {
  for (LinkedList trace: traces) {
    Iterator<Integer> traceItr = trace.iterator(); // To iterate over the points in a trace
    int xVal = 0; // The x-axis variable
    int prevY = 0; // The previous y value plotted
    int currY = 0; // The current value being plotted
    while(traceItr.hasNext()) { // Loop over the points
      //point(xVal, traceItr.next(), 0); // Plot the point in 3D (x, y, z)
      currY = traceItr.next(); // Get the current data point
      line(xVal - speed, prevY, xVal, currY); // Plot a line from the last point to the current one
      prevY = currY; // Store this point for future use
      xVal = xVal + speed; // Increment to the next x position
    }
  }
}