public class NLCDswatch
{
      // a very simple class that holds the standard color
      // values for the National Land Cover Dataset (NLCD)
      // it is nothing more than an array of color variables
      // accessed by the Land Cover codes.
      
      
      color[] NLCD;
  
      public NLCDswatch()
      {
            NLCD = new color[100];
            
            NLCD[11] = color(255,255,255); //Open Water
            NLCD[13] = color(255,255,255); //Developed-Upland Deciduous Forest
            NLCD[14] = color(255,255,255); //Developed-Upland Evergreen Forest
            NLCD[15] = color(255,255,255); //Developed-Upland Mixed Forest
            NLCD[16] = color(255,255,255); //Developed-Upland Herbaceous
            NLCD[17] = color(255,255,255); //Developed-Upland Shrubland
            NLCD[22] = color(255,255,255); //Developed - Low Intensity
            NLCD[23] = color(255,255,255); //Developed - Medium Intensity
            NLCD[24] = color(255,255,255); //Developed - High Intensity
            NLCD[25] = color(255,255,255); //Developed-Roads
            NLCD[31] = color(255,255,255); //Barren
            NLCD[32] = color(255,255,255); //Quarries-Strip Mines-Gravel Pits
            NLCD[100] = color(255,255,255); //Sparse Vegetation Canopy
            NLCD[101] = color(255,255,255); //Tree Cover >= 10 and < 20%
            NLCD[102] = color(255,255,255); //Tree Cover >= 20 and < 30%
            NLCD[103] = color(255,255,255); //Tree Cover >= 30 and < 40%
            NLCD[104] = color(255,255,255); //Tree Cover >= 40 and < 50%
            NLCD[105] = color(255,255,255); //Tree Cover >= 50 and < 60%
            NLCD[106] = color(255,255,255); //Tree Cover >= 60 and < 70%
            NLCD[107] = color(255,255,255); //Tree Cover >= 70 and < 80%
            NLCD[111] = color(255,255,255); //Shrub Cover >= 10 and < 20%
            NLCD[112] = color(255,255,255); //Shrub Cover >= 20 and < 30%
            NLCD[113] = color(255,255,255); //Shrub Cover >= 30 and < 40%
            NLCD[114] = color(255,255,255); //Shrub Cover >= 40 and < 50%
            NLCD[115] = color(255,255,255); //Shrub Cover >= 50 and < 60%
            NLCD[116] = color(255,255,255); //Shrub Cover >= 60 and < 70%
            NLCD[117] = color(255,255,255); //Shrub Cover >= 70 and < 80%
            NLCD[121] = color(255,255,255); //Herb Cover >= 10 and < 20%
            NLCD[122] = color(255,255,255); //Herb Cover >= 20 and < 30%
            NLCD[123] = color(255,255,255); //Herb Cover >= 30 and < 40%
            NLCD[124] = color(255,255,255); //Herb Cover >= 40 and < 50%
            NLCD[125] = color(255,255,255); //Herb Cover >= 50 and < 60%
            NLCD[126] = color(255,255,255); //Herb Cover >= 60 and < 70%
            NLCD[127] = color(255,255,255); //Herb Cover >= 70 and < 80%
            NLCD[128] = color(255,255,255); //Herb Cover >= 80 and < 90%   

      };

      color getColor( int NLCDcode )
      {  
            color defaultColor = color(0,0,0); // enter an invalid code number and
                                               // get K back.
            
            return (NLCDcode >= 11 && NLCDcode <= 95)? NLCD[ NLCDcode ] : defaultColor;
      }
  
      color[] getSwatch()
      {
          return NLCD;
      }
  
}