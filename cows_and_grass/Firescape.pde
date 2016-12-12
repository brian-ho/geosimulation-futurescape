class Firescape extends Lattice   // when a class "extends" another class
{                                 // it has all of the functions and variables that
                                  // the "super" class has, even if they remain hidden
                                  // this is how we use Lattice to create a Firescape
                                  // we want all of the lattice functionality but we 
                                  // what it to do a few other things as well

      float maxCapacity = 100;      // the maximum amount of food
                                  // a cell in the landscape can hold
      
      float capacity[][];         // the capacity to hold food at each x,y cell 
                                  // in the lattice
                                  
      
      float growth[][];           // each cell in the environment can have a different
                                  // growth rate, set with a function similar to 
                                  // addFoodPoint()
      
                                  
      /////////////////////////////////////////////////////////////
      // VARIABLES FOR POLLUTION
                                  
      float food[][];             // new matrix that hold the food       
      float pollution[][];        // pollution matrix
      boolean pollute = false;     // we can set if we're pulluting or not
      float alpha = 0.5;          // pollution rate
      float beta = 5;             // beta is threshold for food collapse
      float recoverRate = 0.999;  // rate at which polluted cell dissipates 
      

 ///////////////////////////////////////////////////////////////
      Firescape( int _w, int _h )
      {        
        super( _w, _h, 0);  // tell the underlying lattice how big it is
        capacity   = new float[w][h];  // initialize the capacity array
        growth     = new float[w][h];  // initialize the growth array
        food       = new float[w][h];  // initialize food matrix
        pollution  = new float[w][h];  // initialize pollution matrix
        
        // NOTE: LATTICE NO LONGER HOLDS "FOOD" IT HOLDS THE RATIO
        // BETWEEN FOOD AND POLLUTION. THIS IS NOW WHAT AN AGENT USES
        // TO CHOOSE LOCATION
        
        // lattice(x,y) = food(x,y) / ( 1+pollution(x,y) )
        
        
      };

 ///////////////////////////////////////////////////////////////
      float harvest( int x_, int y_, float grazingRate )
      {
         // when an agent calls harvest at its x,y location,
         // it removes all of the food at that location. 
          int x = floor( map(x_, 0, width, 0, w));
          int y = floor( map(y_, 0, height, 0, h));
          
          x = constrain(x, 0, w-1 ); // make sure the x,y value
          y = constrain(y, 0, h-1 ); // isn't bigger or smaller than the lattice
          
          float harvestAmount;
          if (food[x][y] <= grazingRate) {                         
            harvestAmount = food[x][y]; // grab the amount of food at x,y
            food[x][y] = 0;                   // set the new amount of food there to zero
          }
          else{
            harvestAmount = grazingRate;
            food[x][y] -= grazingRate;
          }
                                            
                   
          if( pollute == true )            // if we are polluting
          {                                // the amount is proportional to the amount we harvested
              pollution[x][y] += harvestAmount * alpha;
          }
          
          calculatePollutionRatio(x,y);   // update the ratio between food and pollutation at this location
          
          return harvestAmount;                // return the food
      };
      
 ///////////////////////////////////////////////////////////////      
      void growFood( float growthRate )
      {
          //for every cell in the lattice, check if it is below its maximum
          //capacity, if so, grow the food incrementally by "growthRate" amount
          //if it is at capacity, leave it.
        
          for( int x = 0; x < w; x++ ){
            for( int y = 0; y < h; y++){
             
                    // if pollution is less than beta then food will grow there
                    if( food[x][y] < capacity[x][y] && pollution[x][y] < beta )
                    {
                        food[x][y] = food[x][y]+ growthRate;
                        
                    }
                    
                    calculatePollutionRatio(x,y);
            }
          }
      };

///////////////////////////////////////////////////////////////      
      void growFood( )
      {
          //for every cell in the lattice, check if it is below its maximum
          //capacity, if so, grow the food incrementally by "growthRate" amount
          //if it is at capacity, leave it.
        
          for( int x = 0; x < w; x++ ){
            for( int y = 0; y < h; y++){
             
                    // if pollution is less than beta then food will grow there
                    if( food[x][y] < capacity[x][y] && pollution[x][y] < beta )
                    {
                        food[x][y] += growth[x][y];
                       
                    }
                     calculatePollutionRatio(x,y);
            }
          }
      };

 ///////////////////////////////////////////////////////////////      
      void addFoodPoint( int foodX, int foodY, float capacityValue, float spread  )
      {
          // a food point is defined by its x,y location; the maximum value of food
          // at that location, and the rate at which it decays as one moves away 
          // from that point in space.
        
        
          for( int x = 0; x < w; x++ ){
            for( int y = 0; y < h; y++ ){
                  // for every cell in the lattice
                  // measure its distance from the food point
                  // use map to scale distance into capacity 
                  // at a distance of 0, a cell is at the capacity value
                  // at a distance of spread, and beyond, it contains no food
                 
                  float distToFoodPoint = dist(x, y, foodX, foodY);
                  float capValue        = map( distToFoodPoint, 0, spread, capacityValue, 0 );
                        capValue        = constrain( capValue, 0, maxCapacity );
                        
                        
                  // we add capacity in case there are multiple food points, where they overlap
                  // the capacity for food adds together
                  capacity[x][y] = capacity[x][y] + capValue;
                  
                      food[x][y] = capacity[x][y];
            }}
      };
      
 ///////////////////////////////////////////////////////////////      
      void addGrowthRate( int foodX, int foodY, float growthValue, float spread  )
      {
        
          for( int x = 0; x < w; x++ ){
            for( int y = 0; y < h; y++ ){

                  float distToFoodPoint = dist(x, y, foodX, foodY);      
                  float cellGrowthValue = (distToFoodPoint <= spread)? growthValue : 0;
                  
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
            // then calculate the proportion of food to pollution
            pollution[x][y] *= recoverRate;
            lattice[x][y] = food[x][y] / (1 + pollution[x][y] );
            
      }

/////////////////////////////////////////////////////////////// 
      void drawScape ()
      {
        for( int x = 0; x < w; x++){
        for( int y = 0; y < h; y++){
             
            int val = round( map( food[x][y], 0, maxCapacity, 0, 255) );
            
            int drawX = floor( map( x, 0, w, 0, width ) );
            int drawY = floor( map( y, 0, h, 0, height ) );
            
            int dimn = round( width/w );
            
            fill( 255-val, val, 255-val, 50 );
            rect( drawX, drawY, dimn, dimn);
          }
        }
      }

};