class cow
{
   // our agent class
   // a cow goes moo
   
   ///////////////////////////////////////////////////////////////
   // INTERNAL VARIABLES
   
   PVector loc;                // stores current location
   PVector dest = new PVector();               // stores cow's next destination
   float foodAmount = 5;       // starting amount of food (OUT OF?)
   float grazingRate;          // rate of consumption
   float ruminateRate;         // rate of digestion or metabolic rate
   float speed = 0.1;
   int size = 1;               // when it was but a wee calf ...
   int vision;                 // vision range or kernel size
   int w, h;                   // Firescape width and height
   int status;
   String thought;
   boolean alive = true;       // zombie cows?
   Kernel k;                   // kernel for the cow
 
  int R = 0;
  int M = 1;
  int G = 2;
  int P = 3;
 
   ///////////////////////////////////////////////////////////////
   // constructor
       cow( int _w, int _h, float _grazingRate, float _ruminateRate, int _vision )
      {
          w = _w;  //  width of Firescape
          h = _h;  // height of Firescape
          grazingRate  = _grazingRate;        // metabolic rate
          ruminateRate = _ruminateRate;
          vision       = _vision;             // distance of vision (kernel size)
          
          // initialize internal kernel function
          // set the neighborhood distance to "vision" this is how far it can see
          // in terms of locating food resources in its immediate neighborhood
          
          k = new Kernel();
          k.setNeighborhoodDistance( vision );
          
          // assign it a random x,y location on the Firescape
          
          int randomXLoc = (int) random( 0, w-1 );
          int randomYLoc = (int) random( 0, h-1 );
        
          loc = new PVector( randomXLoc, randomYLoc );
          
          ruminate (scape);
      }
      
     ///////////////////////////////////////////////////////////////
     // alternate constructor with location
      cow( int _w, int _h, float _grazingRate, float _ruminateRate, int _vision, int xLoc, int yLoc )
      {
          w = _w;  //  width of Firescape
          h = _h;  // height of Firescape
          grazingRate  = _grazingRate;        // metabolic rate
          ruminateRate = _ruminateRate;
          vision       = _vision;             // distance of vision (kernel size)
          
          // initialize internal kernel function
          // set the neighborhood distance to "vision" this is how far it can see
          // in terms of locating food resources in its immediate neighborhood
          
          k = new Kernel();
          k.setNeighborhoodDistance( vision );
  
          // x,y location assigned explicitly with input parameters above, xLoc, yLoc
          loc = new PVector( xLoc, yLoc );
          
          ruminate (scape);
      };
          
 ///////////////////////////////////////////////////////////////
 // function to run multiple object behaviors
    void update( Firescape scape )
    {
       // at a given frame, a cow is doing one (or more) of the follwing:
       // (1) ruminate : cow pondering logic
       //     if no destination, cow looks in neighborhood for desirable grass.
       //     if more than one option exists, set destination to most preferable.
       //     also digest food in stomach according to metabolic rate and grow size.
       //     if amount need to eat exceeds stored food, cow dies.    
       
       // (2) moove : move toward destination and aerate grass, if necessary. 
       
       // (3) graze : if at destination, eat down grass
       
       // (4) poop : dows what it says on the tin
        
        if (loc == dest) {
          println ("YES");
          graze(scape);
        }
        
        else if (loc != dest) {
          moove();
        }
        
        poop ( scape );
    };
        
 ///////////////////////////////////////////////////////////////
    void drawMyself()
    {
        // if alive, draw to the screen
        // the 50x50 Firescape is scaled to fit the screen
        
        if( alive ) 
        {
            strokeWeight( 1 );
            stroke( 255, 255, 255 );

            if ( status == R ){ 
              thought = "THIKING";
              fill ( 255, 255, 255 );
            }
            else if ( status == G ){  
              thought = "EATING";
              fill (0, 0, 0 );
            }
            else if ( status == M ){
              thought = "MOVING";
              fill (255, 0, 0 );
            }
            float xCow = map( loc.x, 0, w, 0, width );
            float yCow = map( loc.y, 0, h, 0, height );
            ellipse( xCow, yCow, 8, 8 );
            fill( 255, 0, 0 );
            text( thought, xCow, yCow);
            
            noStroke();
            fill( 255, 0, 0 );
            float xDest = map( dest.x, 0, w, 0, width );
            float yDest = map( dest.y, 0, h, 0, height );
            ellipse( xDest, yDest, 4, 4 );
            
            strokeWeight( 1 );
            stroke( 255, 0 , 0 );
            line( xCow, yCow, xDest, yDest );
        }  
    };
    
   ///////////////////////////////////////////////////////////////
    void ruminate( Firescape scape )
    {
       // using the Kernel's getMax() function 
       // find the closest cell with the maximum amount of food
       // use that cell's x, y location and move there. 
       // if there is no cell within the kernel that has food
       // move randomly from current location
      
           
        PVector maxNeighbor = k.getMax( scape, loc );
        
        if( maxNeighbor.z > 0 )
        {
          dest.x = maxNeighbor.x;
          dest.y = maxNeighbor.y;
        }
        else
        {
            dest.x = wrap( loc.x + random(-5,5), w );
            dest.y = wrap( loc.y + random(-5,5), h );
        }
        
        status = R;
    };
    
 ///////////////////////////////////////////////////////////////
    void graze( Firescape scape )
    {   
        // simply extract the food from the sugarScape at currently location
        // and add it to the food the agent currently has stored
        dest = loc;
        foodAmount += scape.harvest( (int)loc.x, (int)loc.y );
        status = G;
    };

 ///////////////////////////////////////////////////////////////
    void moove()// Firescape scape )
    {
        // subtract the food amount needed to stay alive for one time step
        // from the total amount this agent is holding.
        
        
        //foodAmount -= ruminateRate;
        
        // if the amount needed to eat is more than the agent has left
        // the agent "dies"
        
        //if( foodAmount <= 0 ) 
        //    alive = false; 
        PVector velocity = PVector.sub(dest, loc);
        if ( velocity.mag() > speed ){
          velocity.setMag(speed);}
        loc.add(velocity);
        
        status = M;
        if ( velocity.mag() == 0 ){ dest = loc; }
    };
    
  ///////////////////////////////////////////////////////////////
    void poop( Firescape scape )
    {
        // subtract the food amount needed to stay alive for one time step
        // from the total amount this agent is holding.
        
        
        //foodAmount -= ruminateRate;
        
        // if the amount needed to eat is more than the agent has left
        // the agent "dies"
        
        //if( foodAmount <= 0 ) 
        //    alive = false;    
    };
    
 ///////////////////////////////////////////////////////////////
    float wrap( float index, int iSize)
    {
            // just make sure the agent location doesn't give
            // us an error when accessing a cell from the Firescape
            // wrap ensures the agent is on a torus surface
      
            if( index < 0 )           index = iSize + index; //N.B. index is negative here
            else if( index >= iSize ) index = index - iSize;
            
            return index;
    };

};
        