class cow
{
   // our agent class
   // a cow goes moo
   
   ///////////////////////////////////////////////////////////////
   // INTERNAL VARIABLES
   
   PVector loc;                // stores current location
   PVector dest;               // stores cow's current destination
   float grazingRate;          // rate of consumption
   float ruminateRate;         // rate of digestion or metabolic rate
   float stomach = 5;       // starting amount of food
   float speed = 0.5;
   float cowMass = 1;             // when it was but a wee calf ...
   int vision;                 // vision range or kernel size
   int w, h;                   // Firescape width and height
   char status;
   boolean alive = true;       // zombie cows?
   Kernel k;                   // kernel for the cow
 
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
          k.setNeighborhoodDistance(vision *  (int)(w/width));
          
          // assign it a random x,y location on the Firescape
          int randomXLoc = (int) random( 0, width );
          int randomYLoc = (int) random( 0, height );
        
          loc = new PVector( randomXLoc, randomYLoc );
          
          // find a destination
          dest = new PVector();
          ruminate ( scape );
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
          
          // find a destination
          dest = new PVector();
          ruminate( scape );
      };
          
 ///////////////////////////////////////////////////////////////
 // function to run multiple object behaviors
    void update( Firescape scape )
    {
       // at a given frame, a cow is doing one (or more) of the follwing:
       // (1) ruminate : cow pondering logic
       //     cow looks in neighborhood for desirable grass.
       //     if more than one option exists, set destination to most preferable.
       //     also digest food in stomach according to metabolic rate and grow size.
       //     if amount need to eat exceeds stored food, cow dies.    
       
       // (2) moove : move toward destination and aerate grass, if necessary. 
       
       // (3) graze : if at destination, eat down grass
       
       // (4) poop : does what it says on the tin
        
        switch(status)
        {
          case 'G': 
            graze( scape );
            break;
          case 'M': 
            moove();
            break;
          case 'R':
            ruminate( scape );
            break;
          case 'P':
            poop();
            break;
        }
    };
        
 ///////////////////////////////////////////////////////////////
    void drawMyself()
    {
        // if alive, draw to the screen
      String thought = "moo...";
        if( alive ) 
        {
            // mark the destination with a red circle
            noStroke();
            fill( 255, 0, 0 );
            ellipse( dest.x, dest.y, 4, 4 );
            
            // draw a line from cow to destination
            strokeWeight( 1 );
            stroke( 255, 0 , 0 );
            line( loc.x, loc.y, dest.x, dest.y );
            
            // draw cow, with fill depending on status
            stroke( 255, 255, 255 );
            
            switch(status)
            {
              case 'G': 
                thought = "nom...";
                fill (0,0,0);
                break;
              case 'M': 
                thought = "moo...";
                fill (255,255,255);
                break;
              case 'R':
                thought = "hmm...";
                fill (255,0,0);
                break;
            }
            
            ellipse( loc.x, loc.y, 8, 8 );
            fill( 255, 0, 0 );
            
            // create cow text
            text( thought, loc.x + 10, loc.y);
            text("food: " + nf(stomach, 1, 2),loc.x + 10, loc.y + 15);
            text( "V:" + vision + " G:" + grazingRate + " R:" + ruminateRate, loc.x + 10, loc.y + 30);
            //text( status + " " + dest.x + ", " + dest.y, loc.x + 10, loc.y + 30);
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
        
        int xScape = floor( map( loc.x, 0, width, 0, w ) );
        int yScape = floor( map( loc.y, 0, height, 0, h ) );
        
        println ("SCAPE POS:", xScape, yScape);
        
        PVector locScape = new PVector (xScape, yScape);
        
        PVector maxNeighbor = k.getMax( scape, locScape );
        
        if( maxNeighbor.z > 0 )
        {
          dest.x = map(maxNeighbor.x, 0, w, 0, width);
          dest.y = map(maxNeighbor.y, 0, h, 0, height);
          
          println ( "NEW DEST:", dest.x, dest.y);
          status = 'M';
        }
        else
        {
          PVector delta = new PVector();
          delta.x = (int)random (-vision, vision);
          delta.y = (int)random (-vision, vision);
          
          if ( delta.x == 0 && delta.y == 0 )
          {
            status = 'R';
          }
          else if ( delta.x != 0 || delta.y != 0 )
          {         
            dest.x = wrap( loc.x + delta.x, width);
            dest.y = wrap( loc.y + delta.y, width);
            
            status = 'M';
          }
        }
        
        // subtract the food amount needed to stay alive for one time step
        // from the total amount this agent is holding.
        
        //foodAmount -= ruminateRate;
        
        // if the amount needed to eat is more than the agent has left
        // the agent "dies"
        
        //if( foodAmount <= 0 ) 
        //    alive = false; 
    };
    
 ///////////////////////////////////////////////////////////////
    void graze( Firescape scape )
    {   
        // simply extract the food from the fireScape at current location
        // and add it to the food the agent currently has stored
        float mouthful = scape.harvest( (int)loc.x, (int)loc.y, grazingRate );
        
        if (mouthful < grazingRate)
        {
         status = 'R';
        }
        else if (mouthful == grazingRate)
        {
          stomach += mouthful;
          status = 'G';
        }
    };

 ///////////////////////////////////////////////////////////////
    void moove()// Firescape scape )
    { 
        PVector velocity = PVector.sub(dest, loc);
        float mag = velocity.mag();
        if ( velocity.mag() > speed )
        {
          velocity.setMag(speed);
            
          loc.x = wrap( loc.x + velocity.x, width );
          loc.y = wrap( loc.y + velocity.y, height );
          
          status = 'M';
        }
        else if ( velocity.mag() <= speed )
        {
          loc.x = dest.x;
          loc.y = dest.y;
          //println ("ARRIVED", "D:", dest.x, dest.y, "L:", loc.x, loc.y);
          status = 'G';
        }
    };
    
  ///////////////////////////////////////////////////////////////
    void poop()// Firescape scape )
    {  
    };
    
 ///////////////////////////////////////////////////////////////
    float wrap( float index, int iSize)
    {
            // just make sure the agent location doesn't give
            // us an error when accessing a cell from the Firescape
            // wrap ensures the agent is on a torus surface
            float result;
      
            if( index < 0 ){
              result = abs(index);
              return result;
            }; //N.B. index is negative here
            if( index >= iSize )
            {
              result = iSize - (index - iSize);
              return result;
            }
            return index;
    };
}