/*
 * MelodreamDemo1
 * Takes successive FFTs and maps them to a visual display of shapes
 *
 *
 * Mitchell Lewis mblewis@ucsb.edu 2018-11-23
 */
 
import ddf.minim.analysis.*;
import ddf.minim.*;
 
Minim minim;
//AudioPlayer song;
AudioInput in;
//BeatDetect beat;
FFT fft;

float decreaseRate = 1;
float increaseRate = 1.8;
float scoreMax = 100;
float angle;

int rowmax = 7;
float[] rawScores = new float[rowmax];
float[] inScores = {30, 30, 30, 30, 30, 30, 30};
int circleMax = 100;
float[] circlePos = new float[circleMax];
float total = 0;
int col;
int leftedge, lastCount, lastSec;

float attack, average, rawScore;

float colorMod = 0;

float[] max = {100, 100, 100, 100, 100, 100, 100};
int[] limits = {0, 3, 4, 9, 10, 22, 23, 50, 55, 90, 95, 190, 195, 400};

boolean colorUp = true;

PImage img;



void setup()
{
  //size(800, 800, P3D);
  fullScreen(P3D, 2);
  textMode(SCREEN);
  frameRate(60);
  
  img = loadImage("texture.jpg");
 
  minim = new Minim(this);
  colorMode(HSB, 255, 110, 100, 255);
   
  in = minim.getLineIn(Minim.STEREO, 2048);
  
  //song = minim.loadFile("song5.mp3", 2048);
  // a beat detection object song SOUND_ENERGY mode with a sensitivity of 10 milliseconds
  //beat = new BeatDetect(song.bufferSize(), song.sampleRate());
  //beat.setSensitivity(200); 
  //maxHeight = height / 3;
 
  //fft = new FFT(song.bufferSize(), song.sampleRate());
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.window(FFT.HAMMING);

  
  //song.play();

  lastCount = 0;


}
 
 
void draw()
{
  /*if(second() != lastSec){
      int fps = frameCount - lastCount;
      lastCount = frameCount;
      lastSec = second();
      print(fps+" fps\n");
  }*/
  
  // TODO: Implement Max Resets
  
  background(0);
  stroke(255);
  // perform a forward FFT on the samples in the input buffer
  fft.forward(in.mix);
  total = 0;
  // for each of the defined ranges
  for(int i=0; i<rowmax; i++){
    
    // sum  up the "band"
    rawScore = 0;
    for(int j=limits[2*i]; j<limits[(2*i)+1]; j++){
      rawScore += fft.getBand(j);
    }
    
    // get average of "band" (out of 100)
    rawScore = 10*rawScore / (limits[2*i+1]-limits[2*i]);
    
    attack = rawScore - rawScores[i];
    average = rawScore+attack/2;
    rawScores[i] = rawScore;
    if(average > max[i]) max[i] = average;
    float score = boost((average/max[i])*100, 30);
    total += score;
    if(score < inScores[i]) {
      if(abs(score-inScores[i]) > 2){
        score = inScores[i] - decreaseRate;
      }
    }
    if(score > inScores[i]) {
      if(abs(score-inScores[i]) > 2){
        score = inScores[i] + increaseRate;
      }
    }
    inScores[i] = score;

  }
  
  total /= 7;
  
  directionalLight(0, 0, 255, 0, 0, -1);
  pointLight(colorMod*25.5, 50, 250, width/2, height/2, -800);
  drawTriangleGroup(inScores[5], round(inScores[5]*255/100-20+colorMod), 10, width/15);
  drawTriangleGroup(inScores[0], round(inScores[0]*255/100-20+colorMod), 10, width/6);
  drawTriangleGroup(inScores[1], round(inScores[3]*255/100-30+colorMod), 10, width/4);
  drawTriangleGroup(inScores[2], round(inScores[1]*255/100-30+colorMod), 10, width/2.75);
  drawTriangleGroup(inScores[0], round(inScores[0]*255/100-20+colorMod), 10, width/2);
  
 drawCircleGroup(inScores[5], 3, round(30+(colorMod*25.5)), 0);
  drawCircleGroup(inScores[4]+30, 3, round(10+(colorMod*25.5)), 1);
  drawCircleGroup(inScores[6]+90, 3, round(50+(colorMod*25.5)), 2);
  drawCenterCircle(inScores[3], round((colorMod*25.5)));
  
  drawHexagonGroup(inScores[4], round((colorMod*25.5)/2)+10, 1, width/20, 80);
  drawHexagonGroup(inScores[4], round((colorMod*25.5)/2)+20, 2, width/15.7, 100);
  drawHexagonGroup(inScores[3], round((colorMod*25.5)/2)+30, 1, width/8.7, 120);
  drawHexagonGroup(inScores[4], round((colorMod*25.5)/2)+40, 1, width/3, 140);
  drawHexagonGroup(inScores[3], round((colorMod*25.5)/2)+50, 2, width/4.7, 160);
  //drawHexagonGroup(inScores[3], round(inScores[3]*255/200+colorMod), 10, width/6, 240);*/
  
  
  //drawCircleGroup(inScores[5]*2, 10, 80);
  //drawCircleGroup(inScores[5], 3, round(inScores[0]*255/100));
  
  
  
  

  
  
  
  
  
    

    

  

  if(colorUp){
    if(colorMod <= 10) {
      colorMod += 0.02*(total/100);
      angle += total/50;
    }
    else colorUp = false;
  }
  else{
   if(colorMod > 0) {
     colorMod -= 0.02*(total/100);
     angle -= total/50;
   }
   else colorUp = true;
  }
  


}

void keyPressed(){
 if(keyCode == TAB){
   for(int i=0; i<rowmax; i++){
     inScores[i] = 0; 
   }
 }
}
 
 
void stop()
{
  // always close Minim audio classes when you finish with them
  //song.close();
  minim.stop();
 
  super.stop();
}



void drawTriangleGroup(float score, int colorVal, float num, float len){
  if(score<30) score = 30;
  float max = score/ (num);
  for(int i=round(num); i>=0; i--){
    //outer
    drawTriangles(-max*2*(i), colorVal/5+(5*i), len);
    // inner
    drawTriangles(max*2*(i), colorVal/5+(5*i), len);
  }
  
}
void drawHexagonGroup(float score, int colorVal, int num, float len, float opacity){


  for(int i=num; i>0; i--){
    
   
   drawHexagon((score), len+(i*len), opacity, colorVal*1.2);
   //drawHexagon((score+(10*i)), len-50+(i*len), opacity/2, colorVal);
   
  }
}


void drawTriangles(float score, float colorVal, float len){
  
 float h = (height-(len*sqrt(3)))/2;
 float offset = (width - len)/2;
 noStroke();
 fill(colorVal+20*(colorMod), 30, (colorVal*1.3));
 for(int i=0; i<6; i++){
   pushMatrix();
   translate(0, 0, -200+(len/width)*100);
   
   switch(i){
     case 0:
       translate(offset, h);
       break;
     case 1:
       translate(offset+len, h);
       rotate(radians(60));
       break;
     case 2:
       translate(1.5*len+offset, h+(0.5*(len*sqrt(3))));
       rotate(radians(120));
       break;
     case 3:
       translate(offset+len, len*sqrt(3)+h);//
       rotate(radians(180));
       break;
     case 4:
       translate(offset, len*sqrt(3)+h);
       rotate(radians(240));
       break;
     case 5:
       translate(offset-0.5*len, h+(0.5*(len*sqrt(3))));
       rotate(radians(300));
       break;
   }
   //rotateX(radians(angle+40));
   //rotateY(radians(angle+(len/1000)));
   triangle(0,0, len/2, score*len/600, len, 0);
   popMatrix();
 }
  
}

void drawHexagon(float score, float len, float opacity, float colorVal){
 float h = (height-(len*sqrt(3)))/2;
 float offset = (width-len)/2;
 float angleCoeff = len/1000;
 noStroke();
 fill(colorVal, 30, score*255/100, opacity);
 
 for(int i=0; i<6; i++){
   
   pushMatrix();
   translate(0, 0, -300+((len/width)*100));
   switch(i){
     case 0:
       translate(offset, h);
       break;
     case 1:
       translate(offset+len, h);
       rotateZ(radians(60));
       //translate(len/2, 0);
       break;
     case 2:
       translate(1.5*len+offset, h+(0.5*(len*sqrt(3))));
       rotateZ(radians(120));
       //translate(len/2, 0);
       break;
     case 3:
       translate(offset+len, len*sqrt(3)+h);//
       rotate(radians(180));
       //translate(len/2, 0);
       break;
     case 4:
       translate(offset, len*sqrt(3)+h);
       rotate(radians(240));
       //translate(len/2, 0);
       break;
     case 5:
       translate(offset-(0.5*len), h+(0.5*(len*sqrt(3))));
       rotate(radians(300));
       //translate(len/2, 0);
       break;
   }
   rotateX(radians(90+(score*1.5)));
   rect(0, 0, len, score*len/(sqrt(len)*25));
   popMatrix();
 }
}

void drawCircleGroup(float score, int num, float colorVal, int num2){
  for(int i=num*num2; i<num+(num*num2); i++){
    drawCircles(score-(i*10), colorVal, i);
  }
  
}

void drawCircles(float score, float colorVal, float num){
  // set stroke/fill 
  noStroke();
  fill(colorVal, 70, colorVal, 100);
  for(int i=6*round(num); i<6+(6*num); i++){
  // draw things
  float goal = (score/100)*width;
  if(circlePos[i] < goal) circlePos[i] += 2;
  if(circlePos[i] > goal) circlePos[i] -= 1;
  //if(circlePos[i] > width) circlePos[i] = 0;

    fill(colorVal, 70, colorVal, 255-(circlePos[i]*255/width));
    pushMatrix();
    
    translate(width/2, height/2, -1000+((circlePos[i]/width)*500));
    rotateZ(angle*sqrt(circlePos[i])/3000);
    rotateZ(radians(60*i));
    rotateY(radians(210));
    
    translate(circlePos[i], 0, 0);
    float sphereSize = 70-width/(circlePos[i]+50);
    
    sphere(min(sphereSize, 20));
    
    
    

    popMatrix();
    
  }
}

void drawCenterCircle(float score, float colorVal){
 noStroke();
 
 for(int i=5; i>0; i--){
   fill(colorVal, 30, colorVal, 50);
   pushMatrix();
     translate(width/2, height/2, -40*i);
     rotateY(angle/500);
     rotateZ(angle/500);
     
     sphere(log(i)*(score));
     
   popMatrix();
 }
}

float boost(float val, float min){
  float range = scoreMax - min; 
  return ((val*range)/scoreMax)+min;
}
