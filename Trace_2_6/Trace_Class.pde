// A trace is a collection of 1 or more datapoints to be drawn on the screen
class Trace {
  int[] whichMeasurements; // Store the indices of the measurements needed
  int traceLength; // How many datapoints should be kept on screen at any time?
  LinkedList<DataPoint> trace = new LinkedList<DataPoint>(); // This list holds all of the points that make up the trace
  int colorFormat; // Note whether we're using GRAYSCALE, or RED, GREEN, BLUE
  boolean usingXTime; // Is this dimension using the 'time' measurement?
  boolean usingYTime; // Is this dimension using the 'time' measurement?
  boolean usingZTime; // Is this dimension using the 'time' measurement?
  boolean logging; // Will we log the data for this trace?
  PrintWriter writeDataToFile; // A printwriter to write trace data to a file.
  int tempX1, tempY1, tempZ1, tempX2, tempY2, tempZ2; // These are used in drawing. Preallocating saves some time, wastes some memory. Either way is probably fine.
    
  // -Constructor-
  Trace (int[] tempWhichMeasurements, int tempTraceLength, int tempColorFormat, boolean tempXTimeDim, boolean tempYTimeDim, boolean tempZTimeDim, boolean tempLogging) {
    colorFormat = tempColorFormat;
    whichMeasurements = tempWhichMeasurements;
    traceLength = tempTraceLength;
    usingXTime = tempXTimeDim;
    usingYTime = tempYTimeDim;
    usingZTime = tempZTimeDim;
    logging = tempLogging;
     
    // Set up the things we need for logging; if we're logging this one.
    if (tempLogging) { // Are we going to log this trace's data?
        String logFileName = "trace_#" + numTraces + "_[" + getTimeAndDate() + "].csv"; // Name the log file we'll write to
        writeDataToFile = createWriter(logFileName); // Create the file and create a writer for the log file
        writeDataToFile.print("Timestamp,"); // Write a column header for a timestamp
        for (int i = 0; i < tempWhichMeasurements.length; i++) { // Write column headers to the file, one for each dimension in the trace
          // (Writes Dimension: Measurement, ... for each dimension used)
          if (tempWhichMeasurements[i] >= 0) { // Are we using this dimension?
            writeDataToFile.print(dimensionOptions[i] + ": " + tempWhichMeasurements[i] + ",");
          }
        }
        writeDataToFile.println(); // Go down to the line after the column headers
    }
    this.correctLength(); // Make sure the length appropriately matches the 'time' measurement, assuming one is being used
    println("There's a new trace, with the following measurements"); // Debug
    println(tempWhichMeasurements); // Debug
  }
  
  
  // -Checks if there is new data and updates the trace to its most current form-
  void update() {
    trace.add(new DataPoint(measurements, whichMeasurements)); // Add a new point to the end of the trace
    if (trace.size() > traceLength) { // Has it gotten too long?
      trace.remove(); // Remove the point at the front of the trace
    }
    if (logging) { // Should the data for this trace be logged?
      writeDataToFile.print(getTimeAndDate() + ","); // Write the time into the first column
      for (int i = 0; i < whichMeasurements.length; i++) { // Write column headers to the file, one for each dimension in the trace
          // (Writes Dimension: Measurement, ... for each dimension used)
          if (whichMeasurements[i] >= 0 && whichMeasurements[i] < measurements.length) { // Are we using this dimension? And is it real (not 'time')?
            writeDataToFile.print(measurements[whichMeasurements[i]] * SCALING_FACTORS[i] + ","); // Get the measurement from this dimension; write it in the correct place in the file.
          }
        }
        writeDataToFile.println(); // Go down to the next line
    }
  }
  
  
  // -Draws the trace in the appropriate format-
  void drawTrace() {
    for (int i = 0; i < trace.size() - 1; i++) { // Loop through all of the points in the trace
      // Set the color according to the value in the previous point. This handles the GRAYSCALE, RED, GREEN, BLUE, and ALPHA dimensions
      if (colorFormat == GRAYSCALE) {
        stroke(trace.get(i).getDimension(colorFormat), trace.get(i).getDimension(ALPHA)); 
      } else { 
        stroke(trace.get(i).getDimension(RED), trace.get(i).getDimension(GREEN), trace.get(i).getDimension(BLUE), trace.get(i).getDimension(ALPHA));
      }
      
      // Set the thickness, or weight, of this portion of the trace, based on the previous point. This handles the THICKNESS dimension.
      strokeWeight(trace.get(i).getDimension(THICKNESS));
      
      // Draw a line between 2 points in the trace. This handles the X, Y, and Z dimensions
      // The Y dimension is made negative so that increasing values leads upwards on the screen
      tempX1 = trace.get(i).getDimension(X_DIM);
      tempY1 = -trace.get(i).getDimension(Y_DIM);
      tempZ1 = trace.get(i).getDimension(Z_DIM);
      tempX2 = trace.get(i+1).getDimension(X_DIM);
      tempY2 = -trace.get(i+1).getDimension(Y_DIM);
      tempZ2 = trace.get(i+1).getDimension(Z_DIM);
      if (usingXTime) { // Using 'time' for the x-axis
        tempX1 = xTimeDim.get(i);
        tempX2 = xTimeDim.get(i+1);
      }
      if (usingYTime) { // Using 'time' for the y-axis
        tempY1 = -yTimeDim.get(i);
        tempY2 = -yTimeDim.get(i+1);
      }
      if (usingZTime) { // Using 'time' for the z-axis
        tempZ1 = zTimeDim.get(i);
        tempZ2 = zTimeDim.get(i+1);
      }
      line(tempX1, tempY1, tempZ1, tempX2, tempY2, tempZ2);
    }
  }
  
  
  // -If this trace's data has been logged, the log file will be closed.-
  void closeLog() { 
    if(logging) { // Is this trace logging?
      writeDataToFile.flush(); // Write the remaining data
      writeDataToFile.close(); // Finish the file
    }
  }
  
  // -If this trace is using a 'time' measurement, it will adjust it's length to match that of the
  // appropriate 'time' measurement arraylist. If using more than 1 'time' measurement, we need to adjust
  // trace length to the smallest one.
  // There must be a better way than these if statements... (use a 3 digit binary number instead of booleans?)
  void correctLength() {
    // Using one
    if (usingXTime) {
      traceLength = xTimeDim.size();
    }
    if (usingYTime) {
      traceLength = yTimeDim.size();
    }
    if (usingZTime) {
      traceLength = zTimeDim.size();
    }
    // Using two
    if (usingXTime && usingYTime) {
      traceLength = min(xTimeDim.size(), yTimeDim.size());
    }
    if (usingYTime && usingZTime) {
      traceLength = min(yTimeDim.size(), zTimeDim.size());
    }
    if (usingXTime && usingZTime) {
      traceLength = min(xTimeDim.size(), zTimeDim.size());
    }
    // Using three
    if (usingXTime && usingYTime && usingZTime) {
      traceLength = min(min(xTimeDim.size(), yTimeDim.size()), zTimeDim.size());
    }
    // Trim the trace to the appropriate length (if it's too big)
    while (traceLength < trace.size()) {
      trace.remove(); // Pull off the item at the front of the trace
    }
    println("Fixed trace length " + traceLength); // Debug
  }
}