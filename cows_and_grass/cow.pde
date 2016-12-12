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
   int status;
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
          
          // find a destination
          dest = new PVector();
          ruminate ();
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
          ruminate();
      };
          
 ///////////////////////////////////////////////////////////////
 // function to run multiple object behaviors
    void update()// Firescape scape )
    {
      println();
      println(frameCount);

       // at a given frame, a cow is doing one (or more) of the follwing:
       // (1) ruminate : cow pondering logic
       //     cow looks in neighborhood for desirable grass.
       //     if more than one option exists, set destination to most preferable.
       //     also digest food in stomach according to metabolic rate and grow size.
       //     if amount need to eat exceeds stored food, cow dies.    
       
       // (2) moove : move toward destination and aerate grass, if necessary. 
       
       // (3) graze : if at destination, eat down grass
       
       // (4) poop : dows what it says on the tin
        
        if (status == G)
        {
          println ("-decided to graze");
          graze(); //scape);
        }
        
        else if (status == M) {
          println ("-decided to move");
          moove();
        }
        

        
        //poop ( scape );
    };
        
 ///////////////////////////////////////////////////////////////
    void drawMyself()
    {
        // if alive, draw to the screen
        // the 50x50 Firescape is scaled to fit the screen
      String thought = "moo ...";
        if( alive ) 
        {
            strokeWeight( 1 );
            stroke( 255, 255, 255 );

            if ( status == R ){ 
              println( "THINKING");
              fill ( 255, 255, 255 );
            }
            else if ( status == G ){  
              println ("EATING");
              fill (0, 0, 0 );
            }
            else if ( status == M ){
              println("MOVING");
              fill (255, 0, 0 );
            }
            //float xCow = map( loc.x, 0, w, 0, width );
            //float yCow = map( loc.y, 0, h, 0, height );
            ellipse( loc.x, loc.y, 8, 8 );
            fill( 255, 0, 0 );
            text( thought + " food: " + nf(foodAmount, 1, 2), loc.x + 5, loc.y);
            text( "V:" + vision + " G:" + grazingRate + " R:" + ruminateRate, loc.x +5, loc.y+15);
            
            noStroke();
            fill( 255, 0, 0 );
            //float xDest = map( dest.x, 0, w, 0, width );
            //float yDest = map( dest.y, 0, h, 0, height );
            ellipse( dest.x, dest.y, 4, 4 );
            
            strokeWeight( 1 );
            stroke( 255, 0 , 0 );
            line( loc.x, loc.y, dest.x, dest.y );
            
            println( "LOC: " + loc.x + ", " + loc.y );
            println( "DEST: " + dest.x + ", " + dest.y );
        }  
    };
    
   ///////////////////////////////////////////////////////////////
    void ruminate()// Firescape scape )
    {
       println("ruminate");
       // using the Kernel's getMax() function 
       // find the closest cell with the maximum amount of food
       // use that cell's x, y location and move there. 
       // if there is no cell within the kernel that has food
       // move randomly from current location
      
           
        //PVector maxNeighbor = k.getMax( scape, loc );
        
        /*if( maxNeighbor.z > 0 )
        {
          dest.x = maxNeighbor.x;
          dest.y = maxNeighbor.y;
        }
        else
        {*/
          println("looking from", "L:", loc.x, loc.y);
          PVector temp = new PVector();
          float tempX = loc.x;
          float tempY = loc.y;
          //dest.x = (int)wrap( temp.x + random(-vision,vision), w );
          //dest.y = (int)wrap( temp.y + random(-vision,vision), h );
          dest.x = (int)(tempX + random(-vision,vision));
          println(loc.x, dest.x, tempX);
          dest.y = (int)(tempY + random(-vision,vision));
          
          println ("NEW DESTINATION", "D:", dest.x, dest.y, "L:", loc.x, loc.y);
          arrived = false;
        //}
        
        // subtract the food amount needed to stay alive for one time step
        // from the total amount this agent is holding.
        
        //foodAmount -= ruminateRate;
        
        // if the amount needed to eat is more than the agent has left
        // the agent "dies"
        
        //if( foodAmount <= 0 ) 
        //    alive = false; 
        status = M;
    };
    
 ///////////////////////////////////////////////////////////////
    void graze()// Firescape scape )
    {   
        // simply extract the food from the fireScape at current location
        // and add it to the food the agent currently has stored
        //float temp = scape.harvest( (int)loc.x, (int)loc.y, grazingRate );
        //if (temp == 0){
        // (scape);
        //}
        //else if (temp != 0){
        //  foodAmount += temp;
        status = G;
        ruminate();
        //}
    };

 ///////////////////////////////////////////////////////////////
    void moove()// Firescape scape )
    { 
        println("move");
        PVector velocity = PVector.sub(dest, loc);
        float mag = velocity.mag();
        println(velocity.mag(), speed);
        if ( velocity.mag() > speed )
        {
          velocity.setMag(speed);
            
          loc.x = wrap( loc.x + velocity.x, w );
          loc.y = wrap( loc.y + velocity.y, h );
          status = M;
        }
        else if ( velocity.mag() < speed )
        {
          loc.x = dest.x;
          loc.y = dest.y;
          println ("ARRIVED", "D:", dest.x, dest.y, "L:", loc.x, loc.y);
          status = G;
          arrived = true;
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