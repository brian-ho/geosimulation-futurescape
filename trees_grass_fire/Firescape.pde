class Firescape extends Lattice   // when a class "extends" another class
{                                 // it has all of the functions and variables that
                                  // the "super" class has, even if they remain hidden
                                  // this is how we use Lattice to create a Firescape
                                  // we want all of the lattice functionality but we 
                                  // what it to do a few other things as well

      float maxCapacity = 100;    // the maximum amount of grass
                                  // a cell in the landscape can hold
      
      float capacity[][];         // the capacity to hold grass at each x,y cell 
                                  // in the lattice

      float growth[][];           // each cell in the environment can have a different
                                  // growth rate, set with a function similar to 
                                  // addGrassPoint()
      
                                  
      /////////////////////////////////////////////////////////////
      // VARIABLES FOR POLLUTION
                                  
      float grass[][];             // new matrix that holds the grass       
      float poop[][];        // poop matrix
      boolean pollute = false;     // we can set if we're pulluting or not
      float alpha = 0.5;          // poop rate
      float beta = 5;             // beta is threshold for grass collapse
      float recoverRate = 0.999;  // rate at which polluted cell dissipates 
      
      /////////////////////////////////////////////////////////////
      // FIRE STUFF
      // a list of ints that equate to cell fire status (bare, fuel, burning, burnt, growing)?
      // series of lattices 
      Lattice lat1, lat2, lat3;     // our lattices that hold the cellular environment
                                    // lat3 holds the timer 
      Lattice lat4;                 // holds how often a cell was burnt, will write out to GIS                           
      Kernel  k;                    // our kernel function  
      ASCgrid ag;                   // class to read in ascii grid file of Land Cover
      //ASCgrid dem;                  // class to read in ascii grid file of elevation
      ASCgrid fireCount;            // class to export firecount as ascii grid
      //NLCDswatch nlcdColors;        // a simple swatch of land cover colors
      
      int kernelSize = 1;           // simple Moore neighborhood
      
      int BARE    = 0;
      int FUEL    = 1;
      int BURNING = 2;
      int BURNT   = 3;  
      int GROWING = 4;
      
      int burningTime = 80;
      int burntSeason   = 180;     // how many time steps a burnt cell stays burnt
      int growingSeason = 360; 
      
      color[] swatch;
      
      ArrayList <PVector> fires;
      
      //ASCgrid for land cover[
      //ASC grid for DEM elevation[][]
      // lat for current state
      // lat for next state
      // lat for burn timer
      
      //float tree[][]
      //float fertility[][]
      

 ///////////////////////////////////////////////////////////////
      Firescape( int _w, int _h )
      {        
        super( _w, _h, 0);  // tell the underlying lattice how big it is
        println ("INTIALIZED FIRESCAPE cell dimensions:", w, 'x', h);
        capacity   = new float[w][h];  // initialize the capacity array
        growth     = new float[w][h];  // initialize the growth array
        grass      = new float[w][h];  // initialize grass matrix
        poop       = new float[w][h];  // initialize poop matrix
        
        // NOTE: LATTICE NO LONGER HOLDS "Grass" IT HOLDS THE RATIO
        // BETWEEN Grass AND POLLUTION. THIS IS NOW WHAT AN AGENT USES
        // TO CHOOSE LOCATION
        
        // lattice(x,y) = grass(x,y) / ( 1+poop(x,y) )
        
         lat1 = new Lattice( w,h );
         lat2 = new Lattice( w,h, 0 );
         lat3 = new Lattice( w,h, 0 ); 
         lat4 = new Lattice( w,h, 0 );
         fires = new ArrayList<PVector>();
         
         k = new Kernel();
         k.setNeighborhoodDistance( kernelSize );  
         k.isNotTorus();
         
         
         ag = new ASCgrid( "Rasters/veg.asc");
         ag.fitToScreen();
         ag.updateImage();
         /*
         dem = new ASCgrid( "Rasters/azdem.asc" );
         dem.fitToScreen();
         dem.updateImage();
         */
         
         calculateFuelDensity();
         
         swatch = new color[5];
     
         swatch[BARE]    = color(0,0,0);
         swatch[GROWING] = color(0,255,0);
         swatch[FUEL]    = color(204, 153, 0);
         swatch[BURNING] = color(255,0,0);
         swatch[BURNT]   = color(100,100,100);
      };

 ///////////////////////////////////////////////////////////////
     void runScape()
     {
       
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
             
             if( currentState == BURNING )
             {       
                     fires.add(new PVector(x,y,0));
                     // first increment the log book to record that this cell is burning. 
                     lat4.increment(x,y);
               
                     //float currentElevation = dem.get(x,y);
                     PVector[] hood = k.getPVarray( lat1,x,y);
                     
                     for( int i = 0; i < hood.length; i++ )
                     {
                           if( hood[i].z == FUEL && lat4.get(x,y) > (30) )
                           {
                                // if a neighbor is fuel, calculate the slope between the burning 
                                // cell and the neighbor fuel cell. IF() the neighbor is at a positive
                                // slope from our burning cell (slope > 0) , it definitely burns
                                // otherwise, it only burns with probability, from simply proximity
                                /*
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
                                  */
                                        // asign the neighbor a state BURNING with a certain probability
                                        // lock it so the rest of the for loop doesn't accidentally
                                        // reset it to FUEL if it is burning. 
                                        int value = probableValue( FUEL, BURNING, 0.02);
                                        lat2.put(  (int)hood[i].x, (int)hood[i].y, value );
                                        lat2.lock( (int)hood[i].x, (int)hood[i].y);
                                //}
                           }//end if()        
                     }// end for(i)
                   }// end if()
             // store the next state in our temporary lattice, lat2
            lat2.put( x,y, nextState );
            
             //////////////////////////////
             // DRAW
             //////////////////////////////
             /*
             if( currentState > 0)
             {
              noStroke();
              fill( swatch[ currentState ] );
              rect(x,y,1,1);
             }*/
        }//end y for() loop
   }// end x for() loop
   
   // THINGS TO IGNITE IT
    if( mousePressed )
    {
        int latX = floor(map(mouseX,0,width,0,w));
        int latY = floor(map(mouseY,0,height,0,h));
      
        lat2.put(latX, latY, BURNING);
        println("BURNING");
    }
   
    // replace lat1 with our temporary lattice, lat2      
    lat1.replaceWith(lat2);
   }
 
  ///////////////////////////////////////////////////////////////
      float harvest( int x_, int y_, float grazingRate )
      {
         // when an agent calls harvest at its x,y location,
         // it removes all of the grass at that location. 
          int x = floor( map(x_, 0, width, 0, w));
          int y = floor( map(y_, 0, height, 0, h));
          
          x = constrain(x, 0, w-1 ); // make sure the x,y value
          y = constrain(y, 0, h-1 ); // isn't bigger or smaller than the lattice
          
          float harvestAmount;
          if (grass[x][y] <= grazingRate) {                         
            harvestAmount = grass[x][y]; // grab the amount of grass at x,y
            grass[x][y] = 0;                   // set the new amount of grass there to zero
          }
          else{
            harvestAmount = grazingRate;
            grass[x][y] -= grazingRate;
          }
                                            
                   
          if( pollute == true )            // if we are polluting
          {                                // the amount is proportional to the amount we harvested
              poop[x][y] += harvestAmount * alpha;
          }
          
          calculatePollutionRatio(x,y);   // update the ratio between grass and pollutation at this location
          
          return harvestAmount;                // return the grass
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
                    if( grass[x][y] < capacity[x][y] && poop[x][y] < beta )
                    {
                        grass[x][y] = grass[x][y]+ growthRate;
                        
                    }
                    
                    calculatePollutionRatio(x,y);
            }
          }
      };

///////////////////////////////////////////////////////////////      
      void growGrass( )
      {
          //for every cell in the lattice, check if it is below its maximum
          //capacity, if so, grow the grass incrementally by "growthRate" amount
          //if it is at capacity, leave it.
        
          for( int x = 0; x < w; x++ ){
            for( int y = 0; y < h; y++){
             
                    // if poop is less than beta then grass will grow there
                    if( grass[x][y] < capacity[x][y] && poop[x][y] < beta )
                    {
                        grass[x][y] += growth[x][y];
                       
                    }
                     calculatePollutionRatio(x,y);
            }
          }
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
      void calculatePollutionRatio( int x, int y )
      {
            // allow polluted cell to recover by a small amount
            // then calculate the proportion of grass to poop
            poop[x][y] *= recoverRate;
            lattice[x][y] = grass[x][y] / (1 + poop[x][y] );
            
      }

/////////////////////////////////////////////////////////////// 
      void drawScape ()
      {
        image(   ag.getImage(),0,0 );
        for( int x = 0; x < w; x++){
        for( int y = 0; y < h; y++){
             
            int val = round( map( grass[x][y], 0, maxCapacity, 0, 255) );
            
            int drawX = floor( map( x, 0, w, 0, width ) );
            int drawY = floor( map( y, 0, h, 0, height ) );
            
            int dimn = round( width/w );
            
            if (lat1.get(x,y) == BURNING){
              fill(255,0,0,255);
            }
            else {
              fill( 255-val, val, 255-val, 50 );
            }
            rect( drawX, drawY, dimn, dimn);
            
            //strokeWeight(1);
            //stroke(255);
          }
        }
      }

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
             /*
             int LCvalue   = (int) ag.get(x,y);
             
                  if( LCvalue == 42 ){ cellState = probableValue( BARE,FUEL, 0.6); } 
             else if( LCvalue == 51 ){ cellState = probableValue( BARE,FUEL, 0.5); }
             else if( LCvalue == 52 ){ cellState = probableValue( BARE,FUEL, 0.4); }
             else if( LCvalue == 71 ){ cellState = probableValue( BARE,FUEL, 0.3); }
             */
             cellState = probableValue( BARE,FUEL, 0.9);
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
ArrayList<PVector> fires()
{ 
     // choose a random number with a probability rate
     // if it passes the test, the new value is assigned
     // if not the default value is used. 
     
      return fires;   
};
};