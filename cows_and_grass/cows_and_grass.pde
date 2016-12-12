import java.util.Collections;
// main sketch

ArrayList< cow > herd;  // an ArrayList that holds instances of our sugarscape agent
int popSize = 1;        // and the herd size we use to initialize them

int latW = 50;
int latH = 50;
void setup()
{
    size(500,500);
    frameRate(5);  
  
    herd = new ArrayList< cow >();
    
    // fill the ArrayList with popSize number of agents
    for( int n = 0; n < popSize; n++ )
    { 
        int   vision = round( random( 20, 30 ) );    // vision is randomly distributed between 1 and 6
        float metab  = round( random( 1, 4 ) );  // metabolic rate is randomly distributed between 1 and 4
        float metab2  = round( random( 1, 4 ) );  // metabolic rate is randomly distributed between 1 and 4
      
        herd.add( new cow( width, height, metab, metab2, vision ) );
    }
};


void draw()
{

  background(0);
  noStroke();
  
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
        c.update();// scape );
        c.drawMyself();
      }
  }    
}