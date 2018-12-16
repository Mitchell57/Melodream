/*
 * SpectrogramDemo
 * Takes successive FFTs and renders them on screen in color, scrolling left
 *
 * Based on LiveSpectrogram by Dan Ellis (dpwe@ee.columbia.edu)
 *
 * Uses elements from FIND SOURCE OF CUBE-ALIZER
 *
 * Mitchell Lewis mblewis@ucsb.edu 2018-11-23
 */
 
import ddf.minim.analysis.*;
import ddf.minim.*;
 
Minim minim;
AudioPlayer song;
BeatDetect beat;
FFT fft;

float beatA = 10;
float beatB = 10;
float beatC = 10;
float maxHeight;
float yesBeat = 8;
float noBeat = 2.5;


int colmax = 1024;
int rowmax = 7;
int[][] scores = new int[rowmax][colmax];
float[][] rawScores = new float[rowmax][colmax];
int col;
int leftedge, lastCount, lastSec;

float attack, average, rawScore;

// Variables that define the "zones" of the spectrum
// For example, for bass, we take only the first 4% of the total spectrum
int bandSize = 1025;
float specLow = 0.1*bandSize; // 3%
float specMid = 0.60*bandSize;  // 12.5%



// This leaves 64% of the possible spectrum that will not be used.
// These values are usually too high for the human ear anyway.



float[] max = {1, 1, 1, 1, 1, 1, 1};
int[] top = {795, 665, 535, 405, 275, 145, 15};
int[] bottom = {895, 765, 635, 505, 375, 245, 115};
int[] limits = {0, 3, 4, 9, 10, 22, 23, 50, 55, 90, 95, 190, 195, 400};
int[] testlimits = {420, 500, 600, 700, 800, 900, 950, 1024};


void setup()
{
  size(1024, 910, P3D);
  textMode(SCREEN);
  frameRate(100);
 
  minim = new Minim(this);
  colorMode(HSB, 100);
   
  song = minim.loadFile("song2.mp3", 2048);
  song.play();
  // a beat detection object song SOUND_ENERGY mode with a sensitivity of 10 milliseconds
  beat = new BeatDetect(song.bufferSize(), song.sampleRate());
  beat.setSensitivity(200);
  
  maxHeight = height / 3;
 
  fft = new FFT(song.bufferSize(), song.sampleRate());
  fft.window(FFT.HAMMING);
  
  bandSize = fft.specSize();
  
  song.play();
  int frames = 0;
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
  
  if (keyPressed) {
    if (key == TAB) {
      for(int i=0; i<rowmax; i++){
       max[i] = 1; 
      }
    }
  }
  
  background(0);
  stroke(255);
  // perform a forward FFT on the samples in the input buffer
  fft.forward(song.left);
  int total = 0;
  for(int i=0; i<rowmax; i++){
    rawScore = 0;
    for(int j=limits[2*i]; j<limits[(2*i)+1]; j++){
      rawScore += fft.getBand(j);
    }
    rawScores[i][col] = rawScore;
    
    attack = 0;
    if(col > 0) attack = rawScore - rawScores[i][col-1];
    average = rawScore+attack/2;
    if(average > max[i]) max[i] = average;
    scores[i][col] = Math.round((average/max[i])*100);

  }
  
  // resets maxes when song changes
  if(total < 1 ){
    for(int i=0; i<rowmax; i++){
       //max[i] = 1; 
      }
  }
  
  // next time will be the next column
  
  col = col + 1; 
  // wrap back to the first column when we get to the end
  if (col == colmax) { col = 0; }
  
  // Draw points.  
  // leftedge is the column in the ring-filled array that is drawn at the extreme left
  // start from there, and draw to the end of the array
  for (int i = 0; i < colmax-leftedge; i++) {
    for(int l=0; l<rowmax; l++){
      int size = scores[l][i+leftedge]+2;
      int margin = (100-size)/2;
      if(size < 25) stroke(50, 100, size);
      else stroke(size, 100, 90);
      line(i, (top[l]+margin), i, (bottom[l]-margin));
    }


  }
  // Draw the rest of the image as the beginning of the array (up to leftedge)
  for (int i = 0; i < leftedge; i++) { 
    for(int l=0; l<rowmax; l++){
      int size = scores[l][i]+2;
      int margin = (100-size)/2;
      if(size < 25) stroke(50, 100, size);
      else stroke(size, 100, 90);
      line(i+colmax-leftedge, (top[l]+margin), i+colmax-leftedge, (bottom[l]-margin));
    }
    
  }
  // Next time around, we move the left edge over by one, to have the whole thing
  // scroll left
  leftedge = leftedge + 1; 
  // Make sure it wraps around
  if (leftedge == colmax) { leftedge = 0; }
  drawRectangles();

}
 
 
void stop()
{
  // always close Minim audio classes when you finish with them
  song.close();
  minim.stop();
 
  super.stop();
}

void drawRectangles() {
  
 beat.detect(song.mix);
 
 noStroke();
 fill(0, 0, 20);
 
 if(beat.isKick()) beatA = yesBeat; 
 if(beat.isSnare()) beatB = yesBeat;
 if(beat.isHat()) beatC = yesBeat;
 
 rect(10, maxHeight*(2+1/beatA), width-20, maxHeight*(1-(2/beatA)));
 rect(10, maxHeight*(1+1/beatB), width-20, maxHeight*(1-(2/beatB)));
 rect(10, maxHeight*(1/beatC), width-20, maxHeight*(1-(2/beatC)));

 
 beatA *= 0.95;
 beatB *= 0.95;
 beatC *= 0.95;
 
 if(beatA < 3) beatA = noBeat;
 if(beatB < 3) beatB = noBeat;
 if(beatC < 3) beatC = noBeat;
}
