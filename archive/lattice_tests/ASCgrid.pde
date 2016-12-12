public class ASCgrid
{
    private int ncols;
    private int nrows;
    private double xllcorner;
    private double yllcorner;
    private double cellsize;
    private long NODATA_value;
    private String NODATA;
    private String delimmer = " ";
    private String[] projectionFile;
    private boolean prjFileExists = true;
    
    
    protected float[][] cells;
    
    private int HEAD_SIZE = 6;
    
    public  int h, w;
    public  float minValue, maxValue;
    public  boolean wrap = true;
    public  PImage img;
    public  boolean imageLoaded = false;
    
    ASCgrid()
    {
        // creates a blank ASCgrid   
        println( "Blank ASC Grid " + this.w + " x " + this.h + " with no parameters");
    }
    
    ASCgrid( String fileName)
    {
        String[] ascFile = loadStrings(fileName);    
        
        parseProjection(fileName);
        
        parseHeader( ascFile );
        parseBody( ascFile );
        println( "ASC Grid " + this.w + " x " + this.h + ". Min: " + minValue + " Max: " + maxValue );
    }
 
     ASCgrid( ASCgrid ag )
     {
         copyGridStructure( ag );
     }
 
    ////////////////////////////////////////////////////////////////////////////
    public void copyGridStructure( String fileName )
    {
       String[] ascFile = loadStrings(fileName);    
        parseHeader( ascFile );
        parseProjection( fileName );
         cells     = new float[ w ][ h ];
        println( "Blank ASC Grid " + this.w + " x " + this.h);
    }
    
    public void copyGridStructure( ASCgrid ag )
    {
           ncols      = ag.ncols;
           nrows      = ag.nrows;
       xllcorner      = ag.xllcorner;
       yllcorner      = ag.yllcorner;
       cellsize       = ag.cellsize;
       NODATA_value   = ag.NODATA_value;
       NODATA         = ag.NODATA;
       h              = ag.h;
       w              = ag.w; 
       projectionFile = ag.projectionFile;
       prjFileExists  = ag.prjFileExists;

         cells        = new float[ w ][ h ];
        println( "Blank ASC Grid " + this.w + " x " + this.h + " y ");
    }
    
    
    //////////////////////////////////////////////////////////////////////////// 
    private void parseProjection( String fileName )
    {
      
        try
        {
           String[] filenameBits = split(fileName, "." );
           projectionFile        = loadStrings( filenameBits[0] + ".prj" );
        
        }
        catch ( Exception e)
        {
            ;
        }
        
        if( projectionFile == null )
        { 
            prjFileExists = false; 
            println( "WARNING: no *.prj file found. Will not be able to write a new ASC file with projection." );        
        }        
    };
    
    ////////////////////////////////////////////////////////////////////////////   
    private void parseHeader( String[] ascFile )
    {
        ncols          = Integer.parseInt( split(ascFile[0].replaceAll("\\s+", ","), ",")[1] );
        nrows          = Integer.parseInt( split(ascFile[1].replaceAll("\\s+", ","), ",")[1] );
        xllcorner      = Double.parseDouble( split(ascFile[2].replaceAll("\\s+", ","), ",")[1] );
        yllcorner      = Double.parseDouble( split(ascFile[3].replaceAll("\\s+", ","), ",")[1] );
        cellsize       = Double.parseDouble( split(ascFile[4].replaceAll("\\s+", ","), ",")[1] );
        NODATA_value   = Long.parseLong( split(ascFile[5].replaceAll("\\s+", ","), ",")[1] );
        NODATA         = split(ascFile[5].replaceAll("\\s+", ","), ",")[1];
        
        this.h = nrows;
        this.w = ncols;  
    }
    
    ////////////////////////////////////////////////////////////////////////////
    private void parseBody( String[] ascFile )
    {
        cells     = new float[ w ][ h ];    
        minValue  =  999999999;
        maxValue  = -999999999;
        
        
        for( int i = HEAD_SIZE; i < ascFile.length; i++ )
        {    
                  ascFile[i] = ascFile[i].trim(); // get rid of last white space
                  
              String[] rower = split( ascFile[i].replaceAll( NODATA, "0" ), delimmer);
              
              for( int j = 0; j < rower.length; j++)
              {
                  cells[ j ][ i-HEAD_SIZE ] = Float.parseFloat( rower[j] );
                  minValue = min( minValue,   Float.parseFloat( rower[j] ) );
                  maxValue = max( maxValue,   Float.parseFloat( rower[j] ) );           
              }
        }    
    };
    
 
    void minimum()
    {
        minValue  =  999999999;
          for( int x = 0; x < cells.length; x++ ){
            for( int y = 0; y < cells[0].length; y++){
              
                  minValue = min( minValue, cells[x][y] );
            }}
    };
    
    
    void maximum()
    {
        maxValue  = -999999999;
          for( int x = 0; x < cells.length; x++ ){
            for( int y = 0; y < cells[0].length; y++){
              
                  maxValue = max( maxValue, cells[x][y] );
            }}
    };
    
    public void fitToScreen()
    {
        fit( width, height );
    }
    
    public void fit( int wIn, int hIn )
    {
             if( w < wIn || h < hIn ){   scaleUpNearest(wIn, hIn); }
        else if( w > wIn || h > hIn ){ scaleDownNearest(wIn, hIn); }
        println("ASC Grid now sized: " + w + " x " + h );
    };
    
    private void scaleUpNearest( int wIn, int hIn )
    {
        println( "scaling up is not yet implemented."); 
    };
    
    private void scaleDownNearest( int wIn, int hIn )
    {
        int wScl = floor( w / wIn );
        int hScl = floor( h / hIn );
       
        //println( "wScl " + wScl );
        //println( "hScl " + hScl );
        
        int wRes = w - (wIn * wScl);
        int hRes = h - (hIn * wScl);
        
        //println( "wRes " + wRes );
        //println( "hRes " + hRes );
       
        float[][] temp = new float[ wIn ][ hIn ];
        
         for( int x = 0; x < wIn; x ++ ){
         for( int y = 0; y < hIn; y ++ ){
              
               temp[x][y] = cells[x * wScl][y * hScl];
         }}
          
         cells = new float[wIn][hIn];
          
         for( int x = 0; x < wIn; x ++ ){
         for( int y = 0; y < hIn; y ++ ){
              
               cells[x][y] = temp[x][y];
         }} 
         
         //////////////////////////
         // update stats
         //////////////////////////
         w = cells.length;
         h = cells[0].length;
         nrows = h;
         ncols = w;
         minimum();
         maximum();
         yllcorner = yllcorner + (hRes * cellsize);
         cellsize  *= hScl;
    };
    
    
    
    public void put( int _x, int _y, float val )
    {
        if(wrap)
        {
            _x = wrapX(_x);
            _y = wrapY(_y);
        }
        
        cells[_x][_y] = val;
    }
    
    public void put( float[][] vals )
    {
        int xDim = min(    vals.length, w );
        int yDim = min( vals[0].length, h );
    
        for( int x = 0; x < xDim; x++ ){
          for( int y = 0; y < yDim; y++ ){
            
                cells[x][y] = vals[x][y];
          }}
    };
    
    
    public float get( int _x, int _y )
    {
        if(wrap)
        {
            _x = wrapX(_x);
            _y = wrapY(_y);
        }
        
        return cells[_x][_y];
    }
   
   
    public float[][] get()
    {
        return cells;
    }
   
    public PImage updateImage()
    {
         img = new PImage(w, h);
    
        for( int i = 0; i < this.w; i++ ){
          for( int j = 0; j < this.h; j++){
            
                int px = floor( map( this.get(i,j), minValue, maxValue, 0, 255) );
                int pxc = color(px,px,px);
                img.set(i,j,pxc);          
          }}
        
        imageLoaded = true;  
        return img;   
    };
       
    public PImage updateImage( color[] swatch )
    {
         img = new PImage(w, h);
    
        for( int i = 0; i < this.w; i++ ){
          for( int j = 0; j < this.h; j++){
            
                int px = (int)this.get(i,j);                
                img.set(i,j,swatch[px]);          
          }}
        
        imageLoaded = true;  
        return img;   
    };
    
    public PImage updateImage( color[] swatch, String _stretched )
    {
         img = new PImage(w, h);
         boolean stretched = false;
         
         if( _stretched.toUpperCase().equals( "STRETCHED") ) stretched = true;
         
    
        for( int i = 0; i < this.w; i++ ){
          for( int j = 0; j < this.h; j++){
            
                int px = (int)this.get(i,j);
                if( stretched ) // use this for a color map that has values 0-255
                      px = floor( map( this.get(i,j), minValue, maxValue, 0, 255) );
                
                img.set(i,j,swatch[px]);          
          }}
        
        imageLoaded = true;  
        return img;   
    };
    
    
    public PImage getImage()
    {
        return imageLoaded ? img : updateImage();
    }
    
    public PVector[] getPVectors()
    {
        PVector[] values = new PVector[ w * h ];
        
        for( int x = 0; x < w; x++ ){
          for( int y = 0; y < h; y++ ){
            
                values[ y*w+x ] = new PVector( x, y, cells[x][y] );
          }}
        
        return values;
    };
    
    public float[][] getNeighborhood( int _x, int _y)
    {
        if(wrap)
        {
            _x = wrapX(_x);
            _y = wrapY(_y);
        } 
    
        float[][] kernel = new float[3][3];
        
        for( int i = -1; i <= 1; i++ ){
        for( int j = -1; j <= 1; j++ ){
        
              kernel[i+1][j+1] = this.get( wrapX(_x+i), wrapY(_y+j) );
          
        }}
        
        return kernel;
    }
    
    
    public void write( String fileName )
    {
        String[] rowStream = new String[ HEAD_SIZE + nrows ] ;
        
        rowStream[ 0 ] = "ncols" + delimmer + ncols;
        rowStream[ 1 ] = "nrows" + delimmer + nrows;
        rowStream[ 2 ] = "xllcorner" + delimmer + xllcorner;
        rowStream[ 3 ] = "yllcorner" + delimmer + yllcorner;
        rowStream[ 4 ] = "cellsize" + delimmer + cellsize;
        rowStream[ 5 ] = "NODATA_value" + delimmer + NODATA;
        
        for( int n = HEAD_SIZE; n < rowStream.length; n++)
        {
            String rowEntries = "";
            
            for( int m = 0; m < this.w; m++)
            {
            
                rowEntries += cells[m][n-HEAD_SIZE] + delimmer;        
            }
            rowEntries += delimmer;
            rowStream[n] = rowEntries;
        }
        
        saveStrings( fileName, rowStream );   
        println( "ASC Grid " + this.w + " x " + this.h + ". Min: " + minValue + " Max: " + maxValue + " written to " + fileName ); 
      
        // if there is a *.prj file associated with the the asc
        // copy it into a new prj 
        if( prjFileExists)
        {
          String prjFileName = split(fileName, ".")[0] + ".prj";
          saveStrings( prjFileName, projectionFile );
        }
        else{ println( "ASC file contains no *.prj file." ); }
    };
    
    
    public int wrapX( int _x)
    {
          int xx = _x;
          
           if( xx < 0 ) xx = w-xx;            
            xx = xx % this.w;
        
            return xx;
    }

    public int wrapY( int _y)
    {
          int yy = _y;
          
           if( yy < 0 ) yy = h-yy;            
            yy = yy % this.h;
        
            return yy;
    }
    
    
    /////////////////////////////////////////////////////
    
    
    
    
}// class