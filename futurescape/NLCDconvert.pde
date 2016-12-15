public class NLCDconvert
{
      // a very simple class that holds the standard color
      // values for the National Land Cover Dataset (NLCD)
      // it is nothing more than an array of color variables
      // accessed by the Land Cover codes.
      
      
      int[] NLCD;
  
      public NLCDconvert()
      {
            NLCD = new int[129];
            // GRASS + TREE = 255, values are GRASS — makes life easier;
            NLCD[11] = -9999; //Open Water
            NLCD[13] = -9999; //Developed-Upland Deciduous Forest
            NLCD[14] = -9999; //Developed-Upland Evergreen Forest
            NLCD[15] = -9999; //Developed-Upland Mixed Forest
            NLCD[16] = -9999; //Developed-Upland Herbaceous
            NLCD[17] = -9999; //Developed-Upland Shrubland
            NLCD[22] = -9999; //Developed - Low Intensity
            NLCD[23] = -9999; //Developed - Medium Intensity
            NLCD[24] = -9999; //Developed - High Intensity
            NLCD[25] = -9999; //Developed-Roads
            NLCD[31] = -9999; //Barren
            NLCD[32] = -9999; //Quarries-Strip Mines-Gravel Pits
            NLCD[100] = -9999; //Sparse Vegetation Canopy
            NLCD[101] = 204; //Tree Cover >= 10 and < 20%
            NLCD[102] = 178; //Tree Cover >= 20 and < 30%
            NLCD[103] = 153; //Tree Cover >= 30 and < 40%
            NLCD[104] = 127; //Tree Cover >= 40 and < 50%
            NLCD[105] = 102; //Tree Cover >= 50 and < 60%
            NLCD[106] = 76; //Tree Cover >= 60 and < 70%
            NLCD[107] = 51; //Tree Cover >= 70 and < 80%
            NLCD[111] = 26; //Shrub Cover >= 10 and < 20%
            NLCD[112] = 76; //Shrub Cover >= 20 and < 30%
            NLCD[113] = 102; //Shrub Cover >= 30 and < 40%
            NLCD[114] = 127; //Shrub Cover >= 40 and < 50%
            NLCD[115] = 153; //Shrub Cover >= 50 and < 60%
            NLCD[116] = 178; //Shrub Cover >= 60 and < 70%
            NLCD[117] = 204; //Shrub Cover >= 70 and < 80%
            NLCD[121] = 51; //Herb Cover >= 10 and < 20%
            NLCD[122] = 76; //Herb Cover >= 20 and < 30%
            NLCD[123] = 102; //Herb Cover >= 30 and < 40%
            NLCD[124] = 127; //Herb Cover >= 40 and < 50%
            NLCD[125] = 153; //Herb Cover >= 50 and < 60%
            NLCD[126] = 178; //Herb Cover >= 60 and < 70%
            NLCD[127] = 204; //Herb Cover >= 70 and < 80%
            NLCD[128] = 229; //Herb Cover >= 80 and < 90%

      };

      int getConvert( int NLCDcode )
      {  
            int defaultConvert = 0; // enter an invalid code number and
                                               // get K back.
            
            return (NLCDcode >= 11 && NLCDcode <= 128)? NLCD[ NLCDcode ] : defaultConvert;
      }
  
      int[] getConverts()
      {
          return NLCD;
      }
  
}