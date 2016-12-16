import java.util.Map;

public class Kernel
{
    private  int ringSize     = 1;
    public   boolean torus    = false;
    public   int kernelType   = 1;  // 1 - Moore, 2 - von Neumann
  
    private int hoodSize     = 8; // size of neighborhood (moore = 8, Neumann = 4)
    private float NaN        = -9999;
 
    Kernel()
    {
        kernelType = 1; // default to Moore 
        if( kernelType == 1 ) hoodSize = 8;
        if( kernelType == 2 ) hoodSize = 4;
    }
    
    Kernel( int hoodtype )
    {
        if( hoodtype != 1 && hoodtype != 2 )
        {
            println( "ERROR: INVALID NEIGHBORHOOD. SETTING AS MOORE BY DEFAULT" );
            hoodtype = 1;
        }
        
        kernelType = hoodtype;
        if( kernelType == 1 ) hoodSize = 8;
        if( kernelType == 2 ) hoodSize = 4;
    }    
    
////////////////////////////////////////////////////////////////
    void setNeighborhoodDistance( int num )
    {
        num = max(1,num);
        ringSize = num;
    };
    
////////////////////////////////////////////////////////////////
   
    void isTorus()
    {
        torus = true;
    };
    
////////////////////////////////////////////////////////////////
    void isNotTorus()
    {
        torus = false;
    };
 
////////////////////////////////////////////////////////////////
    float getSum(float[][] matrix, int x, int y)
    {
        float[][] nHood = get(matrix, x, y);
        float summation = 0;
        
        for( int i = 0; i < nHood.length; i++ ){
        for( int j = 0; j < nHood[i].length; j++){
          
            if( nHood[i][j] != NaN)
            { summation += nHood[i][j]; }
        }}
        
        return summation;
    };
    
////////////////////////////////////////////////////////////////
    float getMean(float[][] matrix, int x, int y)
    {
        float[][] nHood = get(matrix, x, y);
        int     div = 0;
        float summation = 0;
        
        for( int i = 0; i < nHood.length; i++ ){
        for( int j = 0; j < nHood[i].length; j++){
          
            if( nHood[i][j] != NaN ){
              summation += nHood[i][j];
              div++;
            }
        }}
        
        return (summation / div );
    };
    
    ////////////////////////////////////////////////////////////////
    float getMin(float[][] matrix, int x, int y)
    {
        float[][] nHood = get(matrix, x, y);
        float minVal = -NaN;
            
        for( int i = 0; i < nHood.length; i++ ){
        for( int j = 0; j < nHood[i].length; j++){
            
            if( minVal != NaN )
                minVal = min( minVal, nHood[i][j]);
        }}
        
        return minVal;
    };
    
////////////////////////////////////////////////////////////////
    float getMax(float[][] matrix, int x, int y)
    {
        float[][] nHood = get(matrix, x, y);
    
        float maxVal = NaN;
        
        for( int i = 0; i < nHood.length; i++ ){
        for( int j = 0; j < nHood[i].length; j++){
            
            maxVal = max( maxVal, nHood[i][j]);
        }}
        
        return maxVal;
    };
   
////////////////////////////////////////////////////////////////
    float getRand(float[][] matrix, int x, int y)
    {
        ArrayList<Float> valList = new ArrayList<Float>();
        float[][] nHood = get(matrix, x, y);
        
        for( int i = 0; i < nHood.length; i++ ){
        for( int j = 0; j < nHood[i].length; j++){
            
           if( nHood[i][j] != NaN )
                valList.add(nHood[i][j]);
        }}
        
        return valList.get( floor( random(valList.size()) )    );
     }
     
////////////////////////////////////////////////////////////////
    float getMajority(float[][] matrix, int x, int y)
    {
        HashMap<Float,Integer> histo = new HashMap<Float,Integer>();
        float[][] nHood = get(matrix, x, y);
      
        for( int i = 0; i < nHood.length; i++ ){
        for( int j = 0; j < nHood[i].length; j++){
           
           float nVal = nHood[i][j];
           if( nVal != NaN)
           {
             if( histo.containsKey(nVal) ){ histo.put(nVal,histo.get(nVal)+1 ); }
             else{  histo.put(nVal,1); }
           }
           
        }}
        
              
        float valMaj=-1;
        int maxCount = 0;
        for( Map.Entry kk : histo.entrySet() )
        {
            int cnt = (int)kk.getValue();
            if( cnt > maxCount )
            {  
                maxCount = cnt;
                valMaj   = (float)kk.getKey();
            }
        
        }
      return valMaj;

    }; 
    
//////////////////////////////////////////////////////////////// 
  float getWeightedSum( float[][] matrix, int x, int y, float[] weightArray )
  {
        int storeRingSize = ringSize;  // weight array length determins num rings,                 
        ringSize = weightArray.length; // so store the current ringSize state first.
        
        float[][] nHood = get(matrix, x, y);
        float weightedSum = 0;
        
        for( int i = 0; i < nHood.length; i++ ){
        for( int j = 0; j < nHood[i].length; j++){
          
            if( nHood[i][j] != NaN)
                weightedSum += (nHood[i][j]*weightArray[i]);
                
        }}
    
        ringSize = storeRingSize; // reinstate ring size
        return weightedSum;
  };
  
//////////////////////////////////////////////////////////////// 
boolean hasNeighbor( float[][] matrix, int x, int y, int val )
{
      boolean doIHave = false;
     float[][] nHood  = get(matrix, x, y);
      
     for( int i = 0; i < nHood.length; i++ ){
      for( int j = 0; j < nHood[i].length; j++){
          
            if( nHood[i][j] == val)
            {
                doIHave = true;
                break;
            }                
        }}
        
      return doIHave;
}
  
//////////////////////////////////////////////////////////////// 
    float[][] get( float[][] matrix, int x, int y)
    {
            float[][] kernel = new float[ringSize][hoodSize];
            for( int i = 1; i <= ringSize; i++)
            {    
               kernel[i-1] = getBand(matrix,i,x,y);  
            }
        
            return kernel;
    };

////////////////////////////////////////////////////////////////    

    float[] getBand( float[][] matrix, int band, int x, int y)
    {
        if( kernelType == 1 )
        {
            return getMooreBand( matrix, band, x, y);
        }
        else
        {
            return getNeumannBand( matrix, band, x, y);
        }
    }
    
////////////////////////////////////////////////////////////////    
    float[] getMooreBand( float[][] matrix, int band, int x, int y)
    {
        // this is a hacky way of doing this:
        // 11111111
        // 10000001
        // 10000001
        // 10000001
        // 10000001
        // 10000001
        // 10000001
        // 11111111
        // but it works.
        
                band      = max(band,1);
        int     latWidth  = matrix.length;
        int    latHeight  = matrix[0].length;
        int     bandSize  = hoodSize * band;
        float[] thisBand  = new float[ bandSize ];
        int     cellIncr  = 0;
               
        for( int j=-band; j<=band; j++ ){ // y
        for( int i=-band; i<=band; i++ ){ // x
            
            if( (j==-band) || (j==band) )
            {  
               int xIndx = (torus)? wrap(x+i, latWidth)  : x+i;
               int yIndx = (torus)? wrap(y+j*1, latHeight) : y+j*1;
           float cellVal = (torus)? matrix[xIndx][yIndx] : edge(matrix, xIndx, yIndx);

              thisBand[ cellIncr ] = cellVal; 
             cellIncr++;
            }
            else if( (i==-band ) || (i==band) )
            {
                int xIndx = (torus)? wrap(x+i, latWidth)  : x+i;
                int yIndx = (torus)? wrap(y+j*1, latHeight) : y+j*1;
            float cellVal = (torus)? matrix[xIndx][yIndx] : edge(matrix, xIndx, yIndx);

                thisBand[ cellIncr ] = cellVal;
             cellIncr++;
            }
            
        }}         
        return thisBand;
    };

////////////////////////////////////////////////////////////////    
    float[] getNeumannBand( float[][] matrix, int band, int x, int y)
    {
        // this is a hacky way of doing this:
        //
        // 00100
        // 0   0
        // 1   1
        // 0   0
        // 00100
        //
        // but does it works?
        
                band      = max(band,1);
        int     latWidth  = matrix.length;
        int    latHeight  = matrix[0].length;
        int     bandSize  = hoodSize * band;
        float[] thisBand  = new float[ bandSize ];
        int     cellIncr  = 0;
               
        for( int j=-band; j<=band; j++ ){ // y
        for( int i=-band; i<=band; i++ ){ // x
            
            if( (j==-band && i==x) || (j==band && i==x) )
            {  
               int xIndx = (torus)? wrap(x+i, latWidth)  : x+i;
               int yIndx = (torus)? wrap(y+j*1, latHeight) : y+j*1;
           float cellVal = (torus)? matrix[xIndx][yIndx] : edge(matrix, xIndx, yIndx);
           
              thisBand[ cellIncr ] = cellVal; 
             cellIncr++;
            }
            else if( (i==-band && j==y ) || (i==band && j==y) )
            {
                int xIndx = (torus)? wrap(x+i, latWidth)  : x+i;
                int yIndx = (torus)? wrap(y+j*1, latHeight) : y+j*1;
            float cellVal = (torus)? matrix[xIndx][yIndx] : edge(matrix, xIndx, yIndx);

                thisBand[ cellIncr ] = cellVal;
             cellIncr++;
            }
            
        }}         
        return thisBand;
    };
    
 PVector[] getPVarray( float[][] mat, int x, int y)
 {
       PVector[][] temp = get( mat, new PVector(x,y) );
       int sizeOfList   = temp.length * temp[0].length;
       PVector[] cellList = new PVector[ sizeOfList ];
       
       int indx = 0;
       for( int i = 0; i < temp.length; i++ ){
         for( int j = 0; j < temp[0].length; j++ ){
           
               cellList[ indx ] = temp[i][j];
               indx++;
         }}
       
       return cellList;
 }
    
////////////////////////////////////////////////////////////////    
    
              ////////////////////////////
             // PVECTOR INPUT METHODS  //
            ////////////////////////////

////////////////////////////////////////////////////////////////    
 
    float getSum( float[][] matrix, PVector loc)
    {
        return getSum( matrix, (int)loc.x, (int)loc.y );
    }; 

////////////////////////////////////////////////////////////////
    PVector getMin(float[][] matrix, PVector loc)
    {
        
        PVector[][] nHood = get(matrix, loc);
        float minVal      = -NaN;
        int minValx       =  (int) NaN;
        int minValy       =  (int) NaN;
        
            
        for( int i = 0; i < nHood.length; i++ ){
        for( int j = 0; j < nHood[i].length; j++){
            
            if( nHood[i][j].z < minVal && nHood[i][j].z != NaN )
            {
                minVal  = nHood[i][j].z;
                minValx = (int)nHood[i][j].x;
                minValy = (int)nHood[i][j].y;

            }
        }}
        
        // RETURNS VALUE(Z) AND LOCATION OF MIN CELL (X,Y)
        return new PVector( minValx, minValy, minVal );
    };   
    
////////////////////////////////////////////////////////////////
    PVector getMax(float[][] matrix, PVector loc )
    {
        PVector[][] nHood =   get(matrix, loc);
        float maxVal      =   NaN;
        int maxValx       =  (int) NaN;
        int maxValy       =  (int) NaN;
 
        for( int i = 0; i < nHood.length; i++ ){
        for( int j = 0; j < nHood[i].length; j++){
            
            if( nHood[i][j].z > maxVal && nHood[i][j].z != NaN )
            {
                maxVal  = nHood[i][j].z;
                maxValx = (int)nHood[i][j].x;
                maxValy = (int)nHood[i][j].y;

            }
        }}
 
        // RETURNS VALUE(Z) AND LOCATION OF MAX CELL (X,Y)
        return new PVector( maxValx, maxValy, maxVal );      
    };
    
////////////////////////////////////////////////////////////////
    float getMean(float[][] matrix, PVector loc )
    {
        return getMean(matrix, (int)loc.x, (int)loc.y );
    };

////////////////////////////////////////////////////////////////
    PVector getRand(float[][] matrix, PVector loc )
    {
      
        ArrayList<PVector> valList = new ArrayList<PVector>();
        PVector[][]          nHood = get(matrix, loc);
        
        for( int i = 0; i < nHood.length; i++ ){   // rings
        for( int j = 0; j < nHood[i].length; j++){ // entities in ring
                        
            valList.add(nHood[i][j]);
         }
        }
        
        return valList.get( floor( random(valList.size()) )    );
    };     
    
////////////////////////////////////////////////////////////////
    float getMajority(float[][] matrix, PVector loc )
    {
        return getMajority(matrix, (int)loc.x, (int)loc.y );
    }; 
      
////////////////////////////////////////////////////////////////
    float getWeightedSum(float[][] matrix, PVector loc, float[] weightArray )
    {
        return getWeightedSum(matrix, (int)loc.x, (int)loc.y, weightArray );
    };    
    
//////////////////////////////////////////////////////////////// 
    PVector[][] get( float[][] matrix, PVector loc )
    {
            PVector[][] kernel = new PVector[ringSize][hoodSize];
            for( int i = 1; i <= ringSize; i++)
            {    
               kernel[i-1] = getBand(matrix,i,loc);  
            }
        
            return kernel;
    };
    
//////////////////////////////////////////////////////////////// 
    PVector[][] get( Lattice lat, PVector loc )
    {
            PVector[][] kernel = new PVector[ringSize][hoodSize];
            for( int i = 1; i <= ringSize; i++)
            {    
               kernel[i-1] = getBand( lat.getlattice(),i,loc );  
            }
        
            return kernel;
    };
    
////////////////////////////////////////////////////////////////    
    PVector[] getBand( float[][] matrix, int band, PVector loc )
    {
        // this is a hacky way of doing this:
        // 11111111
        // 10000001
        // 10000001
        // 10000001
        // 10000001
        // 10000001
        // 10000001
        // 11111111
        // but it works.
        
                  band      = max(band,1);
        int       latWidth  = matrix.length;
        int      latHeight  = matrix[0].length;
        int       bandSize  = hoodSize * band;
        PVector[] thisBand  = new PVector[ bandSize ];
        int       cellIncr  = 0;
        int       x         = (int)loc.x;
        int       y         = (int)loc.y;
        
               
        for( int j=-band; j<=band; j++ ){
        for( int i=-band; i<=band; i++ ){
            
            if( (j==-band) || (j==band) )
            {  
               int xIndx     = (torus)? wrap(x+i, latWidth)  : x+i;
               int yIndx     = (torus)? wrap(y+j*1, latHeight) : y+j*1;
               float cellVal = (torus)? matrix[xIndx][yIndx] : edge(matrix, xIndx, yIndx);

               thisBand[ cellIncr ] = new PVector( xIndx, yIndx, cellVal ); 
               cellIncr++;
            }
            else if( (i==-band ) || (i==band) )
            {
                int xIndx     = (torus)? wrap(x+i,       latWidth) : x+i;
                int yIndx     = (torus)? wrap(y+j*1, latHeight) : y+j*1;
                float cellVal = (torus)? matrix[xIndx][yIndx] : edge(matrix, xIndx, yIndx);
                
                thisBand[ cellIncr ] = new PVector (xIndx, yIndx, cellVal); 
                cellIncr++;
            }
            
        }}
              
        return thisBand;
    };
    
 ////////////////////////////////////////////////////////////////    
    
     PVector[] getPVarray( float[][] mat, PVector loc )
     {
          return getPVarray( mat, (int) loc.x, (int) loc.y );
     }
     
 ////////////////////////////////////////////////////////////////    
    
              ////////////////////////////
             // LATTICE INPUT METHODS  //
            ////////////////////////////

////////////////////////////////////////////////////////////////    
    float getSum(Lattice lat, int x, int y)
    {
        return getSum(lat.getlattice(), x, y);
    }
    
////////////////////////////////////////////////////////////////    
    float getMean(Lattice lat, int x, int y)
    {
        return getMean(lat.getlattice(), x, y);
    }
    
////////////////////////////////////////////////////////////////    
    float getMin(Lattice lat, int x, int y)
    {
        return getMin(lat.getlattice(), x, y);
    } 

////////////////////////////////////////////////////////////////    
    float getMax(Lattice lat, int x, int y)
    {
        return getMax(lat.getlattice(), x, y);
    } 
    
////////////////////////////////////////////////////////////////    
    float getRand(Lattice lat, int x, int y)
    {
        return getRand(lat.getlattice(), x, y);
    } 
    

////////////////////////////////////////////////////////////////    
    float getMajority(Lattice lat, int x, int y)
    {
        return getMajority(lat.getlattice(), x, y);
    } 
 
////////////////////////////////////////////////////////////////    
    float getWeightedSum(Lattice lat, int x, int y, float[] weightArray)
    {
        return getWeightedSum(lat.getlattice(), x, y, weightArray);
    } 
    
//////////////////////////////////////////////////////////////// 
boolean hasNeighbor( Lattice lat, int x, int y, int val )
{
      return hasNeighbor( lat.getlattice(), x, y, val );
};

////////////////////////////////////////////////////////////////    
    float[][] get(Lattice lat, int x, int y)
    {
        return get(lat.getlattice(), x, y);
    } 

////////////////////////////////////////////////////////////////    
    PVector   getMin( Lattice lat, PVector loc )
    {
        return getMin( lat.getlattice(), loc );
    }

////////////////////////////////////////////////////////////////    
    PVector   getMax( Lattice lat, PVector loc )
    {
        return getMax( lat.getlattice(), loc );
    }
    
////////////////////////////////////////////////////////////////    
    PVector   getRand( Lattice lat, PVector loc )
    {
        return getRand( lat.getlattice(), loc );
    }
    
 ////////////////////////////////////////////////////////////////    
   PVector[] getPVarray( Lattice lat, PVector loc )
   {
          return getPVarray( lat.getlattice(), (int) loc.x, (int) loc.y );
   }
    
 ////////////////////////////////////////////////////////////////    
   PVector[] getPVarray( Lattice lat, int x, int y )
   {
          return getPVarray( lat.getlattice(), x, y );
   }
   
////////////////////////////////////////////////////////////////
        int wrap( int index, int iSize)
        {
            if( index < 0 )           index = iSize + index; //N.B. index is negative here
            else if( index >= iSize ) index = index - iSize;
            
            return index;
        };
        
////////////////////////////////////////////////////////////////   
        float edge( float[][] matrix, int x, int y)
        {
            int       latWidth  = matrix.length;
            int      latHeight  = matrix[0].length;
            
            float val = ((x>=0 && x<latWidth) && (y>=0 && y<latHeight))? matrix[x][y] : NaN;
            return val;
        }
    

};//class hood