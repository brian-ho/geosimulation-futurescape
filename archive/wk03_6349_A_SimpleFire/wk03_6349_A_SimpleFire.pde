//  GSD 6349 Mapping II : Geosimulation
//  Havard University Graduate School of Design
//  Professor Robert Gerard Pietrusko
//  <rpietrusko@gsd.harvard.edu>
//  (c) Fall 2016 
//  Please cite author and course 
//  when using this library in any 
//  personal or professional project.

//  WEEK 03A : SIMPLE FIRE MODEL
//  

// GLOBAL VARIABLES ////////////////////////////////////////////////////////
// define all variables that we will use in both setup() and draw()


Lattice lat1, lat2;           // our two lattices that hold the cellular environment
Kernel  k;                    // our kernel function  
int kernelSize = 1;

float vegetationDensity = .39; // inital distribution of FUEL values
int month = 0;
float[] monthlyProbs = {0,0,0,0,0,.000005,.000005,0.00005,0,0,0,0};
float monthlyProb;

/////////////////////////////////////
// cell values
// 0 - Bare Ground
// 1 - mature vegetation (fuel)
// 2 - burning vegetation
// 3 - burnt out vegetation
// 4 - growing vegetation

static int BARE    = 0;
static int FUEL    = 1;
static int BURNING = 2;
static int BURNT   = 3;
static int GROWING = 4; 

/////////////////////////////////////

// an array[] of color variables to hold
// the color for each state. we are calling
// this array 'swatch.'

color[] swatch;

///////////////////////////////////////////////////////////////////////
// do once at the beginning....
void setup()
{
      size(400,400);
      frameRate(10);

      // creat our lattices and kernel
      // lat1 is initialized with either a value of 0 or 1, BARE or FUEL, respectively
      // a cell has a "vegetationDensity" probability of being FUEL 
      lat1 = new Lattice( 400,400, BARE, FUEL, vegetationDensity );
      lat2 = new Lattice( 400,400, 0 );
         k = new Kernel();
         k.setNeighborhoodDistance( kernelSize );   



     // define the colors used for each of the model states
     // color is a datatype custom to Processing that lets you
     // store RGB(alpha) values as a single variable
    
     //  swatch is an array[] of the color datatype
     // one for each state of the automata
     
     swatch = new color[5];
     
     swatch[BARE]    = color(0,0,0);
     swatch[GROWING] = color(0,255,0);
     swatch[FUEL]    = color(204, 153, 0);
     swatch[BURNING] = color(255,0,0);
     swatch[BURNT]   = color(100,100,100);
     
};


// do over and over ...

void draw()
{
    if(frameCount % 12 == 0)
    {
      month = (month + 1) % 12;
      println(month);
      monthlyProb = monthlyProbs[month];
    }
    
    background(0);
    
    // for X, for Y 
    // nested for loops to look up every cell in lat1.
    
    for( int x = 0; x < lat1.w; x++ ){
      for( int y = 0; y < lat1.h; y++ ){
      
        
              // get current state of cell x,y
              // look up its next state using our custom function,
              // updateBurnState(), defined below.
              
              int currentState = (int) lat1.get(x,y);
              int    nextState = updateBurnState( currentState );

              
              // UPDATE FIRE SPREAD
              // if a cell is valued FUEL, it checks if any of its neighbors
              // is on fire. 
              
              if( currentState == FUEL && k.hasNeighbor( lat1, x,y, BURNING ) == true )
              {           
                  // if our current state is FUEL ...  
                
                  // use our kernel function, hasNeighbor()
                  // to see if any of our neighbors are valued BURNING.
                  // if so, this cell's next state is BURNING
                  
                  // hasNeighbor() returns boolean, a 'true' or 'false' value .

                   nextState = BURNING;
              }
              
              if( currentState == FUEL)
              {          
                  //randomSeed(x*y*y*frameCount);
                  if (random(0, 1.0) <= monthlyProb){
                    nextState = BURNING;
                    println("burning");
                  }
                  
                  // if our current state is FUEL ...  
                
                  // use our kernel function, hasNeighbor()
                  // to see if any of our neighbors are valued BURNING.
                  // if so, this cell's next state is BURNING
                  
                  // hasNeighbor() returns boolean, a 'true' or 'false' value .
              }
              
             // store the next state in our temporary 
             // lattice
             lat2.put( x,y, nextState );
             
             //////////////////////////////
             // DRAW
             //////////////////////////////
             
             // color is chosen by using the current state
             // to look up a color in our swatch
             // each state has its own color(R,G,B);
             
             noStroke();
             fill( swatch[ currentState ] );
             rect(x,y,1,1);
                        
             
      }//end y for() loop
    }  //end x for() loop



    ///////////////////////////////
    // SIMPLE INTERACTIVITY
    // 'IGNITE' CELL IF MOUSE IS 
    // PRESSED ON TOP OF IT
    ///////////////////////////////
    
    if( mousePressed )
    {
        lat2.put(mouseX, mouseY, BURNING);
    }
           
    // replace lat1 with our temporary lattice, lat2
    lat1.replaceWith(lat2);
    
    // then do it all over again...
    
    
}; // end draw();



  //////////////////////////////////////////////////
 //         OUR CUSTOM FUNCTIONS                 //
//////////////////////////////////////////////////


int updateBurnState( int currentState )
{
      int nextState = currentState;
      
           if( currentState == BURNING ){ nextState =   BURNT; }
           // we'll add more here in the next example...
           // for now, the cell just burns out if it is on fire
           
      return nextState;
};


int probableDeath( int candidateVal, float deathRate )
{
    // it takes in the current Value ("candidate")
    // and its associated death rate. The "dice is rolled"
    // using a random number generator. if the value is
    // less than the death rate, our cell dies and the function
    // returns the value 0. If the cell is lucky and lives, the
    // function merely returns the current value unchanged. 
  
    int verdict = candidateVal;
    
    if( random(0,1.0) <= deathRate )
    {  // Whoops You're Dead!
        verdict = 0;
    }

    return verdict;
};