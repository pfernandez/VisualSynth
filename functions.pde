/*
Miscellaneous funcions.
*/

// translate, transform, and color ellipse in real-time
void funWithEllipse() {
  float angle = getRotationAngle();
  pushMatrix();
  fill      ( controls[0], controls[1], controls[2], controls[3] );
  stroke    ( controls[0], controls[1], controls[2] );
  translate ( controls[6],  controls[7],  controls[8] );
  rotateX   ( controls[9] * angle );
  rotateY   ( controls[10] * angle );
  rotateZ   ( controls[11] * angle );
  translate ( controls[14],  controls[15],  controls[16] );
  ellipse   ( 0, 0, controls[12], controls[13] );
  popMatrix();
}

// set frequency based on note pressed
float getRotationAngle() {
  float intervalSize = notes[noteIndex + 1] - notes[noteIndex];
  float frequency = notes[noteIndex] + map( controls[fineTuneIndex],
                                            controlMins[fineTuneIndex],
                                            controlMaxs[fineTuneIndex], 
                                            -intervalSize,
                                            intervalSize );
  return frequency * frameCount;
}

// adjust tracers
void fadeOut() {
  fill( controls[4], 1.5 * controls[5] - 127.5 );
  rect( 0, 0, width, height );
}

// adjust the timestep
void changeSpeed() {
 frameRate(controls[18]);
}

/*
Thanks to user PhiLho on the Processing forums for 
providing the outline of the following function.
http://processing.org/discourse/beta/num_1242790263.html
*/
// press any key to pause/play
boolean pause = false;
void keyPressed() {
  pause = ! pause;
  if ( pause )
    noLoop();
  else
    loop();
}
