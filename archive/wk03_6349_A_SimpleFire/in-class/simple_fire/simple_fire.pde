///////////////////
// GLOBAL VARIABLES
Lattice lat1, lat2;
Kernel k;
int kernelSize = 1;

float vegDensity = 0.39;

//////////
// cell value
// 0 is bare ground
// 1 - mature veg, fuel
// 2 - burning veg, on fire
// 3 - bunt out cell, no fuel
// 4 - growing veg, not mature, not fuel

static int BARE = 0;
static int FUEL = 1;
static int BURNING = 2;
static int BURNT = 3;
static int GROWING = 4;

///////////
// an array[] of colors associate
// with each of the above land color states

color[] swatch;


//////////
// setup()

void setup()
{
  size(400, 400);
  frameRate(10);
  
  lat1 = new Lattice(400,400, BARE, FUEL, vegDensity );
  lat2 = new Lattice(400, 400);
    k = new Kernel();
    k.setNeighborhoodDistance( kernelSize ); 
    
  swatch = new color[5];
  
  swatch[BARE] = color (0,0,0);
  swatch[FUEL] = color (200,150,0);
  swatch[BURNING] = color (255,0,0);
  swatch[BURNT] = color (100,100,100);
  swatch[GROWING] = color(0,255,0);
  
}


/////////
// draw()
void draw()
{
  background (0);
  
  for( int x = 0; x < lat1.w; x++ ){
    for( int y = 0; y < lat1.h; y++ ){
      
      int currentState = (int) lat1.get(x,y);
      int nextState = updateBurnState( currentState );
      
      if( currentState == FUEL && k.hasNeighbor( lat1, x, y, BURNING) == true )
      {
        nextState = BURNING;
      }
      
      noStroke();
      fill( swatch[ currentState ] );
      rect( x, y, 1, 1);

      lat2.put( x,y, nextState );
    }
  }
  
 if( mousePressed)
  {
  lat2.put( mouseX, mouseY, BURNING);
  print("click");
  }   
  
    lat1.replaceWith( lat2 );
}

int updateBurnState( int currentValue )
{
  int nextValue = currentValue;
    if( currentValue == BURNING ){ nextValue = BURNT; }
  return nextValue;
}