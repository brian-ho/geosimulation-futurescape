//main sketch

// GLOBAL VARIABLES ////////////////////////////////////////////////////////
Firescape scape;

int latH = 25;
int latW = 25; 

ArrayList< cow > herd;  // an ArrayList that holds instances of our sugarscape agent
int popSize = 10;                   // and the herd size we use to initialize them

boolean seasons    = false;          // does the food grow in seasons
float growthRate1  = 0.25;           // season 1 growth rate
float growthRate2  = 0.01;           // season 2 growth rate
float polluteRate  = 0.1;            // pollution rate
float foodCollapse = 2;              // pollution threshold that collapses food
float recoverRate  = 0.998;          // rate that pollution decays

float northMound  = growthRate1;
float southMound  = growthRate2;

///////////////////////////////////////////////////////////////////////
// do once at the beginning....

void setup()
{
    size(500,500);
    frameRate(12);
    
    scape = new Firescape( 50, 50 );    // create a 50 x 50 Sugarscape
    scape.addFoodPoint( 15, 40, 6, 20 );  // add a food mound at x,y location [15,40] 
    scape.addFoodPoint( 40, 15, 6, 20 );  // add a food mound at x,y location [40,15] 
    
    scape.addGrowthRate(15, 40, southMound, 18);
    scape.addGrowthRate(40, 15, northMound, 18);
    scape.alpha       = polluteRate;
    scape.beta        = foodCollapse;
    scape.recoverRate = recoverRate;

    // initialize the ArrayList that holds our herd
    herd = new ArrayList< cow >();
    
    // fill the ArrayList with popSize number of agents
    for( int n = 0; n < popSize; n++ )
    { 
        int   vision = round( random( 1, 2 ) );    // vision is randomly distributed between 1 and 6
        float metab  = round( random( 1, 4 ) );  // metabolic rate is randomly distributed between 1 and 4
      
        herd.add( new cow( latW, latH, metab, metab, vision ) );
    }
    
};

///////////////////////////////////////////////////////////////////////
// draw() do over and over ...

void draw()
{
  
    background(0);
    noStroke();
    
    // reorder the herd on each time step so they are updated
    // in a random order
    Collections.shuffle(herd);
    
    if( seasons == true  ) scape.growFood();
    if( seasons == false ) scape.growFood( growthRate1 );
    
    
    // draw the food source on the screen
    image( scape.updatePImage(), 0, 0, width, height );  
    
    
    // this is an iterator. it allows us to loop through
    // all of the agents in herd without knowing how
    // many are there. this is helpful because every so often
    // we 'prune' or remove the ones no longer alive. using
    // ArrayList with an iterator means we don't have to keep 
    // count in order to run the scene
    
    // for every ScapeAgent in herd: assign to temporary
    // instance "p." check if p is alive, if so, update it and draw it
    // then on to the next one
    
    for( cow c : herd )
    {
        if( c.alive) 
        {
          c.update( scape );
          c.drawMyself();
        }
    }  
};