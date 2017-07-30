//REFERENCE: https://forum.processing.org/two/discussion/comment/101179/#Comment_101179
//REFERENCE: https://math.stackexchange.com/questions/1352792/how-to-derive-the-3d-equation-of-a-torus
//REFERENCE: https://forum.processing.org/two/discussion/comment/102748/#Comment_102748

final int R=150; //Radius
final int VT=5;  //Tangential velocity

final int INIT_N_PTS = 100;
final int MAX_VERS=2;


int n=INIT_N_PTS;
int dn=n;
int drawingVersion=0;

PVector v1 = new PVector(R, 0, 0);     //Current position
PVector v2 = new PVector(0, VT, 0);    //Orthonormal

MotionPoint v, w;
ArrayList<PVector> torus;


void setup() {
  size(800, 800, P3D);
  noStroke();
  textAlign(LEFT, CENTER);
  textSize(18);
  v = new MotionPoint(v1, v2, VT);  
  torus=new ArrayList<PVector>();

  updateTitle();
}

void draw() {

  background(0);
  pushMatrix();
  translate(width/2, height/2, -400);

  camera(width/2.0, (map(mouseY, 0, height, -height, height))/2.0, (height/2.0) / tan(PI*30.0 / 180.0), 0, 0, 0, 0, 1, 0);
  switch(drawingVersion) {
  case 0: 
    drawVersion0();
    break;
  case 1: 
    drawVersion1();
    break;
  case 2: 
    drawVersion2();
    break;
  };
  popMatrix();



  fill(250, 250, 10);
  text("Hit keys 1 to 3 to select different patterns.\nLeft click increases number of points.\nRight click resets number of points.\nMouse Y position adjust camera's angle.", width*0.3, 0.3*height, 200);
}

void mouseReleased() {
  if (mouseButton == LEFT) {
    n+=dn;
  } else if (mouseButton == RIGHT) {
    n=INIT_N_PTS;
  }
  v1.set(100, 0, 0);
  updateTitle();
}

void keyPressed() {

  if (key>='1' && key<='3') {
    drawingVersion=key-'1';
    updateTitle();
  }
}

void updateTitle() {
  surface.setTitle("Drawing selected: "+drawingVersion +" at n= "+ n +" points");
}



void drawVersion0() {
  torus.clear();

  PVector prevPt=new PVector();

  for (int i=0; i<n; i++) {

    pushMatrix();
    fill(v.c);
    v.updatePoint();
    v.draw();
    popMatrix();
  }
}



void drawVersion1() {
  torus.clear();

  PVector prevPt=new PVector();

  for (int i=0; i<n; i++) {

    pushMatrix();

    fill(v.c);
    v.updatePoint();
    v.draw();

    if (i!=0) {
      println(i+"\t"+dist(prevPt.x, prevPt.y, v.getPt().x, v.getPt().y));
    }

    prevPt=v.getPt();

    if (i%5==0) {
      w = new MotionPoint(new PVector(0, 20, 0), v.getDir(), VT);   //v.getPt().setMag(25)
      w.updatePoint(v.getPt());
      for (int j=0; j<n/2; j++) {

        pushMatrix();
        w.updatePoint();
        w.draw();
        popMatrix();

        PVector torusPt=v.getPt().copy();
        torusPt.add(w.getPt());
        torus.add(torusPt.copy());
      }
    }
    popMatrix();
  }

  //========================================================

  fill(0, 255, 0);
  for (PVector p : torus) {
    pushMatrix();
    translate(p.x, p.y, p.z);
    //sphere(2);
    popMatrix();
  }
}





void drawVersion2() {
  torus.clear();

  v.updatePoint();
  w = new MotionPoint(new PVector(0, 20, 0), v.getDir(), VT);  
  w.updatePoint(v.getPt());

  for (int i=0; i<n; i++) {

    pushMatrix();

    fill(v.c);
    v.updatePoint();
    w.updatePoint();

    //v.draw();
    //pushMatrix();    
    //w.draw();
    //popMatrix();

    torus.add(PVector.add(v.cPt, w.cPt));


    popMatrix();
  }

  //========================================================

  fill(0, 255, 0);
  for (PVector p : torus) {
    pushMatrix();
    translate(p.x, p.y, p.z);
    sphere(2);
    popMatrix();
  }
}




/**
 * When one draws a circle, one specifies the radius. Over time, one needs to
 * define the tangential velocity that describes when the next point is draw and
 * at what rate. The radius is defined by a provided vector which magnitude 
 * describes the value of r and it is assume it is drawn from the current 0,0
 * position. One needs to specify a second vector, which indicates direction of
 * rotation using the well know cross product. Vector position acting on an 
 * orthogonal vector yields a third vector orthogonal to each other. This vector
 * is the direction where the velocity is applied and the next point drawn.
 */

class MotionPoint {

  float r;
  float tanVel;
  PVector omegaAxis;
  protected PVector strPt;
  protected PVector cPt;
  protected PVector cDir;


  float rad;
  color c;

  MotionPoint(PVector rnot, PVector orthoAxis, float v) {
    //Get radius
    r=rnot.mag();

    strPt=rnot.copy();

    //Current point
    cPt=rnot.copy();

    //Rotation axis
    omegaAxis=orthoAxis.copy();
    omegaAxis.normalize();

    tanVel=v;
    cDir=null;

    //Drawing attributes
    rad=3;
    c=color(250, 250, 0);
  }

  void updatePoint(PVector ap) {
    cPt=ap.copy();    
    updatePoint();
  }

  void updatePoint() {
    //Pos axis normalized
    PVector v1n=cPt.copy().normalize();

    //Direction axis: pos axis [cross] ortho axis
    cDir = v1n.cross(omegaAxis);  //Working only with unit vectors
    PVector vr=cDir.copy();

    //Assign direction vector    
    cDir.normalize();

    //Resultant vector: direction set to tangential velocity
    vr.setMag(tanVel);

    //Appliy velocity
    cPt.add(vr);

    //Constrain motion to radius
    cPt.setMag(r);
  }

  PVector  getPt() {
    return cPt.copy();
  }

  PVector  getDir() {
    return cDir.copy();
  }


  void draw() {
    translate(cPt.x, cPt.y, cPt.z);
    sphere(rad);
  }
} //END MotionPoint class


































////REFERENCES: 
////REFERENCES: 
////REFERENCES:

////INSTRUCTIONS:
////         *--
////         *--
////         *--
////         *--

////===========================================================================
//// IMPORTS:


////===========================================================================
//// FINAL FIELDS:


////===========================================================================
//// GLOBAL VARIABLES:

//PVector pt;
//PVector omegaVel;
//float tanVel=5;

////===========================================================================
//// PROCESSING DEFAULT FUNCTIONS:

//void settings() {
//  size(400, 600, P3D);
//}

//void setup() {

//  textAlign(CENTER, CENTER);
//  rectMode(CENTER);

//  fill(255);
//  strokeWeight(2);

//  pt=new PVector(200, 0, 0);
//  omegaVel=new PVector(0, 1, 0);
//  omegaVel.setMag(tanVel);
//}



//void draw() {
//  background(0);
//  line(0, 0, 0, pt.x, pt.y, pt.z);
//  translate(pt.x, pt.y, pt.z);
//  sphere(5);
//  PVector newPos=pt.cross(omegaVel);
//}

//void keyReleased() {
//}

//void mouseReleased() {
//}



////===========================================================================
//// OTHER FUNCTIONS: