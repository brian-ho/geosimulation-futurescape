import java.util.Collections;
// main sketch

Firescape scape;

int wScape = 50;
int hScape = 50;

ArrayList< cow > herd;  // an ArrayList that holds instances of our sugarscape agent
int popSize = 20;        // and the herd size we use to initialize them

boolean seasons    = false;          // does the food grow in seasons
float growthRate1  = 0.01;           // season 1 growth rate
float growthRate2  = 0.01;           // season 2 growth rate
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
    scape.addFoodPoint( 15, 40, 6, 20 );  // add a food mound at x,y location [15,40] 
    scape.addFoodPoint( 40, 15, 6, 20 );  // add a food mound at x,y location [40,15]
    
    scape.addGrowthRate(15, 40, southMound, 18);
    scape.addGrowthRate(40, 15, northMound, 18);
    scape.alpha       = polluteRate;
    scape.beta        = foodCollapse;
    scape.recoverRate = recoverRate;
    
    scape.growFood();
  
    herd = new ArrayList< cow >();
    
    // fill the ArrayList with popSize number of agents
    for( int n = 0; n < popSize; n++ )
    { 
        int   vision = round( random( 20, 30 ) );    // vision is randomly distributed between 1 and 6
        float metab  = round( random( 1, 4 ) );  // metabolic rate is randomly distributed between 1 and 4
        float metab2  = round( random( 1, 4 ) );  // metabolic rate is randomly distributed between 1 and 4
      
        herd.add( new cow( wScape, hScape, metab, metab2, vision ) );
    }
};


void draw()
{
  println();
  println(frameCount);
  
  background(0);
  noStroke();
  
  scape.growFood();
  scape.drawScape();
  
  
  // reorder the herd on each time step so they are updated
  // in a random order
  Collections.shuffle(herd);
  
  // draw the landscape on the screen 
  //scape.drawScape();
  
  // for every ScapeAgent in herd: assign to temporary
  // instance "p." check if p is alive, if so, update it and draw it
  // then on to the next one
  
  for( cow c : herd )
  {
      if( c.alive) 
      {
        c.update(scape);
        c.drawMyself();
      }
  }    
}