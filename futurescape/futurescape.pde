 import java.util.Collections;
// main sketch

### futurescape

brian ho and oliver curtis

a project for

//  GSD 6349 Mapping II : Geosimulation
//  Havard University Graduate School of Design
//  Professor Robert Gerard Pietrusko
//  <rpietrusko@gsd.harvard.edu>
//  (c) Fall 2016
//  Please cite author and course
//  when using this library in any
//  personal or professional project.


// GUIDE + README:

// futurescape is an interactive simulation of an imagined ecology
// for the high desert forests land areas near Flagstaff, Arizona. 
// in the futurescape, the current fire regime — defined by frequent
// severe fires across the high density, low homogeneity Ponderosa
// Pine forests - is dynamically changed by the addition of smart
// harvesting landings in the forest and holistic grazing ranches
// on the grassland. the combination of these strategies helps to put
// two natural systems into healthy competition.

// futurescape utilizes GIS and other real-world data sources for the
// topography, soil conditions and lighting frequency; it simulates with
// a combined celluar automata and agent-based model.

// keypresses:
// 1  normal view
// 2  fuel loading view
// 3  tree mass view
// 4  grass mass view
// 5  water def / growth rates view
// 6  tree vs. grass view
// 7  hillshade view

// l  lighting mode — able to start fires with mouse click
// h  harvest landing mode - place forest landings
// f  fence mode - start drawing fence for rangeland with clicks, right-click closes fence (BUGGY)
// s  put out fires
// c  add a cow



Firescape scape;         // new-ish Firescape class - governs landscape

Herd herd;               // collection of cows
int popSize = 20;        // and the herd size we use to initialize them

ArrayList<java.awt.Polygon> fences;


// N.B. swatches are set up for a 4x4 grid — this helps reduce computational complexity for CA
// screen + cell dimension info
int wScape = 250;
int hScape = 250;
float scale;

int month;                             // keeps track of time
boolean seasons    = false;            // does the food grow in seasons

//float growthRate1  = 90;             // season 1 growth rate
//float growthRate2  = 90;             // season 2 growth rate
//float polluteRate  = 0.1;            // pollution rate
//float foodCollapse = 2;              // pollution threshold that collapses food
//float recoverRate  = 0.998;          // rate that pollution decays

//float northMound  = growthRate1;
//float southMound  = growthRate2;

// char variables serve as flags for status
char displayMode;
char action;

// ints hold biomass content of world
int gMass;
int tMass;
int cMass;


//////////////////////////////////////////////
void setup()
{
   
    size(1000,1000);
    frameRate(10);  
    
    scale = width/wScape;  // get the scale
    displayMode = 'N';     // start in normal mode
    
    gMass = 0;
    tMass = 0;
    cMass = 0;
    
    scape = new Firescape( wScape, hScape );
    herd = new Herd();
    fences = new ArrayList<java.awt.Polygon>();
    
    // make cows
    // fill the ArrayList with popSize number of agents
    for( int n = 0; n < popSize; n++ )
    { 
        int   vision = round( random( 20, 30 ) );    // vision is randomly distributed between 1 and 6
        float graze  = random( 100, 200 );           // metabolic rate is randomly distributed between 1 and 4
        float ruminate  = random( 0.01, 0.05 );      // metabolic rate is randomly distributed between 1 and 4
        
        Cow c = new Cow( wScape, hScape, graze, ruminate, vision, scape );
        herd.addCow( c );
    }
};

//////////////////////////////////////////////
void draw()
{
  clear();
  
  // increment months as necessary
  if ( frameCount % 30 == 1 )
  {
      month = ((frameCount/30) % 12)+1;
      scape.cycleDefs( month-1 );
      println("-----------------------");
      println(frameCount, "MONTH", month);
      println("G", gMass, "T", tMass, "C", cMass, "SUM", gMass+tMass+cMass);
  }
  
  // INTERACTIONS - see Firescape.drawScape() for details
  if ( keyPressed && key == '1' ){ displayMode = 'N';}
  if ( keyPressed && key == '2' ){ displayMode = 'F';}  
  if ( keyPressed && key == '3' ){ displayMode = 'T';} 
  if ( keyPressed && key == '4' ){ displayMode = 'G';}
  if ( keyPressed && key == '5' ){ displayMode = 'D';}
  if ( keyPressed && key == '6' ){ displayMode = 'E';}
  if ( keyPressed && key == '7' ){ displayMode = 'V';}
  
  if ( keyPressed && key == 'l' ){ action = 'L'; println("Lightning mode");}
  if ( keyPressed && key == 'h' ){ action = 'H'; println("Harvest landing mode");}
  if ( keyPressed && key == 'f' ){ action = 'F'; println("Fence mode");}
  if ( keyPressed && key == 'c' ){ action = 'C'; println("Cow mode");}
  
  // INTERACTIONS FOR FENCES
  if ( mousePressed && action == 'F')
   { 
    int scapeX = floor(mouseX/scale);
    int scapeY = floor(mouseY/scale); 
    if ( scape.getTree()[scapeX][scapeY] == -9999 || inFence(mouseX, mouseY)){}
    else
    {
    println("ADDING FENCE");
    java.awt.Polygon f = new java.awt.Polygon();
    fences.add(f);
    f.addPoint(mouseX, mouseY);
    action = 'G';
    }
   }
   if (mousePressed && action == 'G' && fences.size() >= 1)
   {  
      int scapeX = floor(mouseX/scale);
      int scapeY = floor(mouseY/scale); 
      if ( scape.getTree()[scapeX][scapeY] == -9999 /*|| inFence(mouseX, mouseY) */){}
      else{
      fences.get(fences.size()-1).addPoint(mouseX, mouseY); 
      }
   }
   if( mousePressed && mouseButton == RIGHT & fences.size() >= 1 && action == 'G')
   {  
      int scapeX = floor(mouseX/scale);
      int scapeY = floor(mouseY/scale); 
      if ( scape.getTree()[scapeX][scapeY] == -9999 /*|| inFence(mouseX, mouseY)*/ ){}
      else {
       println("CLOSING FENCE");
       fences.get(fences.size()-1).addPoint(mouseX, mouseY);
       action = 'N';
      }
   }
   
  if (mousePressed && action == 'C' )
   {  
        int   vision = round( random( 20, 30 ) );    // vision is randomly distributed between 1 and 6
        float graze  = random( 100, 200 );           // metabolic rate is randomly distributed between 1 and 4
        float ruminate  = random( 0.01, 0.05 );      // metabolic rate is randomly distributed between 1 and 4
        
        Cow c = new Cow( wScape, hScape, graze, ruminate, vision, scape, mouseX, mouseY );
        herd.addCow( c );
   }

  
  background(0);
  
  // run and draw the landscape on the screen
  scape.runScape();
  scape.growScape();
  
  // run and draw cows
  herd.run();
  
  // draw current fence
  if (fences.size() >= 1){
    java.awt.Polygon f = fences.get(fences.size()-1); {
      if (action == 'G'){
        fill(0,0,0,50);
        stroke(0,0,0,150);
      beginShape();
      for (int i = 0; i < f.npoints; i++) {
       if ( i < f.npoints) {vertex(f.xpoints[i], f.ypoints[i]);}
      }
      vertex(mouseX, mouseY); endShape(CLOSE);
      }
    }
  }
}
////////////////
boolean inFence(int x, int y) {
  for ( java.awt.Polygon f : fences) {
    if (f.contains(x,y)){
      return true;
      };
    }
    return false;
  }
  
  