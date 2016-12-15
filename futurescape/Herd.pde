// adapted from The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// herd class
// Does very little, simply manages the ArrayList of all the herd

class Herd {
  ArrayList< Cow > herd; // An ArrayList for all the boids

  Herd() {
    herd = new ArrayList< Cow >(); // Initialize the ArrayList
  }

  void run() {
    // reorder the herd on each time step so they are updated
    // in a random order
    Collections.shuffle(herd);
    int cTemp = 0;
    // for every cow in herd: assign to temporary
    // instance "c". check ifc  is alive, if so, update it and draw it
    // then on to the next one
    for (Cow c : herd ) 
    {
      if( c.alive) 
      {
        cTemp += c.mass();
        c.update(scape, herd);
        c.drawMyself();
      }
    }
    cMass = cTemp;
  }

  void addCow(Cow c) {
    herd.add(c);
  } 

}