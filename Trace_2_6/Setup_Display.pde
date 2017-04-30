/**
 *
 */
 
import controlP5.*;
import java.util.*;

ControlP5 setupControl;

Textlabel measurementsLabel;
Textlabel errorLabel;
CheckBox checkDimension; // Select which dimensions will be used for a trace
CheckBox toggleLogging; // Choose whether or not to log the data from a trace
ScrollableList portList; // List of available ports
ScrollableList baudList; // List of available baud rates
Textfield normParamTextfield;

String currentError = "";
String measurementsAvailableString = "";
List dropOptions = new ArrayList<String>();
float[] oldCheckDimensionBox = new float[dimensionOptions.length];
int numTraces = 0; // How many traces have been created?
int timeDimIndex = -1; // Keep track of which index in the scrollable dropdowns in the 'Time' option. -1 indicates it was not created correctly
boolean tempLogging = false; // Do we log the data for a trace? By default, no.
String baudRates[] = {"110", "300", "600", "1200", "2400", "4800", "9600", "14400", "19200", "38400", "57600", "115200", "230400", "460800", "921600"};
String selectedPort = "";
int selectedBaud = 0;

void setupDisplay() {
  noStroke();
  Arrays.fill(oldCheckDimensionBox, 0); // Ensure the array is empty, we start with nothing checked!
  
  setupControl = new ControlP5(this);
  
  int spacingX = 45;
  int spacingY = 30;
  
  
  // This will show what measurements are available
  measurementsLabel = setupControl.addTextlabel("measurementsLabel")
                    .setText(measurementsAvailableString)
                    .setPosition(2 * spacingX, 3 * spacingY)
                    .setColorValue(255)
                    .setFont(createFont("Calibri",20))
                    ;
   // This will tell the user if there's an error
  errorLabel = setupControl.addTextlabel("errorLabel")
                    .setText(measurementsAvailableString)
                    .setPosition(14 * spacingX, spacingY)
                    .setColorValue(color(255, 200, 200))
                    .setFont(createFont("Arial Bold",18))
                    ;
  
  buttons(spacingX, spacingY);
  addScrollableLists();
  createTextFields();
  newTraceOptions();
  // We turn off autodraw so we can manually draw setupControl only on the HUD
  // This way we don't have to worry about the buttons moving around in 3D if someone accidentally drags the screen
  setupControl.setAutoDraw(false);
}


// Draws the SETUP_DISPLAY on the 'HUD"
// In overwords, in 2D, on the screen.
// Why even use the camera? Why have the option of 3D?
// It's easier than switching back and forth hoping the camera is off and nothing is messed up.
// Screen resizing is where the difficulty really came in
void drawSetup() {
  cam.beginHUD();
  setupControl.draw(); 
  cam.endHUD();
}


// Whenever you want a new trace, this shows all the stuff you need.  
void newTraceOptions() {
  int spacingX = 45;
  int spacingY = 30;
  checkDimension = setupControl.addCheckBox("checkDimension")
                .setPosition(2*spacingX, 5*spacingY)
                .setSize(40, 40)
                .setItemsPerRow(2)
                .setSpacingColumn(7*spacingX)
                .setSpacingRow(spacingY)
                .addItem(dimensionOptions[0], 0)
                .addItem(dimensionOptions[1], 1)
                .addItem(dimensionOptions[2], 2)
                .addItem(dimensionOptions[3], 3)
                .addItem(dimensionOptions[4], 4)
                .addItem(dimensionOptions[5], 5)
                .addItem(dimensionOptions[6], 6)
                .addItem(dimensionOptions[7], 7)
                .addItem(dimensionOptions[8], 8)
                .addItem(dimensionOptions[9], 9)
                ;
  toggleLogging = setupControl.addCheckBox("toggleLogging")
                .setPosition(10*spacingX, 17*spacingY)
                .setSize(30, 30)
                .setItemsPerRow(2)
                .setSpacingColumn(7*spacingX)
                .setSpacingRow(spacingY)
                .addItem("Toggle Logging", 0)
                ;
}


// :: Handle Checkboxes ::

// Handle checkboxes being checked and unchecked
// When checked - create a scrollable dropdown to select the measurement for that dimension
// When unchecked - remove the dropdown
// If any mutually exlusive option is checked (Grayscale or R/G/B) uncheck the others
void checkDimension(float[] checkDimensionVals) {
  // I'm only including this explanation once, but the below if statement appears all over
  // ControlP5 has this...quirk, that at startup all controllers are executed. (but not with this if statement!)
  // "the reason for the autostart is, lets say you want to use your controller setup for initialization, then the autostart for the controllers is required."
  // https://processing.org/discourse/beta/num_1178557523.html (I haven't seen a way to configure this; if you have, please let me know!)
  if ( frameCount > 1) {
    int spacingX = 45;
    int spacingY = 30;
    
    //println("Hello there"); // Debug
    //println("Old Checkbox; New Checkbox"); // Debug
    
    // Loop through the checkbox array and see what was just clicked
    for (int i = 0; i < checkDimensionVals.length; i++) {
      //println(oldCheckDimensionBox[i] + "; " + checkDimensionVals[i]); // Debug
      // Check if the checkbox we're looking at has changed state
      if (oldCheckDimensionBox[i] != checkDimensionVals[i]) {
        if (checkDimensionVals[i] == 1) { // If the box was just checked
        // The two below variables are used for placing the scrollable dropdown
          int rightColSpace = 0; // There are two columns of checkboxes, we need to adjust spacing for this
          int vertSpace = i / 2; // Things in the same row need the same vertical spacing
          if (i % 2 == 1) { // If it's an odd number (i.e. right column)
            rightColSpace = 8; // This number works decently
          }
          
          
          // Check if the box is among the mutually exclusive dimensions
          // If it is, we must ensure the other exclusive options are unchecked and without dropdown lists
          if (i == RED || i == GREEN || i == BLUE || i == GRAYSCALE) {
            checkDimensionVals[i] = 0; // Pretend this box is unchecked for the sake of the following code
            
            // Check which, if any, of the other exclusive boxes are checked
            // Then, remove the relevant scrollable dropdown, and uncheck the boxes
            if (checkDimensionVals[GRAYSCALE] == 1) {
              println("Removing the "+dimensionOptions[GRAYSCALE]+" option"); // Debug
              checkDimensionVals[GRAYSCALE] = 0; // Note the change
              oldCheckDimensionBox[GRAYSCALE] = 0; // Record the change
              // Clear the check
              setupControl.get(CheckBox.class, "checkDimension").deactivate(GRAYSCALE);
              // Remove the associated scrollable dropdown
              setupControl.get(ScrollableList.class, "Available Measurements " + dimensionOptions[GRAYSCALE]).remove();
            }
            // The Red, Green, and Blue options are not independent from eachother
            // so they're a special case
            if (i != RED && i != GREEN && i != BLUE) {
              if (checkDimensionVals[RED] == 1) {
                println("Removing the "+dimensionOptions[RED]+" option"); // Debug
                checkDimensionVals[RED] = 0; // Clear the check
                oldCheckDimensionBox[RED] = 0; // Record the change
                // Clear the check
                setupControl.get(CheckBox.class, "checkDimension").deactivate(RED);
                // Remove the associated scrollable dropdown
                setupControl.get(ScrollableList.class, "Available Measurements " + dimensionOptions[RED]).remove();
              } 
              if (checkDimensionVals[GREEN] == 1) {
                println("Removing the "+dimensionOptions[GREEN]+" option"); // Debug
                checkDimensionVals[GREEN] = 0; // Clear the check
                oldCheckDimensionBox[GREEN] = 0; // Record the change
                // Clear the check
                setupControl.get(CheckBox.class, "checkDimension").deactivate(GREEN);
                // Remove the associated scrollable dropdown
                setupControl.get(ScrollableList.class, "Available Measurements " + dimensionOptions[GREEN]).remove();
              } 
              if (checkDimensionVals[BLUE] == 1) {
                println("Removing the "+dimensionOptions[BLUE]+" option"); // Debug
                checkDimensionVals[BLUE] = 0; // Clear the check
                oldCheckDimensionBox[BLUE] = 0; // Record the change
                // Clear the check
                setupControl.get(CheckBox.class, "checkDimension").deactivate(BLUE);
                // Remove the associated scrollable dropdown
                setupControl.get(ScrollableList.class, "Available Measurements " + dimensionOptions[BLUE]).remove();
              }
            }
            
            checkDimensionVals[i] = 1; // Now that we're done removing things, go back to normal
          }
          
          println("Checked the "+dimensionOptions[i]+" box"); // Debug
          
          ArrayList<String> dropDownOptions = new ArrayList<String>(dropOptions); // Copy dropOptions by value. This lets us add measurement options for specific dimensions.
          if (i == X_DIM || i ==  Y_DIM || i == Z_DIM) { // Handle the 'time' option for relevant dimensions
            dropDownOptions.add("'Time'");
            timeDimIndex = dropDownOptions.size() - 1; // Note which of the options is the time dimension
          }
          
          // Create the scrollable dropdown
          setupControl.addScrollableList("Available Measurements " + dimensionOptions[i])
           .setPosition((4+rightColSpace)*spacingX, (5+vertSpace)*spacingY+40*vertSpace)
           .setSize(200, 100)
           .setBarHeight(40)
           .setItemHeight(20)
           .addItems(dropDownOptions)
           ;
        } else { // The box was unchecked
          println("Unchecked the "+dimensionOptions[i]+" box"); // Debug
          // Find the relevant dropdown and remove it
          setupControl.get(ScrollableList.class, "Available Measurements " + dimensionOptions[i]).remove();
        }
        oldCheckDimensionBox[i] = checkDimensionVals[i]; // Remember that a box changed state
      } // Finished with box i
    } // Done looping through the checkboxes
  }
}


// See if the user wants to log the data for this trace
void toggleLogging(float[] toggleLoggingVal) {
  if (toggleLoggingVal[0] == 1) { // Is it checked?
    tempLogging = true; // Note that they want to log this
  } else {
    tempLogging = false; // Mind changed; not logging this one
  }
}

// :: Dropdown Handling ::
// This section handles all dropdowns except the ones added when checkboxes are clicked

void addScrollableLists() {
  // Create a scrollable dropdown
  // This will allow the user to select a COM port to connect to
  portList = setupControl.addScrollableList("Select_a_port")
   .setPosition(spacingX, spacingY)
   .setSize(100, 100)
   .setBarHeight(20)
   .setItemHeight(20)
   .addItems(getSerialOptions())
   ;
  // Create a scrollable dropdown
  // This will allow the user to select a baud rate to use
  baudList = setupControl.addScrollableList("Select_a_baud_rate")
   .setPosition(4 * spacingX, spacingY)
   .setSize(120, 100)
   .setBarHeight(20)
   .setItemHeight(20)
   .addItems(baudRates)
   ;
}

//ControlP5 callback - method name must be the same as the string parameter of .addScrollableList()
void Select_a_port(int index) {
  selectedPort = setupControl.get(ScrollableList.class, "Select_a_port").getItem(index).get("name").toString();
}

//ControlP5 callback - method name must be the same as the string parameter of .addScrollableList()
void Select_a_baud_rate(int index) {
  try {
    selectedBaud = Integer.parseInt(setupControl.get(ScrollableList.class, "Select_a_baud_rate").getItem(index).get("name").toString());
    if (currentError.equals("Error with selected baud rate.")) {
      clearError();
    }
  } catch (Exception e) {
    selectedBaud = 0;
    currentError = "Error with selected baud rate.";
    displayError(); 
  }
}

// :: Textfields ::
// This handles all arbitrary-input text boxes

void createTextFields() {
  normParamTextfield = setupControl.addTextfield("Normalization-Parameter")
     .setPosition(7 * spacingX,spacingY)
     .setSize(100,20)
     .setFont(defaultFont)
     .setFocus(true)
     .setColor(color(255,255,255))
     ;
}


// :: Button Handling ::

// function addTrace will receive changes from 
// controller with name addTrace
public void addTrace(int theValue) {
  if ( frameCount > 1) { // Quick fix, explained elsewhere
  
    int tempColorFormat = DEFAULT_COLOR_FORMAT; // Which color scheme is used for this trace. Default to the default.
    //println("a button event from addtrace: "+theValue); // Debug
    int[] tempWhichMeasurements = new int[MAX_DIMENSIONS]; // This is for tracking which measurements were selected for which dimensions 
    boolean usingXTime = false; // Is this dimension using the 'time' measurement?
    boolean usingYTime = false; // Is this dimension using the 'time' measurement?
    boolean usingZTime = false; // Is this dimension using the 'time' measurement?
    
    // Loop through all of the dropdown lists
    for (int i = 0; i < dimensionOptions.length; i++) {
      //print("The " + dimensionOptions[i] + " dimension is using measurement "); // Debug
      // Check if there is a scrollable dropdown list for the dimension we're looking at
      ScrollableList relevantList = setupControl.get(ScrollableList.class, "Available Measurements " + dimensionOptions[i]);
      if (relevantList != null) { // If there is a list for the dimension
        //println(relevantList.getValue()); // Debug
        tempWhichMeasurements[i] = int(relevantList.getValue()); // Take the user's selection from the scrollable dropdown
        relevantList.remove(); // Cleanup the lists used for that trace
        if (i == RED || i == GREEN || i == BLUE) {
          tempColorFormat = RED;
        }
        // Handle the 'time' measurement
        if (i == X_DIM) {
          if (int(relevantList.getValue()) == timeDimIndex) { // If the time measurement is selected
             usingXTime = true; // Note this dimension is using the 'Time' measurement
          }
        }
        if (i == Y_DIM) {
          if (int(relevantList.getValue()) == timeDimIndex) { // If the time measurement is selected
             usingYTime = true; // Note this dimension is using the 'Time' measurement
          }
        }
        if (i == Z_DIM) {
          if (int(relevantList.getValue()) == timeDimIndex) { // If the time measurement is selected
             usingZTime = true; // Note this dimension is using the 'Time' measurement
          }
        }
      } else { // If there isn't a list
        tempWhichMeasurements[i] = -1; // We aren't using this; we denote this with -1
        println("Woops! Guess we aren't using that dimension."); // Debug 
      }
    }
    
    numTraces++; // Note that there's a new trace
    displayTrace("New Trace: " + numTraces); // List the new trace on screen
    traces.add(new Trace(tempWhichMeasurements, defaultTraceLength, tempColorFormat, usingXTime, usingYTime, usingZTime, tempLogging)); // Actually creating the new trace.
    
    // Clear the checked boxes
    // First, check if there are checkboxes
    CheckBox tmpBox = setupControl.get(CheckBox.class, "checkDimension");
    if (tmpBox != null) {
      println("Clearing checkboxes"); // Debug
      setupControl.get(CheckBox.class, "checkDimension").deactivateAll();
    }
    tmpBox = setupControl.get(CheckBox.class, "toggleLogging");
    if (tmpBox != null) {
      println("Clearing toggle checkbox"); // Debug
      setupControl.get(CheckBox.class, "toggleLogging").deactivateAll();
    }
    
    // Reset defaults
    Arrays.fill(oldCheckDimensionBox, 0); // Clear out the checkbox array
    tempLogging = false; // Do we log the data for a trace? By default, no.
    println("Trace added.\n----------------------------------------------------------------------------------------------\n\n"); // Debug
  }
}


// function done will receive changes from 
// controller with name done
public void done(int theValue) {
  //println(""); // Debug
  if ( frameCount > 1) {
    //println("a button event from: "+theValue); // Debug
    // Note the height and width of the screen, for handling future resizing
    oldWidth = width;
    oldHeight = height;
    setupControl.hide(); // Hide all of the elements in this menu
    page = TRACE_DISPLAY; // Done with this page, onto the next!
    traceDisplaySetup(); // Get things ready for the switch
    camHandlePageChange();
  }
  println(""); // Debug
}

// function update will receive changes from 
// controller with name update
public void update(int theValue) {
  if ( frameCount > 1) {
   //portList.clear(); // Clear the list
   portList.setItems(getSerialOptions()); // Check what ports are available, remake the list
   println("#Ports " + getSerialOptions().length);
  }
}

// function update will receive changes from 
// controller with name connect
public void connect(int theValue) {
  if ( frameCount > 1) {
    int tempParam = 0;
    try {
      tempParam = Integer.parseInt(setupControl.get(Textfield.class,"Normalization-Parameter").getText());
      if (currentError.equals("Could not use normalization parameter. Must be an integer.")) {
        clearError();
      }
    } catch (Exception e) {
      tempParam = 0;
      currentError = "Could not use normalization parameter. Must be an integer.";
      displayError();
    }
    if (selectedBaud != 0 && tempParam > 0 && !selectedPort.equals("")) {
      NORMALIZATION_PARAM = tempParam;
      println("Connecting: Port " + selectedPort + ", Baud Rate " + selectedBaud + ", Norm. Parameter " + NORMALIZATION_PARAM); // Debug
      setUpSerial(selectedPort, selectedBaud);
    } else if (currentError.equals("")) {
      currentError = "Problem with connection parameters.";
      displayError();
    }
  }
}
// function update will receive changes from 
// controller with name break_connection
public void break_connection(int theValue) {
  if ( frameCount > 1) {
    closePort();
    closeLogs();
    delete_traces(0);
  }
}

// function done will receive changes from 
// controller with name delete_traces
public void delete_traces(int theValue) {
  if ( frameCount > 1) {
    //println("a button event from: "+theValue); // Debug
    closeLogs(); // Close logs (if there are any) before getting rid of the traces
    traces.clear(); // Empty the arraylist of traces. This gets rid of the traces!
    numTraces = 0; // This is now the number of traces that there are
    // Loop through the controllers used in the Setup Display, remove all of the labels for the Traces
    for (ControllerInterface c: setupControl.getAll()) {
      println("Item: " + c.getAddress() + ", " + c.getName() + ", " + c.getStringValue()); // Debug
      if (c.getName().contains("Trace:")) {
        c.remove();
      }
    }
  }
}


// Handles adding buttons to the screen
void buttons(int spacingX, int spacingY) {
  // create a new button with display text 'ADDTRACE'
  setupControl.addButton("addTrace")
    .setValue(0)
    .setPosition(2 * spacingX, 18 * spacingY)
    .setSize(200,19)
    ;
     
  // create a new button with display text 'UPDATE'
  setupControl.addButton("update")
    .setValue(1)
    .setPosition(spacingX, 2 * spacingY)
    .setSize(100,19)
    ;        
  // create a new button with display text 'CONNECT'
  setupControl.addButton("connect")
    .setValue(2)
    .setPosition(10 * spacingX, spacingY)
    .setSize(100,19)
    ;   
  // create a new button with display text 'BREAK_CONNECTION'
  setupControl.addButton("break_connection")
    .setValue(2)
    .setPosition(10 * spacingX, 2 * spacingY)
    .setSize(100,19)
    ;   
    
  // create a new button with display text 'DONE'
  setupControl.addButton("done")
    .setValue(3)
    .setPosition(12 * spacingX, 19 * spacingY)
    .setSize(200,19)
    ;   
    
  // create a new button with display text 'DELETE_TRACES'
  setupControl.addButton("delete_traces")
    .setValue(4)
    .setPosition(22 * spacingX, 14 * spacingY)
    .setSize(100,19)
    ;
}


// :: Text :: 
// Everything that exists solely to show text on screen

// Adds info about a created trace to the screen
void displayTrace(String tr) {
  measurementsLabel = setupControl.addTextlabel(tr)
                      .setText(tr)
                      .setPosition(17 * spacingX, spacingY * (3 + numTraces))
                      .setColorValue(255)
                      .setFont(createFont("Calibri",24))
                      ;
}

// Displays the error text on the screen
void displayError() {
  setupControl.get(Textlabel.class, "errorLabel").setText(currentError);
}
// Clears the error message
void clearError() {
  currentError = "";
  setupControl.get(Textlabel.class, "errorLabel").setText(currentError);
}


// When you're selecting measurements, you probably want to know what the measurements are
// This will display the current readings at the top of the screen
// It also takes care of anything else that needs measurements as they update
void availableMeasurementsDisplay(float[] measurementsAvailable) {
  // This will populate the dropdown lists. It's a little ridiculous to do this every time we draw the measurements, but it works for now.
  // We need to know how many measurements we have before we do this, but then it really only needs to be done once.
  dropOptions.clear(); // Clear off the list so we can recreate it
  for (int i = 1; i <= numMeasurements; i++) {
    dropOptions.add(Integer.toString(i));
  }
  
  measurementsAvailableString = "Available Measurements: ";
  for (int i = 0; i < measurementsAvailable.length; i++) {
    // String.format("%.Nf", f) turns f into a string limited to N decimal places
    measurementsAvailableString += dropOptions.get(i) + ": " + String.format("%.2f", measurementsAvailable[i]) + "   ";
  }
  // Change the text displayed to the newest message
  setupControl.get(Textlabel.class, "measurementsLabel").setText(measurementsAvailableString);
}