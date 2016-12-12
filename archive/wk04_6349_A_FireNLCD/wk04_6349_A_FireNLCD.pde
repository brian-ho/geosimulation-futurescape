//  GSD 6349 Mapping II : Geosimulation
//  Havard University Graduate School of Design
//  Professor Robert Gerard Pietrusko
//  <rpietrusko@gsd.harvard.edu>
//  (c) Fall 2016 
//  Please cite author and course 
//  when using this library in any 
//  personal or professional project.

//  WEEK 04a : SIMPLE FIRE MODEL WITH LAYERS
//  

// GLOBAL VARIABLES ////////////////////////////////////////////////////////
// define all variables that we will use in both setup() and draw()


Lattice lat1, lat2, lat3;     // our lattices that hold the cellular environment
                              // lat3 holds the count 
Kernel  k;                    // our kernel function  
ASCgrid ag;                   // class to read in ascii grid files
NLCDswatch nlcdColors;        // a simple swatch of standard land cover colors

int kernelSize = 1;

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

// these values are used in conjunction with lat3, which holds durational
// values for each cell that is burnt or growing
int burntSeason   =  80; // how many time steps a burnt cell stays burnt
int growingSeason = 120; // how many time steps a growing cell grows for
                         // before becoming fuel
                         
float burnProbability = 0.7; // the probability a cell will catch fire if
                             // neighbor is burning 
                             
PVector wind = new PVector (10, 0);                        


///////////////////////////////

// an array[] of color variables to hold
// the color for each state. we are calling
// this array 'swatch.'

color[] swatch;


///////////////////////////////////////////////////////////////////////
// do once at the beginning....
void setup()
{
      size(1000,1000);
      frameRate(30);


      // creat our lattices and kernel
      // all lattices are initialized with a value of 0
      // lat3 is normally valued '0.' If a cell is BURNT or GROWING, the corresponding
      // cell in lat3 begins counting up how many time steps it has been BURNT or GROWING
      // if it passes a durational threshold -- burntSeason or growingSeason, respectively 
      // -- the cell changes state. 
      
      lat1 = new Lattice( 1000,1000, 0 );
      lat2 = new Lattice( 1000,1000, 0 );
      lat3 = new Lattice( 1000,1000, 0 );
 
      // load the kernel class 
         k = new Kernel();
         k.setNeighborhoodDistance( kernelSize );  
         k.isNotTorus();
     
     
     // create a new instance of our Land Cover Code Color swatch
     // this is used to color the land cover ascii grid 
      nlcdColors = new NLCDswatch();
     
     // load an ASCII grid of the NLCD 2011 dataset you exported from ArcMAP
     // though the ArcMap layout window was 1000 x 1000, the ASCII grid will not 
     // be the same size. This is because map scale is not simply a power of two.
     // therefore, use the function that fits (downsamples) the grid to the screen.
     // and create a PImage of the raster using the swatch values in the NLCDswatch()
     
     ag = new ASCgrid( "Rasters/nlcd2011.asc");
     ag.fitToScreen();
     ag.updateImage( nlcdColors.getSwatch() );


     
      // for several Land Cover classes in the NLCD
      // set the density of fuel probabilistically
      
      calculateFuelDensity();


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

///////////////////////////////////////////////////////////////////////
// do over and over ...

void draw()
{
    // instead of a black background use the NLCD ascii as a basemap
    // image using the getImage() function
    
    image( ag.getImage(), 0,0 );
 
 
    // for X, for Y 
    // nested for loops to look up every cell in lat1.
    
    for( int x = 0; x < lat1.w; x++ ){
     for( int y = 0; y < lat1.h; y++ ){
      
             // get current state of cell x,y
             // look up its next state using our custom function,
             // updateBurnState(), defined below.
             // updateBurnState() also keeps track of duration of burnt 
             // or growing states
              
             int currentState = (int) lat1.get(x,y);
             int    nextState = updateBurnState( currentState, x, y );              
              
                 // if our current state is FUEL ...  
                 // use our kernel function, hasNeighbor()
                 // to see if any of our neighbors are valued BURNING.
                 // if so, this cell's next state is BURNING
                 // hasNeighbor() returns boolean, a 'true' or 'false' value .
                 
                 // if a neighbor is burning, our custom function, probableValue(),
                 // calculates the update state. it has a "burnProbability" of catching
                 // fire
                  
                 // UPDATE FIRE SPREAD probabilistically 
             if( currentState == FUEL && k.hasNeighbor(lat1, x,y, BURNING)  )
             {           
                     PVector[] list = k.hasNeighbor2((Lattice)lat1, x,y, BURNING);
                     
                     PVector loc = new PVector(x, y);
                     for ( PVector fire : list )
                     {
                     
                         if (loc.sub(fire.normalize()) == wind.normalize())
                         {
                          burnProbability = 0.9; 
                         }
                         
                   
                     }
                     nextState = probableValue(FUEL, BURNING, burnProbability );            
             }
              
             
            // store the next state in our temporary lattice, lat2
            lat2.put( x,y, nextState );
             
             //////////////////////////////
             // DRAW
             //////////////////////////////
 
             // color the rect using
             // the swatch array. look up a cell
             // state's color using its state code.
             
             if( currentState > 0)
             {
              noStroke();
              fill( swatch[ currentState ] );
              rect(x,y,1,1);
             }
             
      }//end y for() loop
   }// end x for() loop

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




///////////////////////////////////////////////////////////////////////
int updateBurnState( int currentState, int x, int y )
{
      int nextState = currentState;
      
           // FUEL STATE ////////////////////////
           if( currentState == FUEL)
           {    
               lat3.put( x,y, 0 ); // reset growth counter
           }
           
           // BURNING STATE ////////////////////////
           else if( currentState == BURNING )
           { 
               nextState = BURNT;  // next state is burnt
               lat3.put( x,y, 0 ); // reset growth counter
           }
           
           // BURNT STATE ////////////////////////
           else if( currentState == BURNT )
           { 
               // read in how long it has been burnt
               // from our counter lattice
               float dur = lat3.get(x,y);
               
               if( dur > burntSeason )
               {
                   // its been burnt long enough
                   // now it can grow
                   // reset counter
                   nextState = GROWING;
                   lat3.put(x,y,0);
               }
               else
               {
                   // if it is not yet time to grow
                   // increment the duration at this cell
                   // one time step larger
                   lat3.put(x,y, dur+1);
               }
           }
           
           // GROWING STATE ////////////////////////
           else if( currentState == GROWING )
           { 
               float dur = lat3.get(x,y);
               
               if( dur > growingSeason )
               {
                   nextState = FUEL;
                   lat3.put(x,y,0);
               }
               else
               {
                   lat3.put(x,y, dur+1);
               }
           }


      return nextState;
};
///////////////////////////////////////////////////////////////////////
void calculateFuelDensity()
{
    // simply loop through every cell in the ascii grid 
    // if the cell has any of the Land Cover codes listed below
    // it updates the corresponding cell in lat1 with as FUEL with a certain
    // probability
    // if not, the cell stays valued '0'
    // this works because lat1 and AG are both the same size matricies. 
  
     for( int x = 0; x < lat1.w; x++){
       for( int y = 0; y < lat1.h; y++){
             
             int cellState = BARE;
             int LCvalue   = (int) ag.get(x,y);
             
                  if( LCvalue == 42 ){ cellState = probableValue( BARE,FUEL, 0.7); } 
             else if( LCvalue == 51 ){ cellState = probableValue( BARE,FUEL, 0.6); }
             else if( LCvalue == 52 ){ cellState = probableValue( BARE,FUEL, 0.5); }
             else if( LCvalue == 71 ){ cellState = probableValue( BARE,FUEL, 0.5); }
             
             lat1.put( x,y, cellState );
       }}
};

///////////////////////////////////////////////////////////////////////
int probableValue( int defaultValue, int candidateValue, float probabilityRate )
{     
     // choose a random number with a probability rate
     // if it passes the test, the new value is assigned
     // if not the default value is used. 
      
      return (random(0,1.0) <= probabilityRate) ? candidateValue : defaultValue;   
};