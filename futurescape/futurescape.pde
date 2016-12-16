 import java.util.Collections;
// main sketch

// FUTURESCAPE - adapted from ...

//  GSD 6349 Mapping II : Geosimulation
//  Havard University Graduate School of Design
//  Professor Robert Gerard Pietrusko
//  <rpietrusko@gsd.harvard.edu>
//  (c) Fall 2016 
//  Please cite author and course 
//  when using this library in any 
//  personal or professional project.

// new Firescape class - governs landscape
Firescape scape;

Herd herd;               // collection of cows
int popSize = 20;        // and the herd size we use to initialize them

// N.B. swatches are set up for a 4x4 grid
// screen + cell dimension info
int wScape = 125;
int hScape = 125;
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
   
    size(500,500);
    frameRate(10);  
    
    scale = width/wScape;  // get the scale
    displayMode = 'N';     // start in normal mode
    
    gMass = 0;
    tMass = 0;
    cMass = 0;
    
    scape = new Firescape( wScape, hScape );
    herd = new Herd();
    
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
    
  background(0);
  
  // run and draw the landscape on the screen
  scape.runScape();
  scape.growScape();
  
  // run and draw cows
  herd.run();
}