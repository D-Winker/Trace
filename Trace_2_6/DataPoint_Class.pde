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