import java.util.Collections;
// main sketch

Firescape scape;
Herd herd;

int wScape = 25;
int hScape = 25;

int popSize = 20;        // and the herd size we use to initialize them

boolean seasons    = false;          // does the food grow in seasons
float growthRate1  = 0.75;           // season 1 growth rate
float growthRate2  = 0.75;           // season 2 growth rate
float polluteRate  = 0.1;            // pollution rate
float foodCollapse = 2;              // pollution threshold that collapses food
float recoverRate  = 0.998;          // rate that pollution decays

float northMound  = growthRate1;
float southMound  = growthRate2;


void setup()
{
    size(500,500);
    frameRate(30);  
    
    scape = new Firescape( wScape, hScape );
    scape.addFoodPoint( 7, 20, 75, 20 );  // add a food mound at x,y location [15,40] 
    //scape.addFoodPoint( 40, 15, 6, 20 );  // add a food mound at x,y location [40,15]
    
    scape.addGrowthRate(7, 20, southMound, 18);
    //scape.addGrowthRate(40, 15, northMound, 18);
    scape.alpha       = polluteRate;
    scape.beta        = foodCollapse;
    scape.recoverRate = recoverRate;
    
    scape.growFood(25);
  
    herd = new Herd();
    
    // fill the ArrayList with popSize number of agents
    for( int n = 0; n < popSize; n++ )
    { 
        int   vision = round( random( 20, 30 ) );    // vision is randomly distributed between 1 and 6
        float graze  = random( 1, 2 );  // metabolic rate is randomly distributed between 1 and 4
        float ruminate  = random( 0.01, 0.05 );  // metabolic rate is randomly distributed between 1 and 4
        
        Cow c = new Cow( wScape, hScape, graze, ruminate, vision );
        herd.addCow( c );
    }
};


void draw()
{
  println("-----------------------");
  println(frameCount);
  
  background(0);
  noStroke();
  
  // run and draw the landscape on the screen 
  scape.growFood();
  scape.drawScape();
  
  herd.run();
}