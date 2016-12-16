class Firescape extends Lattice   // main class for landscape
{
      float maxCapacity = 255;    // the maximum amount of grass
                                  // a cell in the landscape can hold
      
      float capacity[][];         // the capacity to hold grass at each x,y cell 
                                  // in the lattice

      float growth[][];           // each cell in the environment can have a different
                                  // growth rate, set with a function similar to 
                                  // addGrassPoint()
      
      /////////////////////////////////////////////////////////////
      // BIOMASS
                                  
      float grass[][];             // new matrix that holds the biomass of grass       
      float tree[][];              // new matrix that holds the biomass of trees     
      
      // NOT IMPLEMENTED - FOR FUTURE DEVELOPMENT
      /*
      float poop[][];        // poop matrix
      boolean pollute = false;     // we can set if we're pulluting or not
      float alpha = 0.5;          // poop rate
      float beta = 5;             // beta is threshold for grass collapse
      float recoverRate = 0.999;  // rate at which polluted cell dissipates 
      */
      
      /////////////////////////////////////////////////////////////
      // OTHER LANDSCAPE STUFF

      Lattice lat1, lat2, lat3;     // our lattices that hold the cellular environmenth
                                    // lat3 holds the timer 
      Lattice lat4;                 // holds how often a cell was burnt, will write out to GIS 
      Lattice lat5;                 // holds how often a cell was burnt, will write out to GIS                            
      Kernel  k;                    // our kernel function  
      ASCgrid ag;                   // class to read in ascii grid file of Land Cover
      ASCgrid dem;                  // class to read in ascii grid file of elevation
      ASCgrid fireCount;            // class to export firecount as ascii grid
      ASCgrid[] defs;               // array of ascii grid to hold the monthly water deficit maps
      NLCDswatch nlcdColors;        // a simple swatch of land cover colors
      NLCDhatch nlcdHatches;        // a simple swatch of land cover hatches
      NLCDconvert nlcdConverts;     // a simple swatch of land cover colors to ints
      
      PImage img;                   // image for the hillshade raster
      
      Table strikes;                // will hold lightining data read from CSV
      
      int kernelSize = 1;           // simple Moore neighborhood
      
      int BARE    = 0;
      int FUEL    = 1;
      int BURNING = 2;
      int BURNT   = 3;  
      int GROWING = 4;
      
      int burningTime = 2;         // fire spread rapidly
      int burntSeason   = 240;     // how many time steps a burnt cell stays burnt
      int growingSeason = 1;       // growing is implemented elsewhere
      
      color[] swatch;      
      
      ArrayList <PVector> fires;       // PVector array holds cell positions of fires in a given turn, used for cow fleeing
      ArrayList <PVector> landings;    // PVector array hold screen positions of landings
            
 ///////////////////////////////////////////////////////////////
      Firescape( int _w, int _h )      // constructor runs only in setup()
      { 
        
        
        super( _w, _h, 0);  // tell the underlying lattice how big it is
        
        println ("INTIALIZED FIRESCAPE", w, 'x', h, "cell dimension:", scale);
        
        capacity   = new float[w][h];  // initialize the capacity array
        growth     = new float[w][h];  // initialize the growth array
        grass      = new float[w][h];  // initialize grass matrix
        tree       = new float[w][h];  // initialize grass matrix
        //poop     = new float[w][h];  // initialize poop matrix
        
         lat1 = new Lattice( w,h );
         lat2 = new Lattice( w,h, 0 );
         lat3 = new Lattice( w,h, 0 ); 
         lat4 = new Lattice( w,h, 0 );
         lat5 = new Lattice( w,h, 0 );
         fires = new ArrayList<PVector>();
         landings = new ArrayList<PVector>();
         
         k = new Kernel();
         k.setNeighborhoodDistance( kernelSize );  
         k.isNotTorus();
         
         nlcdHatches = new NLCDhatch();
         nlcdConverts = new NLCDconvert();
         
         /////////////////////////////////////
         // Bring in GIS rasters
         ag = new ASCgrid( "Data/veg.asc");
         ag.fitToScreen();
         ag.resampleImageHatch( nlcdHatches.getHatch());
         //ag.updateImage();
         
         dem = new ASCgrid( "Data/dem.asc" );
         dem.fitToScreen();
         dem.updateImage();
         
         defs = new ASCgrid[12];
         defs[0] = new ASCgrid("Data/def/def_01.asc");
         defs[1] = new ASCgrid("Data/def/def_02.asc");
         defs[2] = new ASCgrid("Data/def/def_03.asc");
         defs[3] = new ASCgrid("Data/def/def_04.asc");
         defs[4] = new ASCgrid("Data/def/def_05.asc");
         defs[5] = new ASCgrid("Data/def/def_06.asc");
         defs[6] = new ASCgrid("Data/def/def_07.asc");
         defs[7] = new ASCgrid("Data/def/def_08.asc");
         defs[8] = new ASCgrid("Data/def/def_09.asc");
         defs[9] = new ASCgrid("Data/def/def_10.asc");
         defs[10] = new ASCgrid("Data/def/def_11.asc");
         defs[11] = new ASCgrid("Data/def/def_12.asc");
         
         for ( int i = 0; i < 12; i++ )
         {
           defs[i].fitToScreen();
         }
         
         img = loadImage("Data/dem_hillshade.png");
         
         // read from the NLCD data to intialize the landscape
         seedScape( nlcdConverts.getConverts() );
         
         // read fuel density from biomass
         calculateFuelDensity2();
         
         // NOT USED EXCEPT FOR BURNING"
         swatch = new color[5];
     
         swatch[BARE]    = color(0,0,0);
         swatch[GROWING] = color(0,255,0);
         swatch[FUEL]    = color(204, 153, 0);
         swatch[BURNING] = color(255,0,0);
         swatch[BURNT]   = color(100,100,100);

         // read in lightning CSV
         strikes = loadTable("Data/lightning.csv");
      };

 ///////////////////////////////////////////////////////////////
 // function runs in draw() each frame
     void runScape()
     {
       // using PImage type for quick landscape rendering with set()
       // img is for hillshade underlay, ag is landscape
       image(   img,0,0 ); 
       image(   ag.getImage(),0,0 );
       
       // draw the landscape with hatches, loosely implemented
       ag.resampleImageHatch( nlcdHatches.getHatch());
       
       // reset collection of fires for each turn
       fires.clear();
        
        // Unlock previous state lattice.
        lat2.unlockAll();
        
        // Iterate over every cell
        for( int x = 0; x < lat1.w; x++ ){
         for( int y = 0; y < lat1.h; y++ ){
           
             // get current state by get() method.
             // update next state as defined in below function.
             int currentState = (int) lat1.get(x,y);
             int    nextState = updateBurnState( currentState, x, y );
             
             // FIRE SUPRESSION - press 's' to put out fires
             if ( keyPressed && key == 's' ){ println ("PUT OUT FIRE");}
             
             // if no supression, continue
             else if( currentState == BURNING )
             {   
                 // add position to collection of fire
                 fires.add(new PVector(x,y,0));
                 
                 // first increment the log book to record that this cell is burning. 
                 lat4.increment(x,y);
                 
                 // get properties of the burning cell from lattices
                 float currentElevation = dem.get(x,y);
                 PVector[] hood = k.getPVarray( lat1, x, y);
                 PVector[] hoodFuel = k.getPVarray( lat5, x, y);
                 
                 // search neighborhood
                 for( int i = 0; i < hood.length; i++ )
                 {
                   // get fuel load of neighboring cell
                   float fuelLoad = hoodFuel[i].z;
                   
                   if ( fuelLoad == -9999) {} // error handling for non-vegetation cells
                   else if( fuelLoad > 100 && lat4.get(x,y) > 2) // fire can only spread at a certain fuel threshold
                   {  
                      // fuel load for burn probability
                      float burnProb = map(fuelLoad, 0, 500, 0, 1);
                      // if a neighbor is fuel, calculate the slope between the burning 
                      // cell and the neighbor fuel cell. IF() the neighbor is at a positive
                      // slope from our burning cell (slope > 0) , it definitely burns
                      // otherwise, it only burns with probability, from simply proximity
                      
                      if (random(0,1) < 0.75 ){
                      float neighborElevation = dem.get( (int)hood[i].x, (int)hood[i].y );
                      float slope = (neighborElevation-currentElevation) / (float)dem.cellsize;
                      
                      if(   slope > 0 )
                      {
                        // asign the neighbor a state BURNING 
                        // lock it so the rest of the for loop doesn't accidentally
                        // reset it to FUEL
                        lat2.put(  (int)hood[i].x, (int)hood[i].y, BURNING );
                        lat2.lock( (int)hood[i].x, (int)hood[i].y);
                      }
                      else
                      {
                        // asign the neighbor a state BURNING with a certain probability
                        // lock it so the rest of the for loop doesn't accidentally
                        // reset it to FUEL if it is burning. 
                        int value = probableValue( FUEL, BURNING, burnProb);
                        lat2.put(  (int)hood[i].x, (int)hood[i].y, value );
                        lat2.lock( (int)hood[i].x, (int)hood[i].y);
                     } //end if() }       
                 } }// end for(i)
               } // end if()
             }
             // store the next state in our temporary lattice, lat2
            lat2.put( x,y, nextState );
            drawScape( currentState, x, y);;
            } //end y for() loop
       } // end x for() loop           
       
       ////////////////////////////////////////
       // INTERACTION + THINGS TO SPARK A FIRE
      int randX = (int)random( 0, lat1.w );
      int randY = (int)random( 0, lat1.h );
      
      // lightning results in fire based on monthly probability
      if( lat1.get(randX, randY ) == FUEL && random(0,1) < strikes.getFloat(0, month)/( width ))
      {
          println("LIGHTING STRIKE");         
          lat2.put( randX, randY, BURNING );
      }
      
      // user can force start fires
      if( mousePressed && action == 'L' )
      {
          int latX = floor(map(mouseX,0,width,0,w));
          int latY = floor(map(mouseY,0,height,0,h));
        
          lat2.put(latX, latY, BURNING);
          println("BURNING");
      }
      
      // placement of harvest landings
      if( mousePressed && action == 'H' )
      { 
          placeLanding(mouseX, mouseY);
          println("PLACING LANDING AT", mouseX, mouseY);
      }
      
      // draw landings
      for (PVector h : landings)
      {
        //println("DRAWING LANDINGS");
        noStroke();
        fill(255,206,127);
        rectMode(CENTER);
        rect(h.x,h.y,8,8);
      }
     
    // replace lat1 with our temporary lattice, lat2      
    lat1.replaceWith(lat2);
    
    // recalculate fuel density for new biomass values
    calculateFuelDensity2();

   };
 
  ///////////////////////////////////////////////////////////////
  // for cows — how they eat
      float harvest( int x_, int y_, float grazingRate )
      {
         // when an agent calls harvest at its x,y location,
         // it removes all of the grass at that location. 
          int x = floor( map(x_, 0, width, 0, w));
          int y = floor( map(y_, 0, height, 0, h));
          
          x = constrain(x, 0, w-1 ); // make sure the x,y value
          y = constrain(y, 0, h-1 ); // isn't bigger or smaller than the lattice
          
          // check against cow's grazing rate
          float harvestAmount;
          
          if (grass[x][y] <= grazingRate) {      // the last bite ...                       
            harvestAmount = grass[x][y];         // grab the amount of grass at x,y
            grass[x][y] = 150;                   // set the new amount of grass there to zero
            tree[x][y] = 0;
            
             // bit of a hack — force a radial area of effect around cow to supress trees 
             for (int i = -2; i < 3; i++) {
              for (int j = -2; j < 3; j++ ) {
                if  (x + j < 0 || y + i < 0 || x + j > 124 || y + i > 124){}
                else {
                      int tempX=x+j;
                      int tempY=y+i;
                      
                      float distToCow = dist(x, y, tempX, tempY);
                      float removal      = map( distToCow, 0, 8, 100, 10 );
                      
                  tree[tempX][tempY] = constrain(tree[tempX][tempY]-removal+random(-10,10),0,255);       // random chance "fuzzes" the edge
                  grass[tempX][tempY] = constrain(grass[tempX][tempY]+removal+random(-10,100),0,255);
                }
              }
            }
          }
          
          // if not the last bite
          else{
            harvestAmount = grazingRate;
            grass[x][y] -= grazingRate;
          }
          
          // NOT IMPLEMENTED - for future development
          /*         
          if( pollute == true )            // if we are polluting
          {                                // the amount is proportional to the amount we harvested
              poop[x][y] += harvestAmount * alpha;
          }
          */
          //calculatePollutionRatio(x,y);   // update the ratio between grass and pollutation at this location
          
          return harvestAmount;                // return the grass to the cow
      };
      
 ///////////////////////////////////////////////////////////////   
 // function to intialize the landscape
      void seedScape( int[] converts ) // "converts" is a series ints
      {
          //intializes the state of every cell based on NLDC ASCII file.
          println( "Seeding Firescape with ASC Grid resampled to", w, 'x', h, "...");
          for( int x = 0; x < w; x++ ){
            for( int y = 0; y < h; y++){
              
              // keep track of cell net grass value
              float grassVal = 0;
              
              // for each cell, go over every pixel in cell
              for ( int i = 0; i < scale; i++ ){
                for ( int j = 0; j < scale; j++ ){
                  
                  // check to make sure we're not looking at non-veg area
                  int temp = converts[int(ag.get(int(x*scale) + i, int(y*scale) + j))];
                  if (temp == -9999) { grassVal = -9999; break; }
                  else {grassVal += converts[int(ag.get(int(x*scale) + i, int(y*scale) + j))] + int(random(-25,25));}
                } 
                if (grassVal == -9999){break;}
              } 
              if (grassVal == -9999)
              {  
              tree[x][y] = -9999;
              grass[x][y] = -9999;
              }
              
              else
              {
              // set cell value to average value of its pixels
              tree[x][y] = 255-round( grassVal/(scale*scale) );
              grass[x][y] = round( grassVal/(scale*scale) );
              growth[x][y] = 1; // starting growth rate
              }
            }
          }
      };
 
  /////////////////////////////////////////////////////////////// 
  // do the above, for a specific cell
void seedScapeCell( int[] converts, int x, int y)
      {
 
              // keep track of cell net grass value
              float grassVal = 0;
              
              // for each cell, go over every pixel in cell
              for ( int i = 0; i < scale; i++ ){
                for ( int j = 0; j < scale; j++ ){
                  
                  int temp = converts[int(ag.get(int(x*scale) + i, int(y*scale) + j))];
                  if (temp == -9999){
                    grassVal = -9999; break;
                  }
                  else{
                    grassVal += converts[int(ag.get(int(x*scale) + i, int(y*scale) + j))] + int(random(-25,25));
                  }
                } if (grassVal == -9999){break;}
              } if (grassVal == -9999){
              tree[x][y] = -9999;
              grass[x][y] = -9999;
              }
              else{
              // set cell value to average
              tree[x][y] = map(255-( grassVal/(scale*scale)),0,255,0,100 );
              grass[x][y] = map( grassVal/(scale*scale),0,255,50,150 );
              growth[x][y] = 1;
              }
      };
 
 ///////////////////////////////////////////////////////////////      
      void growGrass( float growthRate )
      {
          //for every cell in the lattice, check if it is below its maximum
          //capacity, if so, grow the grass incrementally by "growthRate" amount
          //if it is at capacity, leave it.
        
          for( int x = 0; x < w; x++ ){
            for( int y = 0; y < h; y++){
             
                    // if poop is less than beta then grass will grow there
                    if( grass[x][y] < capacity[x][y])// && poop[x][y] < beta )
                    {
                        grass[x][y] = grass[x][y]+ growthRate; 
                        tree[x][y] = tree[x][y]+ growthRate; 
                    }
                    //calculatePollutionRatio(x,y);
            }
          }
      };

///////////////////////////////////////////////////////////////
// make the landscape grow, runs every frame
      void growScape( )
      {
          // variables to hold the biomass
          int g = 0;   // grass
          int t = 0;   // tree
          
          // loop over every cell
          for( int x = 0; x < w; x++ ){
            for( int y = 0; y < h; y++){
              
                    // handle non-veg cells
                    if( grass[x][y] == -9999 || tree[x][y] == -9999 ) {}
                    
                    // TIPPING POINT: behavior hinges on comparative biomass of tree + grass on cell
                    else if ( grass[x][y] - tree[x][y] >= 100 && tree[x][y] > 0 && grass[x][y] <= 255)
                    {
                          g += grass[x][y];
                          t += tree[x][y];
                          grass[x][y] += growth[x][y];
                          tree[x][y] -= growth[x][y];
                    }
                    else if ( grass[x][y] >= 0 && tree[x][y] <= 255)
                    {
                        g += grass[x][y];
                        t += tree[x][y];
                          tree[x][y] += growth[x][y];
                          grass[x][y] -= growth[x][y];
                    }
            }
          }
          gMass = g; // update global counters
          tMass = t;
      };

 ///////////////////////////////////////////////////////////////      
      void addGrassPoint( int grassX, int grassY, float capacityValue, float spread  )
      {
          // a grass point is defined by its x,y location; the maximum value of grass
          // at that location, and the rate at which it decays as one moves away 
          // from that point in space.
        
        
          for( int x = 0; x < w; x++ ){
            for( int y = 0; y < h; y++ ){
                  // for every cell in the lattice
                  // measure its distance from the grass point
                  // use map to scale distance into capacity 
                  // at a distance of 0, a cell is at the capacity value
                  // at a distance of spread, and beyond, it contains no grass
                 
                  float distToGrassPoint = dist(x, y, grassX, grassY);
                  float capValue        = map( distToGrassPoint, 0, spread, capacityValue, 0 );
                        capValue        = constrain( capValue, 0, maxCapacity );
                        
                        
                  // we add capacity in case there are multiple grass points, where they overlap
                  // the capacity for grass adds together
                  capacity[x][y] = capacity[x][y] + capValue;
                  grass[x][y] = capacity[x][y];
            }}
      };
      
 ///////////////////////////////////////////////////////////////      
      void addGrowthRate( int grassX, int grassY, float growthValue, float spread  )
      {
        
          for( int x = 0; x < w; x++ ){
            for( int y = 0; y < h; y++ ){

                  float distToGrassPoint = dist(x, y, grassX, grassY);      
                  float cellGrowthValue = (distToGrassPoint <= spread)? growthValue : 0;
                  
                  growth[x][y] += cellGrowthValue;                            
            }
          }
      }
      
 ///////////////////////////////////////////////////////////////      
      void resetGrowth()
      {
          growth = new float[w][h];
      }

///////////////////////////////////////////////////////////////   
/*
      void calculatePollutionRatio( int x, int y )
      {
            // allow polluted cell to recover by a small amount
            // then calculate the proportion of grass to poop
            //poop[x][y] *= recoverRate;
            lattice[x][y] = grass[x][y] / (1 + poop[x][y] );
      }
*/
///////////////////////////////////////////////////////////////////////
// heavily modified

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
               // secondary check for supression interaction
               if ( keyPressed && key == 's' ){ nextState = BURNT; return nextState; }
               
               // BURNING favors grass post-fire
               if (grass[x][y] > 0){ grass[x][y] = 101; }
               if (tree[x][y] > 0){ tree[x][y] = 1; }
               float dur = lat3.get(x,y);
               
               if( dur > burningTime )
               {
               nextState = BURNT;  // next state is burnt
               lat3.put( x,y, 0 ); // reset growth counter
               }
               else
               {
                   // if it is not yet time to grow
                   // increment the duration at this cell
                   // one time step larger
                   lat3.put(x,y, dur+1);
               }
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
                   lat3.put(x,y,round(random(0,5)));
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
                   lat3.put(x,y,round(random(0,5)));
                   
                   // growing means re-seeding the cell
                   seedScapeCell( nlcdConverts.getConverts(), x, y);
               }
               else
               {
                   lat3.put(x,y, dur+1);
               }
           }
      return nextState;
};

///////////////////////////////////////////////////////////////////////
void calculateFuelDensity2()
{
    // simply loop through every cell in the ascii grid 
    // if the cell has any of the Land Cover codes listed below
    // it updates the corresponding cell in lat1 with as FUEL with a certain
    // probability
    // if not, the cell stays valued '0'
    // this works because lat1 and AG are both the same size matricies. 
    
     for( int x = 0; x < lat5.w; x++){
       for( int y = 0; y < lat5.h; y++){
           int fuelLoad = 0;  
           if( tree[x][y] == -9999 || grass[x][y] == -9999){ fuelLoad = -9999; }
           
           // fuel load favors tree
           else {fuelLoad  = int(tree[x][y] + grass[x][y]/2);}
           lat5.put( x,y, fuelLoad );
       }}
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
             cellState = probableValue( BARE,FUEL, map(tree[x][y] + grass[x][y]/2, 0, 255, 0.01, 0.99));
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

///////////////////////////////////////////////////////////////////////
ArrayList<PVector> fires(  )
{ 
     // collection of fires
      return fires;   
}

/////////////////////////////////////////////////////////////// 
// function to change water def maps
void cycleDefs (int month)
{
  println("Cycling water def maps ...");
  for (int x = 0; x < w; x++){
    for (int y = 0; y < h; y ++)
    {
          // need to normalize re-world data for our simulation
          growth[x][y] = 4-round(map(defs[month].get(int(x*scale), int(y*scale)), -.1, 0.26, -1, 3));
    }
  }
}

/////////////////////////////////////////////////////////////// 
float[][] getGrass ()
{
  return grass; 
};

/////////////////////////////////////////////////////////////// 
ASCgrid getDEM ( )
{
  return dem; 
};

/////////////////////////////////////////////////////////////// 
float[][] getTree ( )
{
  return tree; 
};

/////////////////////////////////////////////////////////////// 
// when landings are placed
void placeLanding (int x, int y )
{
    // save to landings
    landings.add(new PVector(x,y,0));
          
          //translate location
          int latX = floor(map(mouseX,0,width,0,w));
          int latY = floor(map(mouseY,0,height,0,h));
          
          // area of effect around landing
          for (int i = -8; i < 8; i++) {
            for (int j = -8; j < 8; j++ ) {
              if  (latX + j < 0 || latY + i < 0 || latX + j > 124 || latY + i > 124){}
              else {
                    int tempX=latX+j;
                    int tempY=latY+i;
                    
                    float distToLanding = dist(latX, latY, tempX, tempY);
                    float removal      = map( distToLanding, 0, 8, 200, 10 );
                    
                tree[tempX][tempY] = constrain(tree[tempX][tempY]-removal + random(-10,10),1, 255); // random fuzz at edges
                grass[tempX][tempY] = constrain(grass[tempX][tempY]+removal + random(-10,10),1,255);
              }
            }
          }
};

/////////////////////////////////////////////////////////////// 
// draw the landscape at a cell, runs every frame once per cell
      void drawScape ( int currentState, int x, int y )
      {   
            // remap the gree fuel
            int val = round( map( grass[x][y], 0, maxCapacity, 0, 200) );
            
            int drawX = floor( x*scale );
            int drawY = floor( y*scale );
       
            int dimn = round( scale );
            
            // override for fire + burnt states
             if (currentState == 2 || currentState == 3 )
             {
              noStroke();
              fill( swatch[ currentState ] );
              rect( drawX, drawY, dimn, dimn);
             }
              
            // otherwise, choose hatches
            if (displayMode == 'N' || displayMode == 'E'){
            color Gr = color(154, 205, 50, grass[x][y]);
            color Tr = color(0, 100, 0, tree[x][y]);
            color Hr = color(107,142,35,tree[x][y]);
            color b = color (0, 0, 255, 150); 
            color r = color (0, 255, 0, 150); 
            color[] hatch; 
            
            // two kinds of algorithmic hatches depending on dominant veg (or SIMPLE view)
            if (tree[x][y] >= 0 || grass[x][y] >= 0 ){
              if (tree[x][y] > grass [x][y]) {
                if (displayMode == 'E'){hatch = new color[] {b,b,b,b, b,b,b,b,b,b,b,b,b,b,b,b};}
                
                else { hatch = new color []                                 // swatch for TREE
                                                                            {Hr, Tr, Gr, Tr,
                                                                             Tr, Gr, Tr, Hr,
                                                                             Gr, Tr, Hr, Tr,
                                                                             Tr, Hr, Tr, Gr}; }}
               else {
               if (displayMode == 'E'){hatch = new color[] {r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r};}
               
               else {hatch = new color[]                                    // swatch for GRASS
                                                                            {Tr, Gr, Tr, Hr,
                                                                             Gr, Tr, Hr, Tr,
                                                                             Tr, Hr, Tr, Gr,
                                                                             Hr, Tr, Gr, Tr}; }}
            }
            else {return;};
            
            // draw hatch as seiries of pixels within a cell
            for ( int i = 0; i < scale; i++ ) {
              for ( int j = 0; j < scale; j++ ) {
                ag.getImage().set(drawX+j,drawY+i, hatch[int(j+scale*i)%16]);
                }
              };
            }
            
            // FUEL LOADING view
            else if (displayMode == 'F'){
            int fuelLoad = int(map(lat5.get( x, y ), 0, 400, 0, 255));
            
            for ( int i = 0; i < scale; i++ ) {
              for ( int j = 0; j < scale; j++ ) {
                ag.getImage().set(drawX+j,drawY+i, color(fuelLoad, fuelLoad, fuelLoad));
              }
              }
            }
            
            // TREE MASS view
           else if (displayMode == 'T'){
             color fill = color(tree[x][y],tree[x][y],tree[x][y]);
            
            for ( int i = 0; i < scale; i++ ) {
              for ( int j = 0; j < scale; j++ ) {
                ag.getImage().set(drawX+j,drawY+i, fill);
              }
              }
            } 
            
            // GRASS MASS view
            else if (displayMode == 'G'){
             color fill = color(grass[x][y],grass[x][y],grass[x][y]);
            
            for ( int i = 0; i < scale; i++ ) {
              for ( int j = 0; j < scale; j++ ) {
                ag.getImage().set(drawX+j,drawY+i, fill);
              }
            }
            } 
            
            // WATER DEFICIT view
            else if (displayMode == 'D'){
             int shade = int(map(growth[x][y],0,5,0,255));
             color fill = color(shade, shade, shade);
            
            for ( int i = 0; i < scale; i++ ) {
              for ( int j = 0; j < scale; j++ ) {
                ag.getImage().set(drawX+j,drawY+i, fill);
              }
            }
            }
      }
};