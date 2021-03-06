/*
  Author Aaron Ma
  date last edited: Dec 7 2018
  Assignment 2 Pattern 2
*/
void setup() {
  size(830, 830);
}
//current level of the fractal
int cl;
//the next time a key press will be registered register
long nextKey;
//the current phase used to change color;
int phase;
void draw() {
  background(255);  
  //if a key is pressed and the cooldown on the key is over
  if (keyPressed && nextKey < System.currentTimeMillis()) {
    nextKey = System.currentTimeMillis() + 100;
    cl++;
  }
  cl %= 5;
  //if current fractal layer is zero
  if (cl == 0) {
    //inc phase
    phase++;
    //inc layer
    cl = 1;
  }
  //make sure phase is between 0 and 5
  phase %= 5;
  col[]col = new col[2];
  noStroke();
  // green to blue
  if (phase == 1) {
    col[0] = new col(25, 25, 255, 255);
    col[1] = new col(25, 255, 25, 255);
    //blue to green
  } else if (phase == 2) {
    col[0] = new col(25, 255, 25, 255);
    col[1] = new col(25, 25, 255, 255);
    //purple to yellow
  } else if (phase == 3) {
    col[0] = new col(255, 255, 25, 255);
    col[1] = new col(255, 25, 255, 255);
  } else if (phase == 4) {
    //yellow to purple
    col[0] = new col(255, 25, 255, 255);
    col[1] = new col(255, 255, 25, 255);
  } else {
    //greyscale
    col[0] = new col(255, 255, 255, 255);
    col[1] = new col(0, 0, 0, 255);
  }
  fractal(0, cl, 15, 15, 815, 815, col);
}

//renders a fractal recursively with a gradient 
//dimension of ln(8)/ln(3)
void fractal(int cl, int ml, float sx, float sy, float ex, float ey, col[]col) {
  col[][]grad = grad(col, 5);
  if (cl <= ml) {
    float delta = (ex - sx)/3f;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        //top left corner of current fractal
        float xval = (i)*delta + sx;
        float yval = (j)*delta + sy;
        // if the current square is the centre
        if (!((i == 1) && (j== 1))) {

          //minimize rect() calls for performence reasons
          if (cl == ml || cl == 1) {
            fill(grad[i+1][j+1].encode());
            rect(xval, yval, delta, delta);
          }
          //gradation of the next fractal call
          col[]cl1 = new col[2];
          cl1[0] = grad[i+1][j+1];
          cl1[1] = grad[i][j];
          //render the next fractal level
          fractal(cl+1, ml, xval, yval, xval+delta, yval+delta, cl1);
        } else {
          
          //if the current square is the centre 
          //fill it in with white
          fill(255);
          rect(xval, yval, delta, delta);
        }
      }
    }
  }
}

//utility method to make my life easier
double sqr(double k) {
  return k*k;
}
//returns a linear gradient between col[0][0] and col[1][1] based on euclidean distance 
public col[][]grad(col[]col, int w) {

  //make a new gradient
  col[][]a = new col[w][w];
  for (int i = 0; i < w; i++) {
    for (int j = 0; j < w; j++) {
      double dx, dy;
      dx = i/(float)w;
      dy = j/(float)w;
      //strength of d2 to d1 based on euclidan distance
      float d = sqrt((float)((sqr(dx) + sqr(dy))));
      a[i][j] = col[0].mix(col[1], 1-d);
    }
  }
  return a;
}
class col {
  int r, g, b, a;
  //constructor
  public col(int c) {
    b = c &255; //blue channel
    g = (c >> 8) &255; //green channel
    r = (c >> 16) &255; //red channel
    a = (c >>  24) & 255; //alpha channel
  }
  // constructor 
  public col(int r, int g, int b, int a) {
    this.r = r;
    this.g = g;
    this.b = b;
    this.a = a;
  }
  //encode the color
  public int encode() {
    int c = 0;
    c += r<<16; //left shift by 16 for red channel
    c += g<<8; //left shift by 8 for green channel
    c += b;  //blue channel 
    c+= a << 24; //set alpha channel to 255
    return c;
  }
  public col mix(col cl, float ratio) {
    //blend the two alpha channels
    int alpha = (int)(((1-ratio) * a + ratio*cl.a)*255);

    return new col(blendChannel(r, cl.r, ratio), blendChannel(g, cl.g, ratio), blendChannel(b, cl.b, ratio), alpha);
  }
  //blend 2 color channel
  private int blendChannel(int a, int b, float ratio) {
    //blend two color channels
    float a1, b1;
    //channels as a fraction of 255
    a1 = a/255f;
    b1 = b/255f;
    //square root of the squares of fractions
    float res = (float)Math.sqrt((1-ratio)*a1*a1 + ratio*b1*b1);
    //multiply by 255 and cast to integer to get a proper color channel
    return (int)(res * 255) ;
  }
}
