public class NLCDhatch
{
      // a very simple class that holds hatch
      // values for the National Land Cover Dataset (NLCD)
      // it is nothing more than an array of color arrays
      // accessed by the Land Cover codes.
      
      
      color[][] NLCD;
  
      public NLCDhatch()
      {
            //int max = ceil(scale*scale);
            NLCD = new color[129][];
            color W = color(255,255,255,180);
            color G = color(150,150,150,180);
            color D = color(80,80,80,180);
            color B =color(0,0,0,180);
            color T =color(0,0,0,0);
            color Gr = color(154, 205, 50,180);
            color Tr = color(34, 139, 34,180);
            color Hr = color(107,142,35,180);
            color R = color(255,0,0);
                       
            
            NLCD[11] = new color[] {B, B, B, B}; //Open Water
            NLCD[13] = new color[] {Tr,G,Tr,G}; //Developed-Upland Deciduous Forest
            NLCD[14] = new color[] {Hr,G,Tr,G}; //Developed-Upland Evergreen Forest
            NLCD[15] = new color[] {Hr,G,Tr,G}; //Developed-Upland Mixed Forest
            NLCD[16] = new color[] {Hr,D,Hr,G}; //Developed-Upland Herbaceous
            NLCD[17] = new color[] {Hr,G,Hr,D}; //Developed-Upland Shrubland
            NLCD[22] = new color[] {W,G,G,G}; //Developed - Low Intensity
            NLCD[23] = new color[] {G,D,D,D}; //Developed - Medium Intensity
            NLCD[24] = new color[] {D,B,B,B}; //Developed - High Intensity
            NLCD[25] = new color[] {B,B,B,B}; //Developed-Roads
            NLCD[31] = new color[] {G,W,W,W}; //Barren
            NLCD[32] = new color[] {B,W,W,W}; //Quarries-Strip Mines-Gravel Pits
            NLCD[100] = new color[] {G,W,W,W}; //Sparse Vegetation Canopy
            NLCD[101] = new color[] {Tr,T,T,T}; //Tree Cover >= 10 and < 20%
            NLCD[102] = new color[] {Tr,T,T,T}; //Tree Cover >= 20 and < 30%
            NLCD[103] = new color[] {Tr,T,T,T}; //Tree Cover >= 30 and < 40%
            NLCD[104] = new color[] {Tr,T,Tr,T}; //Tree Cover >= 40 and < 50%
            NLCD[105] = new color[] {Tr,T,Tr,T}; //Tree Cover >= 50 and < 60%
            NLCD[106] = new color[] {Tr, T, Tr, T}; //Tree Cover >= 60 and < 70%
            NLCD[107] = new color[] {Tr, T, Tr, T}; //Tree Cover >= 70 and < 80%
            NLCD[111] = new color[] {T,T,Hr,T}; //Shrub Cover >= 10 and < 20%
            NLCD[112] = new color[] {T,T,Hr,T}; //Shrub Cover >= 20 and < 30%
            NLCD[113] = new color[] {T,T,Hr,T}; //Shrub Cover >= 30 and < 40%
            NLCD[114] = new color[] {T,T,Hr,T}; //Shrub Cover >= 40 and < 50%
            NLCD[115] = new color[] {Hr,T,Hr,T}; //Shrub Cover >= 50 and < 60%
            NLCD[116] = new color[] {Hr,T,Hr,T}; //Shrub Cover >= 60 and < 70%
            NLCD[117] = new color[] {Hr,T,Hr,T}; //Shrub Cover >= 70 and < 80%
            NLCD[121] = new color[] {Gr,T,T,T}; //Herb Cover >= 10 and < 20%
            NLCD[122] = new color[] {Gr,T,T,T}; //Herb Cover >= 20 and < 30%
            NLCD[123] = new color[] {Gr,T,T,T}; //Herb Cover >= 30 and < 40%
            NLCD[124] = new color[] {Gr,T,T,T}; //Herb Cover >= 40 and < 50%
            NLCD[125] = new color[] {Gr,T,Gr,T}; //Herb Cover >= 50 and < 60%
            NLCD[126] = new color[] {Gr,T,Gr,T}; //Herb Cover >= 60 and < 70%
            NLCD[127] = new color[] {Gr,T,Gr,T}; //Herb Cover >= 70 and < 80%
            NLCD[128] = new color[] {Gr,T,Gr,T}; //Herb Cover >= 80 and < 90% 
           
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