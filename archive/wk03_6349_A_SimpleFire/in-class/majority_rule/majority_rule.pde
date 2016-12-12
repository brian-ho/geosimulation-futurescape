Kernel k;
Lattice lat1;
Lattice lat2;
int z = 4;


void setup()
{
    size(400,400);
    frameRate(10);
    
     //  random 0,1 binary lattice 400x400.
      //  each cell as a 'prob' probablity of being assigned value '1'
    float prob = 0.2;
          lat1 = new Lattice(400,400, (int)0, (int)1, prob);
   lat2 = new Lattice(400,400);
   
     k = new Kernel();
     k.isTorus();
    
}


void draw() // loops over and over until we quit
{
    background(0); // set the background to black RGB = 0;
    
        // to cycle through every cell in the lattice we need to index each
        // cell using its x,y coordinates. the nested for() loop lets us do that
        // for each x value, it cycles through every y value. the end result
        // is the full permutation of coordinates in the matrix. We use these
        // x and y coordinates to extract thev values of each cell.
        // Note: this nested loop runs within the draw() loop meaning that 
        // the entire matrix of cells is processed every frame. 25 times a second.
    
      for( int x = 0; x < lat1.w; x++ ){
          for( int y = 0; y < lat1.h; y++ ){
      
        // for the cell at x,y get its current value as an integer
        int currentValue = (int)lat1.get(x,y);
        
        // pass the cell coordinates x,y to the instance, k, of our kernel class
        // along with the full environment. K will calculate the sum of the values
        // of x,y's neighbors and return it forced as an integer
        int sumNeighbors = (int) k.getSum( lat1, x, y );
        
        // use the majorityRule() function, that we create below, to calculate
        // the value of cell x,y on the next time step
        //int nextValue = majorityRule( sumNeighbors, currentValue );
        int nextValue = conway( sumNeighbors, currentValue );

        // store the new value of cell x,y in a temporary lattice that will
        // be used to update all the cells simultaneously at the end of the draw loop
        lat2.put( x, y, nextValue );
        
        // since our background is already black we only need to draw
        // the cells that have a value of '1.'
        if( currentValue == 1 )
        {
          fill(255); // values of 1 are assigned the color 255
          noStroke();
          rect(x, y, 1, 1);  // draw a rectangle for the current cell.
        }
  
      }//y
    }//x // end of nested for() loop
    
    // now that we've used the nested for() loop to caculated the next state 
    // for every cell in the lattice ... 
    // replace the lattice of current values with the lattice that has all of
    // these "next" values. 
    
    lat1.replaceWith(lat2);    

    // loop back up to the top...
    
}; // end of draw()

int conway( int sumNeighbors, int currentVal )
{
  int nextVal = currentVal;
  if ( sumNeighbors == 0 ){ nextVal = 0;}
  else if ( sumNeighbors == 1 ){ nextVal = 0;}
  else if ( sumNeighbors == 2 ){ nextVal = currentVal;}
  else if ( sumNeighbors == 3 ){ nextVal = 1;}
  else if ( sumNeighbors >= 4 ){ nextVal = 0;}

  return nextVal;
}


// OUR OWN FUNCTION TO CALCULATE THE MAJORITY RULE rule. 

int majorityRule( int sumN, int currentVal )
{
        // INPUTS 
        // . the sum of the neighbors in x,y's neighborhood
        // . x,y's current value.
  
        int nextVal = 0; // initialize next value to be 0.
        
        // if the current value is 0 and the sum is greater than Z
        // then the  next value is 1
        // otherwise if the current value is 1 and the sum is greater than or equal to Z
        // then the  next value is 1
        // if neither of these are true then the next value remains 0. 
        
        if( currentVal == 0 && sumN > z )
          { nextVal = 1; }

        else if( currentVal == 1 && sumN >= z )
          { nextVal = 1; }
          
    // OUPUT the next value. 
    return nextVal;
    
}; // end of majorityRule()