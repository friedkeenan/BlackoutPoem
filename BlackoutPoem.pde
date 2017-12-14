import java.util.ArrayList; //Import the ArrayList class to be used later
PImage img;
color rcol=color(0,0,0,128); //Make the color of the rectangles a half transparent black
PVector rstart;
PVector trans=new PVector();
PVector torig=new PVector();
PVector tstart;
boolean save;
float scale=.02;
class Rectangle{ //Make class Rectangle to make things easier
  PVector start,end;
  Rectangle(float x1,float y1,float x2,float y2){
    start=new PVector(x1,y1);
    end=new PVector(x2,y2);
  }
  boolean collide(float x,float y){ //See if point is inside rectangle
    return x>start.x&&x<end.x&&y>start.y&&y<end.y;
  }
  void draw(){
    rect(start.x,start.y,end.x-start.x,end.y-start.y);
  }
}
ArrayList<Rectangle> rects=new ArrayList<Rectangle>(); //Make ArrayList of Rectangles so that you can have an arbitrary amount
void doNoise(color col){ //Function that returns nothing and takes a color as input
  set(0,0,img); //Place img at absolute (0,0)
  img.loadPixels(); //Make it so you can adjust the pixels in img
  for(int x=0;x<width;x++){ //For every x from 0 to width
    for(int y=0;y<height;y++){ //For every y from 0 to height
      boolean collide=false;
      for(Rectangle r:rects){ //Check to see if the current (x,y) is in a Rectangle
        if(r.collide(x,y)){
          collide=true;
          break; //Break if there is a collision since we don't need to check all Rectangles
        }
      }
      if(collide)
        continue; //Go to next (x,y) in the loop if there was a collision
      float lerp=noise(scale*x,scale*y); //Get Perlin noise value from 0 to 1 at (scale*x,scale*y)
      lerp=map(lerp,0,1,.25,1); //Change 0 to 1 interval to .25 to 1 to make sure no pixel is too light
      color c=get(x,y); //Get color at (x,y)
      c=lerpColor(c,col,lerp); //Make c look more like col by a factor of lerp
      img.pixels[x+width*y]=c; //The color at (x,y) is now c
    }
  }
  img.updatePixels(); //Update the pixels in img to reflect what we just did
}
void keyPressed(){
  switch(key){
    case 't': //If T is pressed, reset trans to (0,0)
      trans.set(0,0);
      break;
    case 'c': //If C is pressed, clear all the Rectangles
      rects.clear();
      break;
    case 'r': //If R is pressed, do both T and C
      trans.set(0,0);
      rects.clear();
      break;
    case 's': //If S is pressed, set trans to (0,0) and save the frame in the next frame
      trans.set(0,0);
      save=true;
      break;
    case 'n': //If N is pressed, do the noise stuff
      trans.set(0,0);
      doNoise(color(255,0,128)); //Do the noise with hot pink
      break;
  }
}
void mousePressed(){
  switch(mouseButton){
    case LEFT: //If left mouse button is clicked, draw a rectangle
      if(rstart==null)
        rstart=new PVector(mouseX-trans.x,mouseY-trans.y);
      else{
        rects.add(new Rectangle(rstart.x,rstart.y,mouseX-trans.x,mouseY-trans.y));
        rstart=null;
      }
      break;
    case RIGHT: //If right is clicked on a rectangle, remove that rectangle
      for(int i=rects.size()-1;i>-1;i--){
        if(rects.get(i).collide(mouseX-trans.x,mouseY-trans.y)){
          rects.remove(i);
          break;
        }
      }
      break;
    case CENTER: //If middle is dragged, translate accordingly
      if(tstart==null){
        torig=trans.copy();
        tstart=new PVector(mouseX,mouseY);
      }
  }
}
void mouseReleased(){
  if(mouseButton==CENTER){ //If middle mouse button is released, stop translating
    trans.add(mouseX-tstart.x,mouseY-tstart.y);
    tstart=null;
  }
}
void setup(){ //Do all this stuff before everything
  img=loadImage("Girl.png");
  surface.setSize(img.width,img.height); //Set the size of the window to the size of the image
  noStroke(); //Don't want an outline on any shapes
  fill(rcol); //The shapes should be filled with rcol
}
void draw(){
  if(tstart!=null){ //If tstart has a value (when middle click is being dragged)
    trans.add(mouseX-tstart.x,mouseY-tstart.y);
    translate(trans.x,trans.y); //Translate accordingly
    trans=torig.copy(); //Back to what trans was before middle click was dragged to avoid weirdness
  }else //Otherwise translate normally
    translate(trans.x,trans.y);
  background(0); //Make the background black
  image(img,0,0); //Put img at (0,0)
  for(Rectangle r:rects) //Draw all the Rectangles
    r.draw();
  if(rstart!=null) //If a Rectangle is being created, draw it
    rect(rstart.x,rstart.y,mouseX-trans.x-rstart.x,mouseY-trans.y-rstart.y);
  if(save){ //If S was pressed, save the image as "img.png"
    saveFrame("img.png");
    save=false;
  }
}