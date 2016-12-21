class Cow
{
   // our agent class
   // a cow goes moo
   
   ///////////////////////////////////////////////////////////////
   // INTERNAL VARIABLES
   
   PVector loc;                // stores current location
   PVector dest;               // stores cow's current destination
   float grazingRate;          // rate of consumption
   float ruminateRate;         // rate of digestion or metabolic rate
   float stomach = 5;          // starting amount of food
   float speed = 0.5;
   float mass = 1;             // when it was but a wee calf ...scale
   int vision;                 // vision range or kernel size
   int w, h;                   // Firescape width and height
   char status;                // flag for move next turn
   boolean alive = true;       // zombie cows?
   Kernel k;                   // kernel for the cow
 
   ///////////////////////////////////////////////////////////////
   // constructor
       Cow( int _w, int _h, float _grazingRate, float _ruminateRate, int _vision, Firescape scape )
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
          k.setNeighborhoodDistance(round(vision / (int)scale));
          
          int randomXLoc;
          int randomYLoc;
          do {
          randomXLoc = (int) random( 0, width );
          randomYLoc = (int) random( 0, height );
          } while ( scape.getTree()[floor(randomXLoc/scale)][floor(randomYLoc/scale)] == -9999 || scape.getGrass()[floor(randomXLoc/scale)][floor(randomYLoc/scale)] < 125   );
          // assign it a random x,y location on the Firescape
          
          loc = new PVector( randomXLoc, randomYLoc );
          
          // find a destination
          dest = new PVector();
          status = 'R';
      }
      
     ///////////////////////////////////////////////////////////////
     // alternate constructor with location
       Cow( int _w, int _h, float _grazingRate, float _ruminateRate, int _vision, Firescape scape, int xLoc, int yLoc )
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
          k.setNeighborhoodDistance(round(vision / (int)scale));
          
          loc = new PVector( xLoc, yLoc );
          
          // find a destination
          dest = new PVector();
          status = 'R';
      }
          
 ///////////////////////////////////////////////////////////////
 // function to run multiple object behaviors
    void update( Firescape scape, ArrayList<Cow> herd )
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
          case 'Q':
          case 'M': 
            moove( herd, scape );
            break;
          case 'R':
            ruminate( scape );
            break;
          case 'P':
            poop();
            break;
        }
                
        // subtract the food amount needed to stay alive for one time step
        // from the total amount this agent is holding.
        // convert this amount to mass
        stomach -= ruminateRate;
        mass = constrain(mass + ruminateRate, 0, 500); 
                
        // if the amount needed to eat is more than the agent has left
        // the agent "dies"
        if( stomach <= 0 ) alive = false; 
        if( scape.onFire((int)loc.x,(int)loc.y)) alive = false; 
    };
        
 ///////////////////////////////////////////////////////////////
    void drawMyself()
    {
        // if alive, draw to the screen
      String thought = "moo...";
        if( alive ) 
        {
            // mark the destination with a red circle
            //noStroke();
            //fill( 255, 0, 0 );
            //ellipse( dest.x, dest.y, 4, 4 );
            
            // draw a line from cow to destination
            //strokeWeight( 1 );
            //stroke( 255, 0 , 0 );
            //line( loc.x, loc.y, dest.x, dest.y );
            
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
              case 'Q':
                thought = "?";
                fill (255,0,0);
                break;
            }
            
            ellipse( loc.x, loc.y, 4, 4 );
            fill( 255, 0, 0 );
            
            // create cow text
            //text( thought, loc.x + 10, loc.y);
            //text("F: " + nf(stomach, 1, 2) + " M:" + nf(mass, 1, 2),loc.x + 10, loc.y + 15);
            //text( "V:" + vision + " G:" + grazingRate + " R:" + nf(ruminateRate, 1, 2), loc.x + 10, loc.y + 30);
            //text( status + " " + dest.x + ", " + dest.y, loc.x + 10, loc.y + 30);
        }  
    };
    
   ///////////////////////////////////////////////////////////////
    void ruminate( Firescape scape) //, ArrayList<Cow> herd )
    {        
       // convert cow position to Firescape grid
       int xScape = floor( map( loc.x, 0, width, 0, w ) );
       int yScape = floor( map( loc.y, 0, height, 0, h ) );
        
       // using the Kernel's getMax() function 
       // find the closest cell with the maximum amount of food
       // use that cell's x, y location and move there. 
       // if there is no cell within the kernel that has food
       // move randomly from current location
        PVector locScape = new PVector (xScape, yScape);
        PVector maxNeighbor = k.getMax( scape.getGrass(), locScape );
        
        // grass is always greener ... to a point
        if( maxNeighbor.z > 0.0 )
        {
          dest.x = map(maxNeighbor.x, 0, w, 0, width) + floor(random(0,scale));
          dest.y = map(maxNeighbor.y, 0, h, 0, height) + floor(random(0,scale));
          
          //println ( "NEW DEST:", dest.x, dest.y);
          status = 'M';
        }
        /*// cows be patient
        else if( maxNeighbor.z > 0 )
        {
          dest = loc;
          status = 'R';
        }
        */
        // wanderin' about ...
        else
        {
          // pick new destination within visible range
          PVector delta = new PVector();
          delta.x = (int)random (-vision, vision);
          delta.y = (int)random (-vision, vision);
          
          // new destination cannot be same as current location
          if ( delta.x == 0 && delta.y == 0 )
          {
            status = 'R';
          }
          else if ( delta.x != 0 || delta.y != 0 )
          {         
            dest.x = wrap( loc.x + delta.x, width);
            dest.y = wrap( loc.y + delta.y, width);
            
            status = 'Q';
          }
        }
        // restrictions on movement
        if ( abs(scape.getDEM().get((int)loc.x, (int)loc.y) - scape.getDEM().get((int)dest.x, (int)dest.y)) > 75 ){ status = 'R';}
        if ( scape.getTree()[xScape][yScape] > 125 || scape.getTree()[xScape][yScape] == -9999 ){ status = 'R';}
        
        /*
        for ( Fence f : fences)
        {
          if ( f.contains(dest.x, dest.y) && f.contains(loc.x,loc.y) == false)
          {
           status = 'R'; 
          }
        }
         */
        //
    };
    
 ///////////////////////////////////////////////////////////////
    void graze( Firescape scape )
    {   
        // simply extract the food from the fireScape at current location
        // and add it to the food the agent currently has stored
        float mouthful = scape.harvest( (int)loc.x, (int)loc.y, grazingRate );
        
        // seek new pastures ...
        if (mouthful < grazingRate)
        {
         status = 'R';
        }
        // eat up!
        else if (mouthful == grazingRate)
        {
          stomach += mouthful;
          status = 'G';
        }
    };

 ///////////////////////////////////////////////////////////////
    void moove( ArrayList<Cow> herd, Firescape scape )
    { 
        dest.add(herding( herd ).setMag(scale/2));
      
        // cow heading should be toward destination, at speed
        PVector velocity = PVector.sub(dest, loc);
        float mag = velocity.mag();
        
        // if still distant
        if ( mag > speed )
        {
          velocity.setMag(speed);
                  // avoid collisions
          velocity.add(separate(herd).setMag(scale/2));
          velocity.add( fear ( scape ).setMag(speed*2));
          
          PVector next = new PVector(0, 0);
          next.x = wrap( loc.x + velocity.x, width );
          next.y = wrap( loc.y + velocity.y, height );
          
          for ( Fence f : fences)
          {
            if ( f.contains(loc.x, loc.y) && f.contains(next.x,next.y) == false)
            {
             println ("NO GO");
             dest.x = wrap( loc.x - velocity.x*2, width );
             dest.y = wrap( loc.y - velocity.y*2, height );
             status = 'M';
             return;
            }
          }
          
          if (status != 'Q')
          {
            status = 'M';
            loc.x = next.x; loc.y = next.y;
          }
        }
        // if arrived
        else if ( velocity.mag() <= speed )
        {
          velocity.add(separate(herd).setMag(scale/2));
          velocity.add( fear ( scape ).setMag(100));
          
          loc.x = dest.x;
          loc.y = dest.y;
          status = 'G';
        }
    };
    
  ///////////////////////////////////////////////////////////////
    void poop()// Firescape scape )
    {  
    };
    
 ///////////////////////////////////////////////////////////////
    // Keep your distance!
    // Method checks for nearby cows and adjusts destination
    PVector separate (ArrayList<Cow> herd) {
      float desiredseparation = scale;
      PVector steer = new PVector(0,0);
      int count = 0;
      // For every cow in the system, check if it's too close
      for (Cow other : herd) {
        if (mass < other.mass){
          float d = PVector.dist(loc,other.loc);
          // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
          if ((d > 0) && (d < desiredseparation)) {
            // Calculate vector pointing away from neighbor
            PVector diff = PVector.sub(loc,other.loc);
            diff.normalize();
            diff.div(d);        // Weight by distance
            steer.add(diff);
            count++;            // Keep track of how many
          }
        }
      }
      // Average -- divide by how many
      if (count > 0) {
        steer.div((float)count);
      }
  
      // As long as the vector is greater than 0
      if (steer.mag() > 0) {
        steer.normalize();
        //steer.mult(speed);
        //steer.sub(velocity);
        //steer.limit(maxforce);
      }
      return steer;
    }
 
  ///////////////////////////////////////////////////////////////
    // Keep your distance!
    // Method checks for nearby cow destinations and adjusts own destination
    PVector herding (ArrayList<Cow> herd) {
      float desiredseparation = scale;
      PVector steer = new PVector(0,0);
      int count = 0;
      // For every cow destination in the system, check if it's too close
      for (Cow other : herd) {
        if (mass < other.mass){
          float d = PVector.dist(dest,other.dest);
          // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
          if ((d > 0) && (d < desiredseparation)) {
            // Calculate vector pointing away from neighbor
            PVector diff = PVector.sub(loc,other.loc);
            diff.normalize();
            diff.div(d);        // Weight by distance
            steer.add(diff);
            count++;            // Keep track of how many
          }
        }
      }
      // Average -- divide by how many
      if (count > 0) {
        steer.div((float)count);
      }
  
      // As long as the vector is greater than 0
      if (steer.mag() > 0) {
        steer.normalize();
        //steer.mult(speed);
        //steer.sub(velocity);
        //steer.limit(maxforce);
      }
      return steer;
    }
    
    ///////////////////////////////////////////////////////////////
    // Keep your distance!
    // Method checks for nearby cow destinations and adjusts own destination
    PVector fear ( Firescape scape ) {
      
      float desiredseparation = scale*2;
      PVector steer = new PVector(0,0);
      int count = 0;
      
      // For every cow destination in the system, check if it's too close
      for ( PVector f : scape.fires()) {
          int fireX = floor(map(f.x, 0, w, 0, width));
          int fireY = floor(map(f.y, 0, h, 0, height));
          
          f = new PVector (fireX, fireY);
          
          float d = PVector.dist(loc, f);
          // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
          if ((d > 0) && (d < desiredseparation)) {
            //println("FLEE!");
            // Calculate vector pointing away from neighbor
            PVector diff = PVector.sub(loc, f);
            diff.normalize();
            diff.div(d);        // Weight by distance
            steer.add(diff);
            count++;            // Keep track of how many
          
        }
      }
      // Average -- divide by how many
      if (count > 0) {
        steer.div((float)count);
      }
  
      // As long as the vector is greater than 0
      if (steer.mag() > 0) {
        steer.normalize();
        //steer.mult(speed);
        //steer.sub(velocity);
        //steer.limit(maxforce);
      }
      return steer;
    }
 
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
    
    float mass() { return mass; };
}