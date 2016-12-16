 import java.util.Collections;
// main sketch

Firescape scape;
Herd herd;

// swatches are set up for a 4x4 grid
int wScape = 25;
int hScape = 25;
float scale;

int month;                // keeps track of time

int popSize = 20;        // and the herd size we use to initialize them

boolean seasons    = false;          // does the food grow in seasons
float growthRate1  = 90;           // season 1 growth rate
float growthRate2  = 90;           // season 2 growth rate
float polluteRate  = 0.1;            // pollution rate
float foodCollapse = 2;              // pollution threshold that collapses food
float recoverRate  = 0.998;          // rate that pollution decays

float northMound  = growthRate1;
float southMound  = growthRate2;


void setup()
{
 
    size(500,500);
    frameRate(10);  
    
    scale = width/wScape;
    
    scape = new Firescape( wScape, hScape );
    //scape.addGrassPoint( 7, 20, 75, 20 );  // add a food mound at x,y location [15,40] 
    //scape.addGrassPoint( round(random(0, wScape)), round(random(0, hScape)), round(random(1, 100)), 20 );  // add a food mound at x,y location [40,15]
    //scape.addGrassPoint( round(random(0, wScape)), round(random(0, hScape)), round(random(1, 100)), round(random(50, 75)) );
    
    //scape.addGrowthRate(7, 20, southMound, 18);
    //scape.addGrowthRate(round(random(0, hScape)), round(random(0, hScape)), random(0, 1), 18);
    scape.alpha       = polluteRate;
    scape.beta        = foodCollapse;
    scape.recoverRate = recoverRate;
    
    scape.growGrass(25);
  
    herd = new Herd();
    
    // make cows
    // fill the ArrayList with popSize number of agents
    for( int n = 0; n < popSize; n++ )
    { 
        int   vision = round( random( 20, 30 ) );    // vision is randomly distributed between 1 and 6
        float graze  = random( 100, 200 );  // metabolic rate is randomly distributed between 1 and 4
        float ruminate  = random( 0.01, 0.05 );  // metabolic rate is randomly distributed between 1 and 4
        
        Cow c = new Cow( wScape, hScape, graze, ruminate, vision );
        herd.addCow( c );
    }
};


void draw()
{
  clear();

  println("-----------------------");
  month = ((frameCount/30) % 12)+1;
  println(frameCount, "MONTH", month);
  
  background(0);
  noStroke();
  
  // run and draw the landscape on the screen
  scape.runScape();
  scape.growGrass();
  // run and draw cows
  herd.run();
}