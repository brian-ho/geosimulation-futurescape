class Firescape extends Lattice   // when a class "extends" another class
{                                 // it has all of the functions and variables that
                                  // the "super" class has, even if they remain hidden
                                  // this is how we use Lattice to create a Firescape
                                  // we want all of the lattice functionality but we 
                                  // what it to do a few other things as well

      float maxCapacity = 100;      // the maximum amount of grass
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
      

 ///////////////////////////////////////////////////////////////
      Firescape( int _w, int _h )
      {        
        super( _w, _h, 0);  // tell the underlying lattice how big it is
        capacity   = new float[w][h];  // initialize the capacity array
        growth     = new float[w][h];  // initialize the growth array
        grass      = new float[w][h];  // initialize grass matrix
        poop       = new float[w][h];  // initialize poop matrix
        
        // NOTE: LATTICE NO LONGER HOLDS "Grass" IT HOLDS THE RATIO
        // BETWEEN Grass AND POLLUTION. THIS IS NOW WHAT AN AGENT USES
        // TO CHOOSE LOCATION
        
        // lattice(x,y) = grass(x,y) / ( 1+poop(x,y) )
      };

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
        for( int x = 0; x < w; x++){
        for( int y = 0; y < h; y++){
             
            int val = round( map( grass[x][y], 0, maxCapacity, 0, 255) );
            
            int drawX = floor( map( x, 0, w, 0, width ) );
            int drawY = floor( map( y, 0, h, 0, height ) );
            
            int dimn = round( width/w );
            
            fill( 255-val, val, 255-val, 50 );
            rect( drawX, drawY, dimn, dimn);
            
            //strokeWeight(1);
            //stroke(255);
          }
        }
      }

};