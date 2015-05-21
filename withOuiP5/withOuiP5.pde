/*
//////////////////////////////////////////////////
Visuals for "With Oui" Audiovisual Dance Performance
Developed by Rodrigo Carvalho (Visiophone) May 2015, UT Austin - Texas.
Based on the examples from Plethora library. 
Needs Plethora, peasyCam, ToxicGeo and OSCP5 Processing Libraries.

Boids behaviour parameters (cohesion, separation, aligmenet) are audio reactive.
Audio analyze and other parameters controls are done live in a VDMX project (https://vidvox.net/)
and sent by OSC (check all the messages in controlTab and the file "vdmxLiveControl.vdmx5").

More info: www.visiophone-lab.com/
/////////////////////////////////////////////////
*/
import plethora.core.*;
import toxi.geom.*;
import peasy.*;
// OSC Receiving
import oscP5.*;
import netP5.*;

PeasyCam cam; //using peasycam
OscP5 oscP5; //OSC object 
NetAddress myRemoteLocation; // PORT SO SEND OSC MSG

ArrayList <Ple_Agent> boids; //two different families of boids

float DIMX = 1280; // dimension of the planes
float DIMY =  800;
float DIMZ = 800;
int nrBoids = 0; //Number of boids
int nrBoidsTemp=0; // to compare if nr boids have changed.
int ID=0; // id of each boid
int maxBoids=500; //nr max of boids

// cirlce paths that the boids will follow
Spline3D path1;//line to follow
Spline3D path2;//line to follow
int radius=300; // radius for the circle

//TARGETS
Vec3D targetA = new Vec3D (0,0,0); // target in the center
Vec3D targetB = new Vec3D (0,-DIMY,0); // target top of the screen
Vec3D targetC = new Vec3D (0,DIMY,0); // target botton of the screen
Vec3D targetD = new Vec3D (0,0,0); //moving targets !! ! !
Vec3D targetE = new Vec3D (0,0,0); //moving targets !! ! !
Vec3D targetF =  new Vec3D (0,0,810); // target 3D 

//Arraylist that stores the audio reactive colors of the frame border.
IntList frameAlfa = new IntList(); 

int trace = 255; // val to erase background with transparency and leave trace
int fade=0; // var that Fades everythin to black. opacy of a black rect on the top

boolean addBoid=false; // adding more boids
boolean removeBoid=false; // removing boids

void setup (){ 
  
size(int(DIMX), int(DIMY), P3D);
smooth();

oscP5 = new OscP5(this,9002); // start oscP5, port 
//myRemoteLocation = new NetAddress("127.0.0.1",8002); // SEND OSC HERE
myRemoteLocation = new NetAddress("192.168.1.10",57120); // SEND OSC HERE
//myRemoteLocation = new NetAddress("127.0.0.1",57120);

cam = new PeasyCam (this, zoom);   //start Peasy camera, inicial distance
  
boids = new ArrayList <Ple_Agent>(); //initialize the Boids' arrayList

path1=new Spline3D(); // start Spline3D
path2=new Spline3D(); // start Spline 3D
float angle=TWO_PI/30; // angle to creat the polar coordinates

// creating circular points to fill the Spline paths
  for(int i=0; i<30;i++){ 
    Vec3D v = new Vec3D((radius)*sin(angle*i),(radius)*cos(angle*i),0);
    path1.add(v);   
    Vec3D v2 = new Vec3D((radius-100)*sin(angle*i),(radius-100)*cos(angle*i),0);
    path2.add(v2);    
  }

// Arraylist start
 for(int i=0; i<20; i++){  frameAlfa.append(0); }
}



void draw(){

  //// Background
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  fill(0, trace);
  noStroke();
  rect(0,0,width,height);
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
  /////////////////////////////////////////////////////////////addBoid/////////////
  actionArena(); // draw the rectgles where the boids play
  
 if (addBoid && nrBoids<maxBoids)addBoids(); // creating boids. A Max of 400 agents
 if (removeBoid && nrBoids>0) removeBoids(); // killing boids
   
  ////////////////////////////////////////////////////////////////////////
  
  // BOIDs Behaviours
ID=0; //counting boids
for (Ple_Agent pa : boids) {
  
  if(followTarget!=4 || !ThreeD) { pa.wrapSpace(DIMX/2, DIMY/2, DIMZ);  
  //println("heii wrapping "+followTarget+" " +millis());
}// Boundaries, does not work on target 4
  pa.setMaxspeed(MaxSpeed); //Max speed 
  
  // BOIDS TARGETS  
  if(followTarget==1) {pa.seek(targetA,5);  SepF=constrain(SepF,5,10); } // Target Center
  if(followTarget==2) {if(ID%2==0) {pa.seek(targetB,5);} else {pa.seek(targetB,5);} } // Target Top, offscreen
  if(followTarget==3) {if(ID%2==0) {pa.seek(targetB,5);} else {pa.seek(targetC,5);} } // Target Top&Botton, offscreen
  
  if(followTarget==4) {   // target following lines in a circle
   MaxSpeed=constrain(MaxSpeed,1,8); 
   pa.setMaxspeed(MaxSpeed); // SET MAX SPEED
   pa.separationCall(boids, circleAtract,2); // SEPARATION, CONTROLED BY THE WIIMOTE  //MUDAR ISTO. TEM DE SER DESDE O VDMX  
   float m = followDirection; 
   // CALC SPILINES AND NEXT POSITIONS SO THE BOIDS CAN FOLLOW IT
   //dividind in 2 groups;
    if(ID%2==0){
    Vec3D fLoc = pa.futureLoc(1); //calculate future location at 50 units
    Vec3D cns = pa.closestNormalandDirectionToSpline(path1, fLoc,m); 
    pa.seek(cns, 1); //follow
    }
    else {
    Vec3D fLoc = pa.futureLoc(1); //calculate future location at 50 units
    Vec3D cns = pa.closestNormalandDirectionToSpline(path2, fLoc,-m);
    pa.seek(cns, 1); //follow
    }   
   /// CIRCLES
   noFill();
   strokeWeight(2); 
   circleAlpha1+=(map(sound0,0,1,0,255)-circleAlpha1)*0.01; // smothing the values
   circleAlpha2+=(map(sound2,0,1,0,255)-circleAlpha2)*0.01; // smothing the values
   // deforming the circle so it matches the projector. 
   stroke(180,circleAlpha1);
   ellipse(0,0,radius*2,radius*2);
   stroke(180,circleAlpha2);
   ellipse(0,0,(radius-100)*2,(radius-100)*2); 
  }  
  // target 5 -> moving targets. Duet. 
  if(followTarget==5) { DuetMovingTargets(); if(ID%2==0) {pa.seek(targetD,5);} else {pa.seek(targetE,5);}  } 
  
  // Target 3d
  if(followTarget==6) {
  //values from audio, to make trails react  
  circleAlpha1+=(map(sound0,0,1,0,255)-circleAlpha1)*0.01; // smothing the values
  circleAlpha2+=(map(sound2,0,1,0,255)-circleAlpha2)*0.01; // smothing the values
   
  pa.seek(targetF,5);  
  strokeWeight(2);
 // stroke(255,200);
 if(ID%2==0)stroke(0,255,255,map(circleAlpha1,0,255,100,255)); else stroke (255,map(circleAlpha1,0,255,100,255));
  pa.dropTrail(2,50);
  pa.drawTrail(25);
  cam.rotateY(0.000005);
  
 } 
  
  ////////////////////////////////// 
  // FLOCKING RULES. Do not flock on 4. Cohesion, Alignment, Separation, + coheForce, AligForce, sepForce)
  if(followTarget!=4) pa.flock(boids, Cohe, Alig, Sep, CoheF, AligF,SepF); 
  
  //////////////////////////////////
  ////// Draw lines connecting boids. kind of plexus
   if(lines) {
     strokeWeight(2); 
     stroke(0, 250, 255);
     pa.drawLinesInRange(boids, linesMin, linesMax); // Array, distmin, distMax 
   }
  //////////////////////////////////
  ////// DRAWING STUFF
  // colors and size of each particle  is defirent, using the ID number to map the size, 
  // Boids are divided in two groups/colors, depending if ID is even or odd
  //strokeWeight(map(ID, 0,maxBoids,8,14)); // size of the point
  strokeWeight(map(ID, 0,maxBoids,6,10));
 if(ID%2==0) {stroke(0, 255, 255);} else {stroke(255, 255, 255);} // dividing in 2 groups, 2 colors
  
   pa.displayPoint();   
   strokeWeight(2);
   stroke(255);
   if(!lines) pa.displayDir(pa.vel.magnitude()*5);  // magnitude , line in front of the boid. not to use during plexus
  
  
  /////////////////////////////////
   pa.update(); // update boids vels and positions
   ID++; 
 } 

/// 3D, WHEN IT JUMPS TO 3D
if(ThreeD){ 
  println("inside ThreeD "+ ThreeD);
 if(pan < 600) {
 pan++;
 cam.pan(0,-0.5);
 }  
 if (rotX>-90){rotX=rotX-0.1; cam.setRotations(radians(rotX),0,0);}
//else cam.rotationY(0.01);

}


  ////////////////////////////////////////////////////////////////////////
  // OFF CAMERA HUD
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  fill(255);
 // text("FPS: "+int(frameRate), 20, 20); 
 // text("NR.BOIDS: "+nrBoids, 80, 20); 
text(nrBoids, 20, 20); 
  
  // FLASH ON THE Top
  if(flash){
   
    thetaFlash=thetaFlash+0.01;
    pulseFlash =abs(10* sin(thetaFlash));
    
   // println(theta
    
    noStroke();
    fill(255,map(pulseFlash,0,10,255,0));
    rect(0,0,width,height);
  }

  // fade to BLACK 
  fill(0, fade);
  noStroke();
  rect(0,0,width,height);
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
  ////////////////////////////////////////////////////////////


}
