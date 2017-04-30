// When displaying traces (the traceDisplay page) the HUD will be overlaid
// The HUD provides information to the user, and has clickable controls and options

ControlP5 hudControl;
CallbackListener sliderListener;
CallbackListener colorWheelListener;
Slider speedSlider;
ColorWheel colorWheel;
Button hideButton;
Button returnToSetup;
Textfield xAxisTextfield;
Textfield yAxisTextfield;
Textfield zAxisTextfield;
Button setxAxis;
Button setyAxis;
Button setzAxis;

static final int HIDE = 2;
boolean hideFirstClick; // When we switch to the HUD, all of the buttons get clicked (which we don't want).
boolean hudIsHidden = false; // Track whether or not the HUD is hidden
static final int RETURNTOSETUP = 3;
boolean returnToSetupFirstClick; // When we switch to the HUD, all of the buttons get clicked (which we don't want).
color traceDisplayBckgrnd = color(255,255,255);
// The below spacing seems to be pretty useful
int spacingX = 45;
int spacingY = 30;

// Create everything that will go on the HUD
void setupHUD() {
  
  //println("Setting up HUD"); // Debug
  
  hideFirstClick = false; // When we switch to the HUD, all of the buttons get clicked (which we don't want).
  hudIsHidden = false; // Track whether or not the HUD is hidden
  returnToSetupFirstClick = false; // When we switch to the HUD, all of the buttons get clicked (which we don't want).
  
  hudControl = new ControlP5(this);
  
  // ~ Add Hide Button ~  
  // create a new button with display text 'Hide'
  hideButton = hudControl.addButton("Hide")
    .setValue(HIDE)
    .setSize(100,19)
    ;
  hideFirstClick = true; // Our fake click has passed
  println("Width: " + width + " drawing the hide button at " + (width - 3 * spacingX) +", " + spacingY);
  // ~ Add ReturnToSetup Button ~  
  // create a new button with display text 'Return to Setup'
  returnToSetup = hudControl.addButton("ReturnToSetup")
    .setValue(RETURNTOSETUP)
    .setSize(100,19)
    ;
  returnToSetupFirstClick = true; // Our fake click has passed
  
  // ~ Color Selection ~
  // for changing the background color
  colorWheel = hudControl.addColorWheel("bckgndColor" , width - 3 * spacingX , 3 * spacingY, 100 ).setRGB(traceDisplayBckgrnd);
  
  // ~ Speed Control Slider ~
  // add a horizontal slider
  speedSlider = hudControl.addSlider("speed")
     .setRange(1,100)
     ;
     
  // ~ Custom Axis Limits ~
  // Textfields and submit buttons
  PFont textAreaFont = createFont("Calibri",18);
  xAxisTextfield = hudControl.addTextfield("X Axis Limit")
     .setText("Axis Limit")
     .setSize(80,20)
     .setFont(textAreaFont)
     .setColor(color(255,255,255))
     ;
  yAxisTextfield = hudControl.addTextfield("Y Axis Limit")
     .setText("Axis Limit")
     .setSize(80,20)
     .setFont(textAreaFont)
     .setColor(color(255,255,255))
     ;
  zAxisTextfield = hudControl.addTextfield("Z Axis Limit")
     .setText("Axis Limit")
     .setSize(80,20)
     .setFont(textAreaFont)
     .setColor(color(255,255,255))
     ;
  setxAxis = hudControl.addButton("x")
    .setValue(X_DIM)
    .setSize(20,20)
    ;   
  setyAxis = hudControl.addButton("y")
    .setValue(Y_DIM)
    .setSize(20,20)
    ;   
  setzAxis = hudControl.addButton("z")
    .setValue(Z_DIM)
    .setSize(20,20)
    ;
     
  // Make sure everything is where it should be
  positionControllers();
  
  // ~ Listening ~
  // the following CallbackListener will listen to any controlP5 
  // action such as enter, leave, pressed, released, releasedoutside, broadcast
  // see static variables starting with ACTION_ inside class controlP5.ControlP5Constants
  
  // We want to listen to the speed slider, so we can do things when the user is done adjusting it, and
  // so we can prevent the camera from moving when adjusting it
  sliderListener = new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {}
  };
  // We want to listen to the color wheel, so we can prevent the camera from moving when adjusting it
  colorWheelListener = new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {}
  };
  
  // We turn off autodraw so we can manually draw hudControl only on the HUD
  hudControl.setAutoDraw(false);
  //println("HUD created."); // Debug
}

// Places the controllers in hudControl relative to the window
// Useful for when the window changes size
void positionControllers() {
  hideButton.setPosition(width - 3 * spacingX, spacingY);
  returnToSetup.setPosition(width - 3 * spacingX, 2 * spacingY);
  colorWheel.setPosition(width - 3 * spacingX , 3 * spacingY);
  speedSlider.setPosition(width - 3 * spacingX , 7 * spacingY);
  
  xAxisTextfield.setPosition(width - 3 * spacingX , 8 * spacingY);
  setxAxis.setPosition(width - 1 * spacingX , 8 * spacingY);
  yAxisTextfield.setPosition(width - 3 * spacingX , 9 * spacingY);
  setyAxis.setPosition(width - 1 * spacingX , 9 * spacingY);
  zAxisTextfield.setPosition(width - 3 * spacingX , 10 * spacingY);
  setzAxis.setPosition(width - 1 * spacingX , 10 * spacingY);
}

// :: Handle button presses ::

// Function hide will receive changes from controller with name Hide
public void Hide(int theValue) {
  if (hideFirstClick) { // Quick fix, explained elsewhere
    if (hudIsHidden) {
      // Loop through the controllers used in the HUD, show all of them
      for (ControllerInterface c: hudControl.getAll()) {
        c.show();
      }
      hudIsHidden = false;
    } else {
      // Loop through the controllers used in the HUD, hide everything except the Hide button
      for (ControllerInterface c: hudControl.getAll()) {
        if (!c.equals(hideButton)) {
          c.hide();
        }
      }
      hudIsHidden = true;
    }
  }
}

// Function returntosetup will receive changes from controller with name returntosetup
public void ReturnToSetup(int theValue) {
  //println(""); // Debug
  if (returnToSetupFirstClick) { // Quick fix, explained elsewhere
    //println("Going back to setup display"); // Debug
    page = SETUP_DISPLAY; // Go back to the setup page
    hudControl.hide(); // Hide all of this HUD stuff
    camHandlePageChange();
    setupControl.show(); // Show the setup menu again
    bckgndColor = setupDisplayBckgndColor; // Return to the setup display background color
  }
  //println(""); // Debug
}

// Set the axis length to the value in the corresponding textfield
public void x(int theValue) {
  int tempVal = 0;
  try {
    tempVal = Integer.parseInt(xAxisTextfield.getText());
  } catch (Exception e) {
    tempVal = 0;
  }
  if (tempVal > 0) {
    setAxisLimit(X_DIM, tempVal); 
  }
}
// Set the axis length to the value in the corresponding textfield
public void y(int theValue) {
  int tempVal = 0;
  try {
    tempVal = Integer.parseInt(yAxisTextfield.getText());
  } catch (Exception e) {
    tempVal = 0;
  }
  if (tempVal > 0) {
    setAxisLimit(Y_DIM, tempVal); 
  }
}
// Set the axis length to the value in the corresponding textfield
public void z(int theValue) {
  int tempVal = 0;
  try {
    tempVal = Integer.parseInt(zAxisTextfield.getText());
  } catch (Exception e) {
    tempVal = 0;
  }
  if (tempVal > 0) {
    setAxisLimit(Z_DIM, tempVal); 
  }
}

// Debug
//public void controlEvent(ControlEvent theEvent) {
//  if ( frameCount > 1) {
//    println(theEvent.getController().getName());
//  }
//}


// :: Handle Callback (Listener) Events ::

// controlEvent(CallbackEvent) is called whenever a callback 
// has been triggered. controlEvent(CallbackEvent) is detected by 
// controlP5 automatically.

void controlEvent(CallbackEvent theEvent) {
  // -Speed Slider-
  if (theEvent.getController().equals(speedSlider)) { // Did something happen with the speed slider?
    if (theEvent.getAction() == ControlP5.ACTION_ENTER) { // Is the mouse over the slider?
      storeCamState(TRACE_DISPLAY); // For some reason, disabling the camera isn't enough, so we'll store and reset it
      cam.setActive(false); // We don't want to drag the screen when we drag the slider
    }
    if (theEvent.getAction() == ControlP5.ACTION_RELEASED) { // Did the user release the slider?
      speed = int(theEvent.getController().getValue()); // Set the speed ('time' measurements) to the value on the slider 
      // Update the 'time' axes
      setTimeDimSpeed(X_DIM, speed); // Set up the 'time' dimension for the X axis
      setTimeDimSpeed(Y_DIM, speed); // Set up the 'time' dimension for the Y axis
      setTimeDimSpeed(Z_DIM, speed); // Set up the 'time' dimension for the Z axis
      applyCamState(); // For some reason, disabling the camera isn't enough, so we'll store and reset it
    }
    if (theEvent.getAction() == ControlP5.ACTION_LEAVE) { // Is the mouse off the slider?
      cam.setActive(true); // We can go back to moving the camera when the user click-drags
      applyCamState(); // For some reason, disabling the camera isn't enough, so we'll store and reset it
    }
  }
  // -Color Wheel-
  if (theEvent.getController().equals(colorWheel)) { // Did something happen with the color wheel?
    if (theEvent.getAction() == ControlP5.ACTION_ENTER) { // Is the mouse over it?
      println("On color Wheel"); // Debug
      storeCamState(TRACE_DISPLAY); // For some reason, disabling the camera isn't enough, so we'll store and reset it
      cam.setActive(false); // We don't want to drag the screen when we drag here
    }
    if (theEvent.getAction() == ControlP5.ACTION_RELEASED) { // Did the user release the slider?
      traceDisplayBckgrnd = hudControl.get(ColorWheel.class,"bckgndColor").getRGB();
      applyCamState(); // For some reason, disabling the camera isn't enough, so we'll store and reset it
    }
    if (theEvent.getAction() == ControlP5.ACTION_LEAVE) { // Is the mouse off of it?
      println("Off color Wheel"); // Debug
      cam.setActive(true); // We can go back to moving the camera when the user click-drags
      applyCamState(); // For some reason, disabling the camera isn't enough, so we'll store and reset it
    }
  }
}


// Draw the HUD
void drawHUD() {
  // Something wrong in the hud drawing? Debugging
  cam.beginHUD();
  hudControl.draw(); // Draw the HUD stuff relative to the viewing screen, and not the 3D space.
  cam.endHUD();
}