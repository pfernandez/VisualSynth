/*
Sets up on-screen or midi conrols depending
on selection in setup() function.
*/

import controlP5.*;

int nControls      = 19;  // the number of variable controllers, i.e. sliders or knobs
int nNotes         = 17;  // the number of buttons or midi keys
int fineTuneIndex  = 17;  // slider for tweaking note intervals or midi pitch bender

// dependent global variables
float[] controls       = null;
String[] controlLabels = null;
float[] controlMins    = null;
float[] controlMaxs    = null;
float[] notes          = null;
String[] noteLabels    = null;
int[][] uniqueCCs      = null;
int noteIndex          = 0;
ControlP5 cp5;

// setup midi controls if available, otherwise use controlP5
void setupControls( String controlType ) {
  
  
  /* General settings for both on-screen and midi controls
  -----------------------------------------------------------------*/

  String[] controlLabelVals = {
    "red", "green", "blue", "fill", "background", "fade",
    "translate x", "translate y", "translate z",
    "rotate x", "rotate y", "rotate z",
    "x diameter", "y diameter",
    "translate-2 x", "translate-2 y", "translate-2 z",
    "fine-tune interval", "framerate"
  };
  controlLabels = controlLabelVals;
  
  float[] controlVals = {
    0, 0, 0, 0.1 * 255, 0.98 * 255, 0.5 * 255,
    0.5 * width, 0.5 * height, 0,
    0, 0, 0,
    0.5 * width, 0.5 * width,
    0, 0, 0,
    0, 30
  };
  controls = controlVals;
  
  float[] controlMinVals = {
    0, 0, 0, 0, 0, 255,
    0, height, - 4.0 * width,
    0, 0, 0,
    0, 0,
    -width, -height, -width,
    -1, 5
  };
  controlMins = controlMinVals;
                           
  float[] controlMaxVals = { 
    255, 255, 255, 255, 255, 0,
    width, 0, 0.5 * width,
    TWO_PI, TWO_PI, TWO_PI,
    width, width,
    width, height, width,
    1, 80
  };
  controlMaxs = controlMaxVals;

  String[] noteLabelVals = {
    "1",     "1/4",   "1/9",   "1/16",
    "1/25",  "1/36",  "1/49",  "1/64",
    "1/81",  "1/100", "1/121", "1/144",
    "1/169", "1/196", "1/225", "1/256"
  };
  noteLabels = noteLabelVals;
  
  float[] noteVals = {
    1.,     1/4.,   1/9.,   1/16.,
    1/25.,  1/36.,  1/49.,  1/64.,
    1/81.,  1/100., 1/121., 1/144.,
    1/169., 1/196., 1/225., 1/256.,
    1/289.
  };
  notes = noteVals;
  
  /* End general settings
  -------------------------------------------------------------*/
  

  // put controllers on the screen if selected
  if( "screen" == controlType ) {
        
    cp5 = new ControlP5( this );
    
    // set up controls
    for( int i = 0; i < nControls; i++ ) {
      cp5.addSlider( "controls" + i )
      .setPosition( 10, i * 24 + 14 )
      .setSize( 100, 10 )
      .setRange( controlMins[i], controlMaxs[i] )
      .setValue( controls[i] )
      .setCaptionLabel( controlLabels[i] )
      .setColorCaptionLabel( 93342 )
      .setId( i )
     ;
    }
    // set up buttons
    for( int i = 0; i < nNotes - 1; i++ ) {
      cp5.addButton( "notes" + i )
       .setPosition( ( width - nNotes * 40 ) + i * 40, height - 70 )
       .setSize( 30, 60 )
       .changeValue( notes[i] )
       .setCaptionLabel( noteLabels[i] )
       .setId( i )
       ;
    }
    // add a label to the row of buttons
    cp5.addTextlabel( "label" )
       .setText( "INTERVAL" )
       .setPosition( width - nNotes * 40 - 3, height - 80 )
       .setColorValue( 93342 )
       ;
  }   
  // set up midi if selected
  else if( "midi" == controlType ) {
    import rwmidi.*;
    MidiInput input   = RWMidi.getInputDevices()[0].createInput( this );
    MidiOutput output = RWMidi.getOutputDevices()[0].createOutput();
    println( "Midi device list:" );
    println( RWMidi.getInputDeviceNames() );
    println( "Input: "+input.getName() );
    println( "Output: "+output.getName() );
    
    /*
    Midi CC numbers might be any integer. However, we need values of
    1, 2, ..., N. Map the midi values here by putting each CC number
    into the index of an array.
    */
    int numCCs = nControls;
    int[] ccValues = new int[numCCs];
    for( int i = 0; i < numCCs; i++ ) {
      // just filling it with monotonic integers for now
      ccValues[i] = i + 1;
    }
    // overwriting with unique values where necessary
    ccValues[ccValues.length - 2] = 33;  // this is my pitch bend wheel
    ccValues[ccValues.length - 1] = 34;  // this is my modulation wheel
    
    // pick out only non-montonic values to save time
    // while determining which CC was triggered
    int[][] uniqueCCVals = new int[nControls][2];
    int nUniqueCCs = 0;
    for( int i = 0; i < numCCs; i++ ) {
      if( i + 1 != ccValues[i] ) {
        uniqueCCVals[nUniqueCCs][0] = i;  // the index of our controller
        uniqueCCVals[nUniqueCCs][1] = ccValues[i];  // the CC of our controller
        nUniqueCCs++;
      }
    }
    uniqueCCs = new int[nUniqueCCs][2];
    arrayCopy( uniqueCCVals, uniqueCCs, nUniqueCCs );  // put it the global array
    
    // print controller info
    println( "\nAvailable controls:" );
    for( int i = 0; i < nControls; i++ ) {
      println( (i+1) + ": " + controlLabels[i] + ", [" +
              controlMins[i] + ", " + controlMaxs[i] + "]");
    }
  }
  else println( "Argument of \"midi\" or \"screen\" required." );
}

/*
Thanks to andreas.schlegel on the Processing forums for providing the
base code for the following function.
http://forum.processing.org/topic/change-array-variable-with-controlp5
*/
// ControlP5 workaround allowing access to controls stored in an array
void controlEvent( ControlEvent theEvent ) {
  if( theEvent.isController() ) {
    if( theEvent.controller().name().startsWith( "controls" ) ) {
      int id = theEvent.controller().id();
      if ( id >= 0 && id < nControls )
        controls[id] = theEvent.value();
    }
    else if ( theEvent.controller().name().startsWith( "notes" ) ) {
      int id = theEvent.controller().id();
      if ( id >= 0 && id < nNotes ) {
        cp5.getController( "controls" + fineTuneIndex ).setValue( 0 );    
        noteIndex = id;
      }
    }
  }
}

// midi signals from keys
void noteOnReceived( Note note ) {
  println( "Note on: " + note.getPitch() + ", velocity: " + note.getVelocity() );
}
void noteOffReceived( Note note ) {
  println( "Note off: " + note.getPitch() );
}

// midi signals from other controllers
void controllerChangeReceived( rwmidi.Controller controller ) {
  int ccIndex = controller.getCC() - 1;
  int signal  = controller.getValue();
  for( int i = 0; i < uniqueCCs.length; i++ ) {
      if( ccIndex == uniqueCCs[i][1] - 1 ) {
        ccIndex = uniqueCCs[i][0];
      }
    }
  if( ccIndex < nControls ) {
    controls[ccIndex] = map( signal, 0, 127, controlMins[ccIndex],
                             controlMaxs[ccIndex] );
    //println( "Controller: " + (ccIndex+1) + ", value: " + controls[ccIndex] );
  }
}
