//soundFreq  low-mid-high, receiving from OSC
float sound0=0.0;
float sound1=0.0;
float sound2=0.0;
float peak=0.0;  // soudn Peak
float pitch= 0.0; // pitch from the WII
float acc=1.0; // accelaration from the WII

boolean follow; // follow path, or flock around
float MaxSpeed=3; // maxspeed for the boids
//boids parameters (coehsion, aligment, separation)
float Cohe=70;
float Alig=25;
float Sep=24;
float CoheF=1.33;
float AligF=1.59;
float SepF=2.5;

float circleAtract=20; // vall that defines how close the boids are from the path


int followTarget=0; // which target should the boids follow
int zoom=663; //move camera

float theta=0; //receinving LFO from VDMX

boolean lines=false; // Lines connecting boids. Plexus kind of thing
float linesMin=16; //lines Min and Max Range. 
float linesMax=18; //lines Min and Max Range.

float followDirection = 0;

boolean ThreeD=false; //checks if planes are 2D or 3D
float rotX=0; // var to control de rotating of the plane to #3d
float pan=0; // var to control the panning for the 3d view

boolean flash=false; // a flash on the top of the screen.
float thetaFlash=0; // val to pulse the light on the flash.
float pulseFlash=0;//  val to pulse the light on the flash.

boolean zoomIn=false; // boolian to check that I only send it once to eli
boolean zoomOut=true; // boolian to check that I only send it once to eli
boolean flatten=true; // boolian to check that I only send it once to eli

float circleAlpha1; // vals to smooth the alpha color for circles on target4
float circleAlpha2=0.0; // vals to smooth the alpha color for circles on target4

///////////////////////////////////////////////////////////////

// Keyboard
void keyPressed () { 

  if (key == 'a' ) addBoid=!addBoid;    // addBoid 
  if (key == 'r' ) removeBoid=!removeBoid;   // remove Boids

  if (key == '0') followTarget=0; // Flock Around
  if (key == '1') followTarget=1; // Target Center
  if (key == '2') followTarget=2; // Target Top, offscreen
  if (key == '3') followTarget=3; // Target Top&Botton offscreen
  if (key == '4') followTarget=4; // Target Circle
  if (key == '5') followTarget=5; // Duet 2 moving targets
  if (key == '6') followTarget=6; // 3d Target

  if (key == 'q')   //cam.pan(0,-200);
  if (key == 'e')   // zoom in
  if (key == 'e')   // bend 3d
  if (key == 'r') {  // reset pos
    cam.setDistance(885);
    cam.setRotations(-1,0,0);
    ThreeD=false;
  }
  if(key == 'z') {
   
    for (Ple_Agent pa : boids) {
   Vec3D initialVelocity = new Vec3D (random(-1, 1), random(-1, 1), random(-1, 1)); 
    //set initial velocity
    pa.setVelocity(initialVelocity); 
    }
  }
  println(key);
}

///////////////////////////////////////////////////////////////
// RECEIVING OSC

void oscEvent(OscMessage theOscMessage) {
  
  //////////////////////////////////////////////
  //////RECEIVING SOUND FREQS  LOW/MID/HIG + PEAK
  if (theOscMessage.checkAddrPattern("/sound0")==true) {
    float val=theOscMessage.get(0).floatValue(); 
    sound0=val;  
    SepF=map(val, 0, 1, 1, 10);
    SepF=constrain(SepF, 1, 10);
  }
    if (theOscMessage.checkAddrPattern("/sound1")==true) {
    float val=theOscMessage.get(0).floatValue();    
    sound1=val;
    AligF=map(val, 0, 1, 0, 10);
    AligF=constrain(AligF, 2, 8);
  }
  if (theOscMessage.checkAddrPattern("/sound2")==true) {
    float val=theOscMessage.get(0).floatValue();
    sound2=val;
    MaxSpeed=map(val, 0, 1, 0, 8);
    MaxSpeed=constrain(MaxSpeed, 0.5, 8);
    //println(aSepF);
  }
  if (theOscMessage.checkAddrPattern("/soundPeak")==true) {
    float val=theOscMessage.get(0).floatValue();
    peak=val;
  }  
  
   //////////////////////////////////////////////
  ////// PARAMETERS FROM VDMX
  
    if (theOscMessage.checkAddrPattern("/cohe")==true) {
    float val=theOscMessage.get(0).floatValue();   
    Cohe=val;
  }      
    if (theOscMessage.checkAddrPattern("/coheF")==true) {
    float val=theOscMessage.get(0).floatValue();   
    CoheF=val;
  } 
    if (theOscMessage.checkAddrPattern("/alig")==true) {
    float val=theOscMessage.get(0).floatValue();   
    Alig=val;
    println(Alig);
  } 
    if (theOscMessage.checkAddrPattern("/sep")==true) {
    float val=theOscMessage.get(0).floatValue();   
    Sep=val;
  } 
    if (theOscMessage.checkAddrPattern("/lfo")==true) {
    float val=theOscMessage.get(0).floatValue();   
    theta=val;
  } 
    if (theOscMessage.checkAddrPattern("/direction")==true) {
    float val=theOscMessage.get(0).floatValue();   
    followDirection=val;
  } 
  
    if (theOscMessage.checkAddrPattern("/addBoid")==true) {
    //println(theOscMessage);
    int val=theOscMessage.get(0).intValue();
    if (val==1)addBoid=true;
    if (val==0)addBoid=false;   
  } 
    if (theOscMessage.checkAddrPattern("/removeBoid")==true) {
    int val=theOscMessage.get(0).intValue();
    if (val==1)removeBoid=true;
    if (val==0)removeBoid=false;
  }
     if (theOscMessage.checkAddrPattern("/backAlpha")==true) {
    float val=theOscMessage.get(0).floatValue();
    trace=int(map(val, 0,1,0,255));
  }
    if (theOscMessage.checkAddrPattern("/fade")==true) {
    float val=theOscMessage.get(0).floatValue();
    fade=int(map(val, 0,1,0,255));
  }
  ////WII FROM VDMX
   if (theOscMessage.checkAddrPattern("/wiiPitch")==true) {
    float val=theOscMessage.get(0).floatValue();
    pitch=map(val, 0, 1, 0, 100);
    pitch=constrain(pitch, 0, 100); 
  }
    if (theOscMessage.checkAddrPattern("/wiiAcc")==true) {
    float val=theOscMessage.get(0).floatValue();
    acc=val;
  }
    if (theOscMessage.checkAddrPattern("/maxSpeed")==true) {
    float val=theOscMessage.get(0).floatValue();
    MaxSpeed=val;
  }
//// LINES
  if (theOscMessage.checkAddrPattern("/linesMin")==true) {
    float val=theOscMessage.get(0).floatValue();
    linesMin=map(val, 0,1,0,50);
  }
   if (theOscMessage.checkAddrPattern("/linesMax")==true) {
   float val=theOscMessage.get(0).floatValue();
   linesMax=map(val, 0,1,0,50);
   println("MAX "+linesMax);   
  }
  
   if (theOscMessage.checkAddrPattern("/lines")==true) {
    int val=theOscMessage.get(0).intValue();
    if (val==1)lines=true;
    if (val==0)lines=false;
   println(lines);  
   }
  
  //zoom
  if (theOscMessage.checkAddrPattern("/zoom")==true) {
    int val=theOscMessage.get(0).intValue();
    zoom=val;
    cam.setDistance(zoom,10000);
    println("ZOOOM    "+val);
    
    if(zoomIn) sendZoomIn();
    else sendZoomOut();
    
    
    
  }  
  
  //Rotate the plane into 3D
  if (theOscMessage.checkAddrPattern("/3d")==true) {
    //int val=theOscMessage.get(0).intValue();  
    cam.setDistance(1000,5000);
   // cam.setRotations(-1.3,0,0);   
    ThreeD=true;   
    if(flatten) sendFlatten();
  }  
  
    if (theOscMessage.checkAddrPattern("/followTarget")==true) {
    int val=theOscMessage.get(0).intValue();
    followTarget=val;
  }
  
      if (theOscMessage.checkAddrPattern("/circleAtract")==true) {
      float val=theOscMessage.get(0).floatValue();
     circleAtract=map(val,0,1,0,100);
      println(circleAtract);
  }

  
  if (theOscMessage.checkAddrPattern("/flash")==true) {
  int val=theOscMessage.get(0).intValue();
    println(val);
if(val==1) flash=true;
if(val==0) flash=false;
  }
}

