// GLOBAL VARIABLES ////////////////////////////////////////////////////////
// define all variables that we will use in both setup() and draw()

//LookUpTable LU;    // class that holds a look up table of of transition rules 
                   // between the different land use classes
                   
Lattice lat1;                   // our lattice to hold the state of the cellular world
ASCgrid ag, agOut;              // classes to read in and write out ascii grid files
//Lattice cLat, rLat, mLat, oLat; // each land use class (Commercial, Residential, Manufacturing, Office )
                                // has a lattice that stores each cell's potential for transitioning
                                // to that land use on the next time step

Kernel k;    // Kernel function


int    hoodSize   = 6;                       // size of our kernel neighborhood
//String LUfile     = "LUtransitionTable.csv"; // name of transition rule table
String source  = "DATA/test.asc";     // name of output ASCII grid file to read back into GIS
float  rScl       = 1;                       // will use this to draw shapes to the screen
                                             // short for "rectangle scaling"
                                             
float  growthRate = 0.03; // growth rate determines
                          // how many cells to generate on
                          // next time step
                          
color[] swatch;
 
static int V = 0; // VACANT
static int C = 1; // COMMERCIAL
static int R = 2; // RESIDENTIAL
static int M = 3; // MANUFACTURING + INDUSTRIAL
static int O = 4; // OFFICE
static int T = 5; // TRANSPORTATION
static int I = 6; // INSTITUTIONAL
static int S = 7; // OPEN SPACE
static int W = 8; // WATER
static int A = 9; // AGRICULTURE
 
 
 void setup()
{
    size(800,800);
    frameRate(12);

    /*
    // * * * KERNEL * * * //
    // set up the Kernel with our neighborhood size, 6, defined above
    k = new Kernel();
    k.setNeighborhoodDistance(hoodSize);
    k.isNotTorus();
    

    // define the colors used for each of the model states
    // color is a datatype custom to Processing that lets you
    // store RGB(alpha) values as a single variable
    // swatch is an array[] of the color datatype
    // one for each state of the automata
     */
    swatch    = new color[10];
    swatch[V] = color(  0,   0,   0); // Vacant --------- 'black'
    swatch[C] = color(255,  25,  11); // Commercial ----- 'red'
    swatch[R] = color(255, 140,   0); // Residential ---- 'Orange'
    swatch[M] = color(  5, 103, 229); // Industiral ----- 'magenta'
    swatch[O] = color(255,  20, 147); // Office --------- 'pink'
    swatch[T] = color(100, 100, 100); // Transportation - 'grey'
    swatch[I] = color(  0,   0, 255); // Institutional -- 'blue'
    swatch[S] = color(  0, 255,   0); // Open Space ----- 'green'
    swatch[W] = color(  0, 255, 255); // Water ---------- 'light blue'
    swatch[A] = color(142, 166,  26); // Agriculture ---- 'yellow-brown'

  
    // * * * ASCII GRID  * * * //
    
     ag = new ASCgrid(source);
     ag.fitToScreen();
     //ag.updateImage( swatch );
     agOut = new ASCgrid( ag );    // ascGrid output copies its size
                                   // and map projection from the grid
                                   // we are loading in from GIS
                                    
        
    // * * * LATTICE * * * //
    // Create our lattices and set them to be the same size
    // as the data we loaded in from GIS (in the ASC Grid above)
    
    lat1 = new Lattice(ag.w,ag.h);  // holds our cellular world
    
    lat1.replaceWith( ag.get() );   // copy the ASCII Grid 
                                    // Land Use Cells into the lat1
      
  
    // initialize our new LookUpTable() Class
    // it takes in the name of the csv file we are loading
    // as well as the sizes of the transition space
    // 10 land use classes that might transition
    // 10 land use classes that a cell might transition to
    // 10 land use classes that are possible neighbors
    // 6 distance bands that neighbors may reside in
    
    //LU = new LookUpTable( LUfile, 10,10,10, 6);

      
    // rScl stores how big 'pixel' rectangles should
    // draw to the screen. since our world in 50x50 and our
    // screen in 600x600, a rect should be 600/50 pixels big
    // we'll use this in the draw loop
    rScl = width / lat1.w;
  
}; // setup()


///////////////////////////////////////////////////////////////////////
// draw() do over and over ...
///////////////////////////////////////////////////////////////////////

void draw()
{
    background(0);
    noStroke();
    
    
    // reset our lattices
    // unlock all values in lat1
    // set all C, R, M and O potentials back to zero
    lat1.unlockAll();
    /*
    cLat.clear();
    rLat.clear();
    mLat.clear();
    oLat.clear();
    */

    // for X, for Y 
    // nested for loops to look up every cell in lat1.
    
    for( int x = 0; x < lat1.w; x++ ){
      for( int y = 0; y < lat1.h; y++ ){
        
            // using our custom function, calculatePotential(), defined below...
            int    val = (int)lat1.get(x,y);            // get the current value of cell x,y
            /*
            float   Cp = calculatePotential(x,y,val, C);// calculate the potential for C land use at cell x,y
            float   Rp = calculatePotential(x,y,val, R);// calculate the potential for R land use at cell x,y
            float   Mp = calculatePotential(x,y,val, M);// calculate the potential for M land use at cell x,y
            float   Op = calculatePotential(x,y,val, O);// calculate the potential for O land use at cell x,y
            
            // put the transition potential into the respective lattices.
            cLat.put( x, y, Cp );
            rLat.put( x, y, Rp );
            mLat.put( x, y, Mp );
            oLat.put( x, y, Op );
            
                        
            // draw the current value of the cell
            if( val != V ) // if it isn't Vacant, draw it. 
            {
                // if the size of lat1 does not match the size of our screen --
                // scale the x,y position of our cells to fit the screen
                // draw the rectangle with a size of rScl 
                // (we defined this above as width/lat1.w or 600/50
                // the fill is loaded from the swatch*/
                float xScl = map( x, 0, lat1.w, 0, width );
                float yScl = map( y, 0, lat1.h, 0, height);
                fill( swatch[val] );
                rect( xScl, yScl, rScl, rScl );
            //}
           
      }// end for() y
    }// end for() x
      /*
     
      //////////////////////////////////////////////////
      // NOW ASSIGN VALUES TO CELLS BASE              //
      //////////////////////////////////////////////////
      // use custom function we define below 

         assignNewCells();
         
         if( keyPressed == true && key == 's')
         {
             println( "saving ascii grid" );
             agOut.put( lat1.getlattice() );
             agOut.write("DATA/LUoutput.asc");
         }
      
      
      // loop back to the top, do over again....
     */ 
      
};  