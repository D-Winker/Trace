
// :: General Functions ::

// Returns the current date and time as a string in the format
// month-day-year_hh-mm-ss
// It turns out colons are not safe for Windows file names!
String getTimeAndDate() {
  return (month() + "-" + day() + "-" + year() + "_" + hour() + "-" + minute() + "-" + second());
}

// Closes log files and exits the program
void quit() {
  closePort(); // Release the port before the program ends
  for (Trace t : traces) {
      t.closeLog(); // If this trace has a log, the file will be properly closed.
    }
}

// Closes logs if there are any
void closeLogs() {
  for (Trace t : traces) {
      t.closeLog(); // If this trace has a log, the file will be properly closed.
    }
}

// This is called when the program ends
// So, when someone clicks the X in the corner
public void stop() {
  quit();
  super.stop(); // This calls the default stop method
} 

// - Draws the X, Y, and Z axes to the screen -
// draw the x axis
void drawXAxis() {
  stroke(color(axesRed, axesGreen,axesBlue), axesAlpha); // Set the color and opacity of the axis
  strokeWeight(axesThickness); // Set the thickness of the axis
  textSize(20);
  // Write labels at the axis tick marks
  for (int i = 0; i <= SCALING_FACTORS[X_DIM]; i += axisTickSpacing) {
    // text(str, x, y, z)
    text(str(i), i, 0, 0);
  }
  // Draw the line for the axis
  // line(x1, y1, z1, x2, y2, z2);
  line(0, 0, 0, SCALING_FACTORS[X_DIM], 0, 0);
} //------------------------------------------
// draw the y axis
void drawYAxis() {
  stroke(color(axesRed, axesGreen,axesBlue), axesAlpha); // Set the color and opacity of the axis
  strokeWeight(axesThickness); // Set the thickness of the axis
  textSize(20);
  // Write labels at the axis tick marks
  for (int i = 0; i <= SCALING_FACTORS[Y_DIM]; i += axisTickSpacing) {
    // text(str, x, y, z)
    text(str(i), 0, -i, 0);
    // i is made negative so increasing values go upwards
  }
  // Draw the line for the axis
  // line(x1, y1, z1, x2, y2, z2);
  // Negative sign so larger values go upwards
  line(0, 0, 0, 0, -SCALING_FACTORS[Y_DIM], 0);
} //------------------------------------------
// draw the z axis
void drawZAxis() {
  stroke(color(axesRed, axesGreen,axesBlue), axesAlpha); // Set the color and opacity of the axis
  strokeWeight(axesThickness); // Set the thickness of the axis
  textSize(20);
  // Write labels at the axis tick marks
  for (int i = 0; i <= SCALING_FACTORS[Z_DIM]; i += axisTickSpacing) {
    // text(str, x, y, z)
    text(str(i), 0, 0, i);
  }
  // Draw the line for the axis
  // line(x1, y1, z1, x2, y2, z2);
  line(0, 0, 0, 0, 0, SCALING_FACTORS[Z_DIM]);
} //------------------------------------------

void drawBoxes() {
  lights(); //Debug
  stroke(255, 0, 0); // Debug
  box(50, 25, 10); // Debug
  stroke(0, 255, 0); // Debug
  translate(cam.getLookAt()[0], cam.getLookAt()[1], cam.getLookAt()[2]); // Debug, draw the one where the camera is looking
  box(50, 25, 10); // Debug
  translate(-cam.getLookAt()[0], -cam.getLookAt()[1], -cam.getLookAt()[2]); // Debug, move back
  stroke(0, 0, 255); // Debug
  sphere(15); // Debug
}

// :: Setup Functions ::
// These functions get things ready to be used
// They likely only ever need to be called once, on startup

// Returns a String array of all available serial connections
String[] getSerialOptions() {
  return Serial.list();
}

// Establish a serial connection at the desired baud rate
void setUpSerial(String serialPort, int baudRate) {
  println("Setting up the serial connection"); // Debug
  closePort(); // If we're already connected to something, break the connection
  // Check that the port is still there, select it
  for (int portIter = 0; portIter < Serial.list().length; portIter++) {
    if (Serial.list()[portIter].equals(serialPort)) {
      mySerial = new Serial( this, Serial.list()[portIter], baudRate); // Open a serial port at the desired rate
      mySerial.bufferUntil(lf); // Fill buffer until there's a new line
      println("Making a port connection."); // Debug
    }
  }  
}

// Close the serial connection, if there is one
void closePort() { 
  try {
    mySerial.stop();
  } catch(Exception e) {
    println("There was no prior connection."); // Debug
  }
}