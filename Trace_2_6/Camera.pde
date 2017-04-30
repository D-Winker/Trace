// Screen resizing and switching back and forth between screens is tough with camera stuff
// So having it's own tab helps me keep things organized
PeasyCam cam; // Define our camera for looking around 3D space
CameraState traceDisplayCamState = null; // Used to save the state when leaving the camera

float[] traceDisplayCameraFocus = {width / 2, -height / 2, 0};
double traceDisplayCameraDist = (height/2.0) / tan(PI*30.0 / 180.0);
float[] traceDisplayCameraRotations = {0, 0, 0};
float[] traceDisplayCameraPos = {0, 0, 0};

PVector setupDisplayCameraFocus;

// Initialize a peasycam so we can look around in 3D
void initializeCamera() {
  // PeasyCam(PApplet parent, double lookAtX, double lookAtY, double lookAtZ, double distance);
  makeNewCamera(traceDisplayCameraFocus[0], traceDisplayCameraFocus[1], traceDisplayCameraFocus[2], (height/2.0) / tan(PI*30.0 / 180.0));
  storeCamState(TRACE_DISPLAY); // This is the initial state for the camera on the TRACE_DISPLAY
  cam.setMinimumDistance(0);
  cam.setMaximumDistance(4000);
  println("The camera has been initialized"); // Debug
}

// When changing from one page to another ...
void camHandlePageChange() {
  println("Page changing");
  // Which page have we switched to?
  switch (page) {
      case SETUP_DISPLAY: // Things to do when going to the SETUP_DISPLAY
        storeCamState(TRACE_DISPLAY); // Remember the state the camera was in for when we get back
        cam.setActive(false);
        break;
      case TRACE_DISPLAY: // Things to do when going to the TRACE_DISPLAY
        applyCamState();
        cam.setActive(true);
        println("Applying"); // Debug
        break;
      default:
        println("Something has gone horribly wrong, you've escaped the pages! Written words brought to life in this physical world!"); // Debug
        break;
    }
}

// It seems, as far as I can tell, that to get everything to work correctly between peasycam, processing, and controlP5
// we need a new camera for each new screen size
void camHandleScreenResize() {
  println("Handling screen resize"); // Debug
  switch (page) {
      case SETUP_DISPLAY:  
        setupDisplayCameraFocus = new PVector(width / 2, height / 2, 0);
        makeNewCamera(setupDisplayCameraFocus.x, setupDisplayCameraFocus.y, setupDisplayCameraFocus.z, (height/2.0) / tan(PI*30.0 / 180.0));
        cam.setActive(false);
        break;
      case TRACE_DISPLAY:
        storeCamState(TRACE_DISPLAY);
        makeNewCamera(traceDisplayCameraFocus[0], traceDisplayCameraFocus[1], traceDisplayCameraFocus[2], traceDisplayCameraDist);
        applyCamState();
        hudControl.setGraphics(this, 0, 0); // This like tells the HUD_CONTROL what to orient itself relative to
        positionControllers(); // Because these elements are positioned relative to the right side of the screen, we need to re-adjust when the screen changes size
        break;
      default:
        break;
  }
}

// Between resizing the screen, and switching between the trace and setup displays, a lot of new cameras need to be created
// Additionally, each time one is created, we need to reset the custom drag (right click) handler
// - Double clicking resets the camera to its original state. That state is different for the trace and setup displays
//   for the trace display, traces are drawn relative to the bottom left corner, making the math for drawing traces simpler
//   for the setup display, relative to the top left; this makes screen resizing much easier to handle
void makeNewCamera(double lookatX, double lookatY, double lookatZ, double lookfromDist) {
  println("Creating a new camera"); // Debug
  cam = new PeasyCam(this, lookatX, lookatY, lookatZ, lookfromDist);
  // Set the right mouse drag to pan around the screen
  PeasyDragHandler PanDragHandler = cam.getPanDragHandler();
  cam.setRightDragHandler(PanDragHandler);
  // By default, scroll is zoom, and left click is rotate
}

// When we switch back and forth between pages, or resize the display, we want the camera to remember
// where it was looking before the change. Now you may have noticed there's a CameraState object in
// peasycam! Well, this has given me better results.
void storeCamState(int whichPage) {
  println("Storing camera state"); // Debug
  switch (whichPage) {
      case SETUP_DISPLAY:  

        break;
      case TRACE_DISPLAY:
        // Remember the state the camera was in for when we get back
        traceDisplayCameraDist = cam.getDistance();
        traceDisplayCameraFocus = cam.getLookAt();
        traceDisplayCameraRotations = cam.getRotations();
        break;
      default:
        break;
  }
}

// We've stored the state of the camera at some point in the past, and now we wanna go back,
// back to the past (position and orientation).
void applyCamState() {
  println("Applying camera state"); // Debug
  switch (page) {
    case SETUP_DISPLAY:  

      break;
    case TRACE_DISPLAY:
      cam.lookAt(traceDisplayCameraFocus[0], traceDisplayCameraFocus[1], traceDisplayCameraFocus[2]);
      cam.setDistance(traceDisplayCameraDist);
      cam.setRotations(traceDisplayCameraRotations[0], traceDisplayCameraRotations[1], traceDisplayCameraRotations[2]);
      break;
    default:
      break;
}
}