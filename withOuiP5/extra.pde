

// Draw action Arena. TUNNEL MADE OF FRAMES/RECTS
void actionArena(){
  pushMatrix();
  translate(0, 0, 0); 
  noFill();
  strokeWeight(3);
  stroke(255);
  rect(-DIMX/2, -DIMY/2, DIMX, DIMY); // action arena 
  // Update the array with data from sound. "sound0"
  frameAlfa.append(int(map(sound0, 0,1,10,255)));
  // erase the las vallue to keep the array always with the same size   
  if (frameAlfa.size() > 20) { frameAlfa.remove(0);}


 for(int i=0; i<20; i++){    
    float alfa= frameAlfa.get(int(map(i,0,19,19,0)));
   // if(ThreeD)alfa=map(alfa, 50,255,10,100);
    stroke(255,alfa);
    translate(0, 0, 200);
    rect(-DIMX/2, -DIMY/2, DIMX, DIMY);  // rect tunel   
 }  
  popMatrix();   
}

////////////////////////////////////////////////////////////////////////


// CREATING BOIDS
void addBoids(){
   //set the initial location as 0,0,0 
    if(followTarget==6) 
    {Vec3D v = new Vec3D (0,0,0); 
     //create the plethora agent!
    Ple_Agent pa = new Ple_Agent(this, v); 
    //generate a random initial velocity
    Vec3D initialVelocity = new Vec3D (random(-1, 1), random(-1, 1), 0); 
    //set initial velocity
    pa.setVelocity(initialVelocity);    
   //add the agents to the list 
    boids.add(pa); 
}
    else { 
    Vec3D v = new Vec3D (0,(height/2)-1,0); 
    Ple_Agent pa = new Ple_Agent(this, v);   
       //generate a random initial velocity
    Vec3D initialVelocity = new Vec3D (random(-1, 1), random(-1, 1), 0); 
    //set initial velocity
    pa.setVelocity(initialVelocity);    
   //add the agents to the list 
    boids.add(pa); 
}
      
   // actualize var that counts nr of boids.
    nrBoids++; 
   //println ("Adding Boids "+nrBoids);
   }
   
////////////////////////////////////////////////////////////////////////
   
// REMOVING BOIDS

void removeBoids(){
  boids.remove(nrBoids-1);
  nrBoids--; 
 // println ("Removing Boids "+nrBoids);
}

////////////////////////////////////////////////////////////////////////

// Target nr 5. Boids separate in two groups and follow a duet moving in circles.

int alfaTemp=0; // var to smooth the color of the big circle

void DuetMovingTargets() {
  
       noStroke();
      // fill(150,map(sound1,0,1,5,200));
     //  pushMatrix();
     //  translate(0,0,-100);
     //  ellipse(0,0,600,600);
     //  popMatrix();
    //   noFill();
       stroke(255);
       strokeWeight(3);
       SepF=constrain(SepF,7,10);
       MaxSpeed=constrain(MaxSpeed,1,10);
       float r=180;
       targetD.x=r *cos(theta);
       targetD.y=r*sin(theta);
       targetE.x=r *cos(theta-PI);
       targetE.y=r*sin(-theta);
        
       noFill();
        stroke(200);
       line(targetD.x,targetD.y,0,0);
       line(targetE.x,targetE.y,0,0);
    /*   line(-DIMX, 0, targetD.x,targetD.y);
       line(DIMX, 0, targetE.x,targetE.y);
       line(-DIMX, 0, targetE.x,targetE.y);
       line(DIMX, 0, targetD.x,targetD.y);*/
       fill(0);
       ellipse(targetD.x,targetD.y,280,280);
       ellipse(targetE.x,targetE.y,280,280);
       
  
}

//sending OSC to Eli

void sendZoomIn(){

  OscMessage myMessage = new OscMessage("/zoomin");
  myMessage.add(1); /* add an int to the osc message */
 /* send the message */
  oscP5.send(myMessage, myRemoteLocation); 
 zoomIn=false;
 //zoomOut=true;
}

// sending OSC msg to trigger specific sounds

void sendZoomOut(){

  OscMessage myMessage = new OscMessage("/zoomout");
  myMessage.add(1); /* add an int to the osc message */
 /* send the message */
  oscP5.send(myMessage, myRemoteLocation); 
 //zoomOut=false;
  zoomIn=true;
  println("out "+myMessage);

}

void sendFlatten(){

  OscMessage myMessage = new OscMessage("/flatten");
  myMessage.add(1); /* add an int to the osc message */
 /* send the message */
  oscP5.send(myMessage, myRemoteLocation);
 flatten=false; 

}

