public class NLCDhatch
{
      // a very simple class that holds the standard color
      // values for the National Land Cover Dataset (NLCD)
      // it is nothing more than an array of color variables
      // accessed by the Land Cover codes.
      
      
      color[][] NLCD;
  
      public NLCDhatch()
      {
            //int max = ceil(scale*scale);
            NLCD = new color[129][];
            
            NLCD[11] = new color[] {0, 255, 0, 255}; //Open Water
            NLCD[13] = new color[] {0,255,0,255}; //Developed-Upland Deciduous Forest
            NLCD[14] = new color[] {0,255,0,255}; //Developed-Upland Evergreen Forest
            NLCD[15] = new color[] {0,255,0,255}; //Developed-Upland Mixed Forest
            NLCD[16] = new color[] {0,255,0,255}; //Developed-Upland Herbaceous
            NLCD[17] = new color[] {0,255,0,255}; //Developed-Upland Shrubland
            NLCD[22] = new color[] {0,255,0,255}; //Developed - Low Intensity
            NLCD[23] = new color[] {0,255,0,255}; //Developed - Medium Intensity
            NLCD[24] = new color[] {255,255,255,255}; //Developed - High Intensity
            NLCD[25] = new color[] {255,255,255,255}; //Developed-Roads
            NLCD[31] = new color[] {0,255,0,255}; //Barren
            NLCD[32] = new color[] {0,255,0,255}; //Quarries-Strip Mines-Gravel Pits
            NLCD[100] = new color[] {0,255,0,255}; //Sparse Vegetation Canopy
            NLCD[101] = new color[] {0,255,0,255}; //Tree Cover >= 10 and < 20%
            NLCD[102] = new color[] {255,0,255,0,255}; //Tree Cover >= 20 and < 30%
            NLCD[103] = new color[] {255,0,255,0,255}; //Tree Cover >= 30 and < 40%
            NLCD[104] = new color[] {255,0,255,0,255}; //Tree Cover >= 40 and < 50%
            NLCD[105] = new color[] {255,0,255,0,255}; //Tree Cover >= 50 and < 60%
            NLCD[106] = new color[] {255,0,255,0,255}; //Tree Cover >= 60 and < 70%
            NLCD[107] = new color[] {255,0,255,0,255}; //Tree Cover >= 70 and < 80%
            NLCD[111] = new color[] {0,0,0,0}; //Shrub Cover >= 10 and < 20%
            NLCD[112] = new color[] {0,0,0,0}; //Shrub Cover >= 20 and < 30%
            NLCD[113] = new color[] {0,255,0,255}; //Shrub Cover >= 30 and < 40%
            NLCD[114] = new color[] {0,255,0,255}; //Shrub Cover >= 40 and < 50%
            NLCD[115] = new color[] {0,255,0,255}; //Shrub Cover >= 50 and < 60%
            NLCD[116] = new color[] {0,255,0,255}; //Shrub Cover >= 60 and < 70%
            NLCD[117] = new color[] {0,0,0,0}; //Shrub Cover >= 70 and < 80%
            NLCD[121] = new color[] {0,255,0,255}; //Herb Cover >= 10 and < 20%
            NLCD[122] = new color[] {0,255,0,0}; //Herb Cover >= 20 and < 30%
            NLCD[123] = new color[] {0,255,0,0}; //Herb Cover >= 30 and < 40%
            NLCD[124] = new color[] {0,255,0,0}; //Herb Cover >= 40 and < 50%
            NLCD[125] = new color[] {0,255,0,0}; //Herb Cover >= 50 and < 60%
            NLCD[126] = new color[] {0,255,0,0}; //Herb Cover >= 60 and < 70%
            NLCD[127] = new color[] {0,255,0,0}; //Herb Cover >= 70 and < 80%
            NLCD[128] = new color[] {0,255,0,0}; //Herb Cover >= 80 and < 90%  
           
      };
/*
      color getColor( int NLCDcode )
      {  
            color defaultColor = color(0,0,0); // enter an invalid code number and
                                               // get K back.
            
            return (NLCDcode >= 11 && NLCDcode <= 95)? NLCD[ NLCDcode ] : defaultColor;
      }
      */
      color[][] getHatch()
      {
          return NLCD;
      }
  
}