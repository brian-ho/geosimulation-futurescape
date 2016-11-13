class ScapeAgent
{
   // our agent class
   // scape agent
  
 ///////////////////////////////////////////////////////////////
 // INTERNAL VARIABLES
 
    PVector loc;                // PVector holding x,y location
    float   foodAmount = 3;    // starting amount of food
    float   foodConsumedPerDay; // metabolic rate, how much it "eats" per time step
    int     vision;             // how far can it "see" (i.e. kernel size)
    int     w, h;               // width and height of the lattice it is on
    boolean alive = true;       // boolean variable that will mark when agent dies
    Kernel  k;                  // personal kernel function
    
  
 ///////////////////////////////////////////////////////////////
 // constructor
    ScapeAgent( int _w, int _h, float _foodConsumedPerDay, int _vision )
    {
        w = _w;  //  width of lattice
        h = _h;  // height of lattice
        foodConsumedPerDay = _foodConsumedPerDay; // metabolic rate
        vision             = _vision;             // distance of vision (kernel size)
        
        // initialize internal kernel function
        // set the neighborhood distance to "vision" this is how far it can see
        // in terms of locating food resources in its immediate neighborhood
        
        k = new Kernel();
        k.setNeighborhoodDistance( vision );
        
        // assign it a random x,y location on the lattice
        
        int randomXLoc = (int) random( 0, w-1 );
        int randomYLoc = (int) random( 0, h-1 );
      
        loc = new PVector( randomXLoc, randomYLoc );
    
    };
    
 ///////////////////////////////////////////////////////////////
    ScapeAgent( int _w, int _h, float _foodConsumedPerDay, int _vision, int xLoc, int yLoc )
    {
        w = _w;  //  width of lattice
        h = _h;  // height of lattice
        foodConsumedPerDay = _foodConsumedPerDay; // metabolic rate
        vision             = _vision;             // distance of vision (kernel size)
        
        // initialize internal kernel function
        // set the neighborhood distance to "vision" this is how far it can see
        // in terms of locating food resources in its immediate neighborhood
        
        k = new Kernel();
        k.setNeighborhoodDistance( vision );

        // x,y location assigned explicitly with input parameters above, xLoc, yLoc
        loc = new PVector( xLoc, yLoc );
    
    };
    
 ///////////////////////////////////////////////////////////////
    void update( Sugarscape scape )
    {
       // (1) updateLocation : using kernel look in my neighborhood for
       //     the maximum food source, go there. if there more than one, 
       //     go to the closest one
       
       // (2) harvestFood : once at that location, extract the food from 
       //     the sugarscape. 
       
       // (3) consumeFood : on each time step, the metabolic rate determines
       //     how much food an agent needs to eat. eat that amount. if the 
       //     amount needed to eat exceeds how much food the agent has, the agent dies
      
        updateLocation( scape );
        harvestFood( scape );
        consumeFood();
    };
    
 ///////////////////////////////////////////////////////////////
    void drawMyself()
    {
        // if alive, draw to the screen as a rectangle
        // the 50x50 lattice is scaled to fit the screen
      
        if( alive ) 
        {
            noStroke();
            fill( 255, 0, 255 );
            float xDraw = map( loc.x, 0, w, 0, width );
            float yDraw = map( loc.y, 0, h, 0, height);
            rect( xDraw, yDraw, 6, 6 );
        }
    };
    
 ///////////////////////////////////////////////////////////////
    void updateLocation( Sugarscape scape )
    {
       // using the Kernel's getMax() function 
       // find the closest cell with the maximum amount of food
       // use that cell's x,y location and move there. 
       // if there is no cell within the kernel that has food
       // move randomly from current location
      
      
        PVector maxNeighbor = k.getMax( scape, loc );
        
        if( maxNeighbor.z > 0 )
        {
          loc.x = maxNeighbor.x;
          loc.y = maxNeighbor.y;
        }
        else
        {
            loc.x = wrap( loc.x + random(-5,5), w );
            loc.y = wrap( loc.y + random(-5,5), h );
        }
  
    };
    
 ///////////////////////////////////////////////////////////////
    void harvestFood( Sugarscape scape )
    {   
        // simply extract the food from the sugarScape at currently location
        // and add it to the food the agent currently has stored
      
        foodAmount += scape.harvest( (int)loc.x, (int)loc.y );
    };

 ///////////////////////////////////////////////////////////////
    void consumeFood()
    {
        // subtract the food amount needed to stay alive for one time step
        // from the total amount this agent is holding.
        
        
        foodAmount -= foodConsumedPerDay;
        
        // if the amount needed to eat is more than the agent has left
        // the agent "dies"
        
        if( foodAmount <= 0 ) 
            alive = false;    
    };
    
 ///////////////////////////////////////////////////////////////
    float wrap( float index, int iSize)
    {
            // just make sure the agent location doesn't give
            // us an error when accessing a cell from the lattice
            // wrap ensures the agent is on a torus surface
      
            if( index < 0 )           index = iSize + index; //N.B. index is negative here
            else if( index >= iSize ) index = index - iSize;
            
            return index;
    };

};