class Fence {      // Currently, a silly wrapper for the Polygon object
                   // established for future development.665

java.awt.Polygon fence;

// constructor
Fence ()
{
  fence = new java.awt.Polygon();
}

// 
void addPost(int x, int y)
{
  fence.addPoint(x, y);
}

//
int numPosts()
{
  return fence.npoints;
}
  
//
float[] getPost( int i )
{
  return new float[] {fence.xpoints[i], fence.ypoints[i]};   
}
 
//
boolean contains ( float x, float y )
{
  return fence.contains(x,y);
}
}