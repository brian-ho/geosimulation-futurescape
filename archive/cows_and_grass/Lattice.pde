import java.util.Map;


public class Lattice
{
    int w = 0;
    int h = 0;
    float[][] lattice;
    boolean[][] cellLock; //toggle whether a cell can change 
    PImage img;
    boolean imgLoaded = false;

////////////////////////////////////////////////////////////////
    public Lattice( int _w, int _h, float val )
    {
        w = PApplet.max(0, _w);
        h = PApplet.max(0, _h); 
        lattice = new float[w][h];
       cellLock = new boolean[w][h];

        
        for( int i = 0; i < lattice.length; i++){
        for( int j = 0; j < lattice[0].length; j++){
       
             lattice[i][j] = val;  
            cellLock[i][j] = false;
        }} 
    };

////////////////////////////////////////////////////////////////
    public Lattice(int _w, int _h)
    {
        w = PApplet.max(0, _w);
        h = PApplet.max(0, _h); 
        lattice = new float[w][h];
       cellLock = new boolean[w][h];

        
        for( int i = 0; i < lattice.length; i++){
        for( int j = 0; j < lattice[0].length; j++){
       
            lattice[i][j] = 0;  
           cellLock[i][j] = false;
        }}
    }

////////////////////////////////////////////////////////////////    
    public Lattice(int _w, int _h, float _min, float _max )
    {
        w = PApplet.max(0, _w);
        h = PApplet.max(0, _h); 
         lattice = new float[w][h];
        cellLock = new boolean[w][h];
        
          for( int i = 0; i < lattice.length; i++){
          for( int j = 0; j < lattice[0].length; j++){
         
              lattice[i][j] = random(_min,_max);
             cellLock[i][j] = false;
          }}    
    };
    
////////////////////////////////////////////////////////////////
    public Lattice(int _w, int _h, float _min, float _max, String _flag )
    {
        String Round = "ROUND";
        w = PApplet.max(0, _w);
        h = PApplet.max(0, _h); 
         lattice = new float[w][h];
        cellLock = new boolean[w][h];
        
          for( int i = 0; i < lattice.length; i++){
          for( int j = 0; j < lattice[0].length; j++){
         
            if( Round.equals(_flag.toUpperCase()) )
            {
                   lattice[i][j] = round(random(_min,_max));
            }
            else{ lattice[i][j] = random(_min,_max); }
             
            cellLock[i][j] = false;
          }}    
    };
    
 ////////////////////////////////////////////////////////////////   
    public Lattice(int _w, int _h, int _min, int _max )
    {  // random binary lattice with either min OR max value

        w = PApplet.max(0, _w);
        h = PApplet.max(0, _h); 
         lattice = new float[w][h];
        cellLock = new boolean[w][h];
        
          for( int i = 0; i < lattice.length; i++){
          for( int j = 0; j < lattice[0].length; j++){
         
              lattice[i][j] = random(0,1.0)<=0.5 ? _min : _max;
             cellLock[i][j] = false;
          }}    
    };
    
////////////////////////////////////////////////////////////////
    public Lattice(int _w, int _h, int _min, int _max, float prob )
    {  // random binary lattice with either min OR max value

        w = PApplet.max(0, _w);
        h = PApplet.max(0, _h); 
         lattice = new float[w][h];
        cellLock = new boolean[w][h];
        
          for( int i = 0; i < lattice.length; i++){
          for( int j = 0; j < lattice[0].length; j++){
         
              lattice[i][j] = random(0,1.0)<=prob ? _max : _min;
             cellLock[i][j] = false;
          }}    
    };
    
////////////////////////////////////////////////////////////////
    void replaceWith( Lattice l )
    {    
       w = l.w;
       h = l.h;
       lattice = new float[w][h];
      
        for( int xx = 0; xx < w; xx++){
          for( int yy = 0; yy < h; yy++){
            
                lattice[xx][yy] = l.lattice[xx][yy];  
          }}
    }

////////////////////////////////////////////////////////////////
    void replaceWith( float[][] mat )
    {
        w = mat.length;
        h = mat[0].length;
    
        lattice = new float[w][h];
      
        for( int xx = 0; xx < w; xx++){
          for( int yy = 0; yy < h; yy++){
            
                lattice[xx][yy] = mat[xx][yy];  
          }}
    };
    
    
////////////////////////////////////////////////////////////////
    void put( int x, int y, float val )
    {    
        if( !cellLock[ testX(x) ][ testY(y) ] )
             lattice[ testX(x) ][ testY(y) ] = val;
    };
    
////////////////////////////////////////////////////////////////
    void put( PVector pv )
    {
        if( !cellLock[testX( (int)pv.x )][testY( (int)pv.y )] )
                put( testX( (int)pv.x ), testY( (int)pv.y ), pv.z );
    };

////////////////////////////////////////////////////////////////
    
    void increment(int x, int y)
    {
        lattice[testX(x)][ testY(y) ] = lattice[testX(x)][ testY(y) ] + 1;
    }

////////////////////////////////////////////////////////////////
    
    void increment(PVector loc )
    {
        increment( (int)loc.x, (int)loc.y );
    }    

 ////////////////////////////////////////////////////////////////   
    float get( int x, int y )
    {
        return lattice[testX(x)][ testY(y)];
    };
    
////////////////////////////////////////////////////////////////    
    float getNorm( int x, int y)
    {
        float minval = this.min();
        float maxval = this.max(); 
        if( minval != maxval )
        {  return map( lattice[testX(x)][ testY(y)], minval, maxval, 0, 1.0); }
        else return 0;
    };

 ////////////////////////////////////////////////////////////////   
    PVector getcell( int x, int y)
    {
        return new PVector(testX(x), testY(y), get(testX(x), testY(y)) );
    };
    
////////////////////////////////////////////////////////////////    
    float[][] getlattice()
    {
        return lattice;
    };

////////////////////////////////////////////////////////////////
    void lock( int x, int y)
    {
        cellLock[testX(x)][testY(y)] = true;
    }
    
////////////////////////////////////////////////////////////////
    void unlock( int x, int y)
    {
        cellLock[testX(x)][testY(y)] = false;
    }
    
////////////////////////////////////////////////////////////////    
    void lockAll()
    {
        for( int i = 0; i < cellLock.length; i++){
        for( int j = 0; j < cellLock[0].length; j++){
    
              cellLock[i][j] = true;         
        }}
    };
    
////////////////////////////////////////////////////////////////
    void unlockAll()
    {
        for( int i = 0; i < cellLock.length; i++){
        for( int j = 0; j < cellLock[0].length; j++){
    
              cellLock[i][j] = false;         
        }}
    };
    
////////////////////////////////////////////////////////////////    
    float max()
    {
        float maxval = -9999;
        for( int i = 0; i < lattice.length; i++){
        for( int j = 0; j < lattice[0].length; j++){
    
              maxval = PApplet.max(maxval, lattice[i][j] );          
        }}
        
        return maxval;
    };
    
////////////////////////////////////////////////////////////////    
    float min()
    {
        float minVal = 9999;
        for( int i = 0; i < lattice.length; i++){
        for( int j = 0; j < lattice[0].length; j++){
    
              minVal = PApplet.min(minVal, lattice[i][j] );
          
        }}      
        return minVal;
    };
    
////////////////////////////////////////////////////////////////    
    float average()
    {    
        int   cnt = 0;
        float sum = 0;
        
        for( int i = 0; i < lattice.length; i++){
        for( int j = 0; j < lattice[0].length; j++){
    
              sum += lattice[i][j];
              cnt++;
        }}      
        
        return sum / cnt;
    };
    
////////////////////////////////////////////////////////////////
    PVector[] histogram()
    {
        HashMap<Float,Integer> histo = new HashMap<Float,Integer>();
        int numEntries = 0;
        PVector[] histReturn;
        
        for( int i = 0; i < lattice.length; i++){
        for( int j = 0; j < lattice[0].length; j++){
    
             float val = lattice[i][j];     
             if( histo.containsKey(val) ){ histo.put(val,histo.get(val)+1 ); }
             else{  histo.put(val,1); numEntries++; }
        }}
        
        
        histReturn = new PVector[ numEntries ];
        int k = 0;
        
        for( Map.Entry kk : histo.entrySet() )
        {
            histReturn[k] = new PVector( (float)kk.getKey(), (int)kk.getValue()) ;
            k++;
        }
        
        return histReturn;
    };
////////////////////////////////////////////////////////////////    
    PImage updatePImage()
    {
        img = new PImage(w,h);
        
        int minny = floor( this.min() );
        int maxxy = floor( this.max() );
        
        for( int i = 0; i < lattice.length; i++){
        for( int j = 0; j < lattice[0].length; j++){
    
              int val = round( map( lattice[i][j], minny, maxxy, 0, 255) );
              img.set(i,j, val);
        }}
        
        imgLoaded = true;
        
        return img;
    
    }
    
////////////////////////////////////////////////////////////////    
    PImage getPImage()
    {
        return imgLoaded ? img : updatePImage();
    };
    
 ////////////////////////////////////////////////////////////////   
    int testX( int x )
    {
        if( x < 0 )
        {
           x = constrain(x,0, lattice.length-1); 
           println( "WARNING: X index out of bounds, negative number ");
        }
        
        else if(  x >= lattice.length)
        {
            x = constrain(x,0, lattice.length-1);
            println( "WARNING: X index out of bounds, too big! ");
        }
        
        return x;
    };
    
////////////////////////////////////////////////////////////////    
    int testY( int y )
    {
        if( y < 0 )
        {
            y = constrain(y,0, lattice[0].length-1);
            println( "WARNING: Y index out of bounds, negative number!");
        }
        
        else if( y >= lattice[0].length)
        {
            y = constrain(y,0, lattice[0].length-1);
            println( "WARNING: Y index out of bounds, too big!");
        }
        
        return y;
    };
       
};