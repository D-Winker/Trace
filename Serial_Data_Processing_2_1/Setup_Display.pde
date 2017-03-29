/**
 *
 */
 
import controlP5.*;
import java.util.*;

ControlP5 cp5;

Textlabel measurementsLabel;
CheckBox checkbox;
String measurementsAvailableString = "";
List dropOptions = new ArrayList<String>();
float[] oldCheckBox = new float[dimensionOptions.length];
int numTraces = 0; // How many traces have been created?
int timeDimIndex = -1; // Keep track of which index in the scrollable dropdowns in the 'Time' option. -1 indicates it was not created correctly

void setupDisplay() {
  noStroke();
  Arrays.fill(oldCheckBox, 0); // Ensure the array is empty, we start with nothing checked!
  
  cp5 = new ControlP5(this);
  
  int spacingX = 45;
  int spacingY = 30;
  
  
  // This will show what measurements are available
  measurementsLabel = cp5.addTextlabel("measurementsLabel")
                    .setText(measurementsAvailableString)
                    .setPosition(2 * 45, 30)
                    .setColorValue(255)
                    .setFont(createFont("Calibri",20))
                    ;
  
  buttons(spacingX, spacingY);
  newTraceOptions();
}

// Whenever you want a new trace, this shows all the stuff you need.  
void newTraceOptions() {
  int spacingX = 45;
  int spacingY = 30;
  checkbox = cp5.addCheckBox("checkBox")
                .setPosition(2*spacingX, 3*spacingY)
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
}

// Handle checkboxes being checked and unchecked
// When checked - create a scrollable dropdown to select the measurement for that dimension
// When unchecked - remove the dropdown
// If any mutually exlusive option is checked (like RGB or Grayscale) uncheck the others
void checkBox(float[] checkBoxVals) {
  // I'm only including this explanation once, but the below code appears all over
  // ControlP5 has this...quirk, that at startup all controllers are executed.
  // "the reason for the autostart is, lets say you want to use your controller setup for initialization, then the autostart for the controllers is required."
  // https://processing.org/discourse/beta/num_1178557523.html (I haven't seen a way to configure this; if you have, please let me know!)
  if ( frameCount > 1) {
    int spacingX = 45;
    int spacingY = 30;
    
    //println("Hello there"); // Debug
    //println("Old Checkbox; New Checkbox"); // Debug
    
    // Loop through the checkbox array and see what was just clicked
    for (int i = 0; i < checkBoxVals.length; i++) {
      //println(oldCheckBox[i] + "; " + checkBoxVals[i]); // Debug
      // Check if the checkbox we're looking at has changed state
      if (oldCheckBox[i] != checkBoxVals[i]) {
        if (checkBoxVals[i] == 1) { // If the box was just checked
        // The two below variables are used for placing the scrollable dropdown
          int rightColSpace = 0; // There are two columns of checkboxes, we need to adjust spacing for this
          int vertSpace = i / 2; // Things in the same row need the same vertical spacing
          if (i % 2 == 1) { // If it's an odd number (i.e. right column)
            rightColSpace = 8; // This number works decently
          }
          
          
          // Check if the box is among the mutually exclusive dimensions
          // If it is, we must ensure the other exclusive options are unchecked and without dropdown lists
          if (i == RED || i == GREEN || i == BLUE || i == GRAYSCALE || i == RGB_COLOR) {
            checkBoxVals[i] = 0; // Pretend this box is unchecked for the sake of the following code
            
            // Check which, if any, of the other exclusive boxes are checked
            // Then, remove the relevant scrollable dropdown, and uncheck the boxes
            if (checkBoxVals[GRAYSCALE] == 1) {
              println("Removing the "+dimensionOptions[GRAYSCALE]+" option"); // Debug
              checkBoxVals[GRAYSCALE] = 0; // Note the change
              oldCheckBox[GRAYSCALE] = 0; // Record the change
              // Clear the check
              cp5.get(CheckBox.class, "checkBox").deactivate(GRAYSCALE);
              // Remove the associated scrollable dropdown
              cp5.get(ScrollableList.class, "Available Measurements " + dimensionOptions[GRAYSCALE]).remove();
            }
            if (checkBoxVals[RGB_COLOR] == 1) {
              println("Removing the "+dimensionOptions[RGB_COLOR]+" option"); // Debug
              checkBoxVals[RGB_COLOR] = 0; // Clear the check
              oldCheckBox[RGB_COLOR] = 0; // Record the change
              // Clear the check
              cp5.get(CheckBox.class, "checkBox").deactivate(RGB_COLOR);
              // Remove the associated scrollable dropdown
              cp5.get(ScrollableList.class, "Available Measurements " + dimensionOptions[RGB_COLOR]).remove();
            } 
            // The Red, Green, and Blue options are not independent from eachother
            // so they're a special case
            if (i != RED && i != GREEN && i != BLUE) {
              if (checkBoxVals[RED] == 1) {
                println("Removing the "+dimensionOptions[RED]+" option"); // Debug
                checkBoxVals[RED] = 0; // Clear the check
                oldCheckBox[RED] = 0; // Record the change
                // Clear the check
                cp5.get(CheckBox.class, "checkBox").deactivate(RED);
                // Remove the associated scrollable dropdown
                cp5.get(ScrollableList.class, "Available Measurements " + dimensionOptions[RED]).remove();
              } 
              if (checkBoxVals[GREEN] == 1) {
                println("Removing the "+dimensionOptions[GREEN]+" option"); // Debug
                checkBoxVals[GREEN] = 0; // Clear the check
                oldCheckBox[GREEN] = 0; // Record the change
                // Clear the check
                cp5.get(CheckBox.class, "checkBox").deactivate(GREEN);
                // Remove the associated scrollable dropdown
                cp5.get(ScrollableList.class, "Available Measurements " + dimensionOptions[GREEN]).remove();
              } 
              if (checkBoxVals[BLUE] == 1) {
                println("Removing the "+dimensionOptions[BLUE]+" option"); // Debug
                checkBoxVals[BLUE] = 0; // Clear the check
                oldCheckBox[BLUE] = 0; // Record the change
                // Clear the check
                cp5.get(CheckBox.class, "checkBox").deactivate(BLUE);
                // Remove the associated scrollable dropdown
                cp5.get(ScrollableList.class, "Available Measurements " + dimensionOptions[BLUE]).remove();
              }
            }
            
            checkBoxVals[i] = 1; // Now that we're done removing things, go back to normal
          }
          
          println("Checked the "+dimensionOptions[i]+" box"); // Debug
          
          ArrayList<String> dropDownOptions = new ArrayList<String>(dropOptions); // Copy dropOptions by value. This lets us add measurement options for specific dimensions.
          if (i == X_DIM || i ==  Y_DIM || i == Z_DIM) { // Handle the 'time' option for relevant dimensions
            dropDownOptions.add("'Time'");
            timeDimIndex = dropDownOptions.size() - 1; // Note which of the options is the time dimension
          }
          
          // Create the scrollable dropdown
          cp5.addScrollableList("Available Measurements " + dimensionOptions[i])
           .setPosition((4+rightColSpace)*spacingX, (3+vertSpace)*spacingY+40*vertSpace)
           .setSize(200, 100)
           .setBarHeight(40)
           .setItemHeight(20)
           .addItems(dropDownOptions)
           ;
        } else { // The box was unchecked
          println("Unchecked the "+dimensionOptions[i]+" box"); // Debug
          // Find the relevant dropdown and remove it
          cp5.get(ScrollableList.class, "Available Measurements " + dimensionOptions[i]).remove();
        }
        oldCheckBox[i] = checkBoxVals[i]; // Remember that a box changed state
      } // Finished with box i
    } // Done looping through the checkboxes
  }
}


// :: Button Handling ::
// The button-click functions

// function addTrace will receive changes from 
// controller with name addTrace
public void addTrace(int theValue) {
  if ( frameCount > 1) { // Quick fix, explained elsewhere
    int tempColorFormat = GRAYSCALE; // Which color scheme is used for this trace. Default to grayscale.
    println("a button event from addtrace: "+theValue); // Debug
    int[] tempWhichMeasurements = new int[MAX_DIMENSIONS]; // This is for tracking which measurements were selected for which dimensions
    int tempTimeDim = -1; // Note what dimension, if any, is using the 'Time' measurement
    // Loop through all of the dropdown lists
    for (int i = 0; i < dimensionOptions.length; i++) {
      print("The " + dimensionOptions[i] + " dimension is using measurement "); // Debug
      // Check if there is a scrollable dropdown list for the dimension we're looking at
      ScrollableList relevantList = cp5.get(ScrollableList.class, "Available Measurements " + dimensionOptions[i]);
      if (relevantList != null) { // If there is a list for the dimension
        println(relevantList.getValue()); // Debug
        tempWhichMeasurements[i] = int(relevantList.getValue()); // Take the user's selection from the scrollable dropdown
        relevantList.remove(); // Cleanup the lists used for that trace
        if (i == RED || i == GREEN || i == BLUE) {
          tempColorFormat = RED;
        } else if (i == RGB_COLOR) {
          tempColorFormat = RGB_COLOR;
        }
        // Handle the 'time' measurement
        if (i == X_DIM) {
          if (int(relevantList.getValue()) == timeDimIndex) { // If the time measurement is selected
             tempTimeDim = X_DIM; // Note this dimension is using the 'Time' measurement
          }
        } else if (i == Y_DIM) {
          if (int(relevantList.getValue()) == timeDimIndex) { // If the time measurement is selected
             tempTimeDim = Y_DIM; // Note this dimension is using the 'Time' measurement
          }
        } else if (i == Z_DIM) {
          if (int(relevantList.getValue()) == timeDimIndex) { // If the time measurement is selected
             tempTimeDim = Z_DIM; // Note this dimension is using the 'Time' measurement
          }
        }
      } else { // If there isn't a list
        tempWhichMeasurements[i] = -1; // We aren't using this; we denote this with -1
        println("Woops! Guess we aren't using that dimension."); // Debug 
      }
    }
    // Clear the checked boxes
    // First, check if there are checkboxes
    CheckBox tmpBox = cp5.get(CheckBox.class, "checkBox");
    if (tmpBox != null) {
      println("Clearing checkboxes"); // Debug
      cp5.get(CheckBox.class, "checkBox").deactivateAll();
    }
    Arrays.fill(oldCheckBox, 0); // Clear out the checkbox array
    numTraces++; // Note that there's a new trace
    displayTrace("New Trace: " + numTraces); // List the new trace on screen
    traces.add(new Trace(tempWhichMeasurements, defaultTraceLength, tempColorFormat, tempTimeDim)); // Actually creating the new trace, (int[] whichMeasurements, int length)
    println("Trace added.\n----------------------------------------------------------------------------------------------\n\n"); // Debug
  }
}

// function done will receive changes from 
// controller with name done
public void done(int theValue) {
  if ( frameCount > 1) {
    println("a button event from done: "+theValue); // Debug
    //cp5.dispose(); // Clear off all of the cp5 elements we've used
    clearController(); // Clear off all of the cp5 elements we've used
    page = TRACE_DISPLAY; // Done with this page, onto the next!
    traceDisplaySetup(); // Get things ready for the switch
  }
}


// The dispose method wasn't working for me, so this is how I'll 'clear' the cp5 elements
void clearController() {
  cp5.hide(); // This hides everything
  // Okay, so I guess all the stuff technically still exists. On the bright side, you can
  // bring it back if you need to, downside, it's probably bad to leave all of these things?
  // Memory leaks? There must be a way to get all of the objects and individually dispose each one.
}

// Handles adding buttons to the screen
void buttons(int spacingX, int spacingY) {
  // create a new button with display text 'ADDTRACE'
  cp5.addButton("addTrace")
    .setValue(0)
    .setStringValue("This Test")
    .setPosition(2 * spacingX, 16 * spacingY)
    .setSize(200,19)
    ;
    
  // create a new button with display text 'DONE'
  cp5.addButton("done")
    .setValue(0)
    .setStringValue("Thistest")
    .setPosition(12 * spacingX, 18 * spacingY)
    .setSize(200,19)
    ;
}

// :: Text :: 
// Everything that exists solely to show text on screen

// Adds info about a created trace to the screen
void displayTrace(String tr) {
  measurementsLabel = cp5.addTextlabel(tr)
                      .setText(tr)
                      .setPosition(17 * 45, 30 + 30 * numTraces)
                      .setColorValue(255)
                      .setFont(createFont("Calibri",20))
                      ;
}

// When you're selecting measurements, you probably want to know what the measurements are
// This will display the current readings at the top of the screen
// It also takes care of anything else that needs measurements as they update
void availableMeasurementsDisplay(float[] measurementsAvailable) { 
  // This will populate the dropdown lists. It's a little ridiculous to do this every time we draw the measurements, but it works for now.
  // We need to know how many measurements we have before we do this, but then it really only needs to be done once.
  dropOptions.clear(); // Clear off the list so we can recreate it
  for (int i = 1; i <= numMeasurements; i++) {
    dropOptions.add(Float.toString(i));
  }
  
  measurementsAvailableString = "Available Measurements: ";
  for (int i = 0; i < measurementsAvailable.length; i++) {
    measurementsAvailableString += dropOptions.get(i) + ": " + measurementsAvailable[i] + "   ";
  }
  // Change the text displayed to the newest message
  cp5.get(Textlabel.class, "measurementsLabel").setText(measurementsAvailableString);
}