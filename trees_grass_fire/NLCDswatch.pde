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
   
           NLCD[11] = color( 72,109,162); // open water
           NLCD[12] = color(231,239,252); // ice
           NLCD[21] = color(255,205,206); // developed, open land
           NLCD[22] = color(220,152,129); // developed, low intensity
           NLCD[23] = color(241,  1,  0); // developed, medium intensity
           NLCD[24] = color(171,  1,  1); // developed, high intensity
           NLCD[31] = color(179,175,164); // barren land       
           NLCD[41] = color(108,169,102); // deciduous forest       
           NLCD[42] = color( 29,101, 51); // evergreen forest
           NLCD[43] = color(189,204,147); // mixed forest
           NLCD[51] = color(176,151, 61); // dwarf scrub 
           NLCD[52] = color(209,187,130); // shrub
           NLCD[71] = color(237,236,205); // grassland
           NLCD[72] = color(208,209,129); // sedge
           NLCD[73] = color(164,204, 81); // lichens
           NLCD[74] = color(130,186,157); // moss
           NLCD[81] = color(221,216, 62); // pasture
           NLCD[82] = color(174,114, 41); // cultivated crops
           NLCD[90] = color(187,215,237); // woody wetlands
           NLCD[95] = color(107,166,200); // emergent herbaceous wetlands    
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