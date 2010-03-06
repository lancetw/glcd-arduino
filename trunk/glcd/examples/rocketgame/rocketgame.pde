//
// NOTE
// This code was originally published on the arduino forum:
//	http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1265067548
//
//************************************************************
//
// Can I haz comments?
//

#include <glcd.h>
#include "fonts/SystemFont5x7.h"   // font
#include "bitmaps.h"         // bitmaps

/*
******************************
*  A few pin defines         *
******************************
*/

//#define glcd_brightness 64
//#define glcd_brightnessPin 3

#define controlpotPin 5 // analog pin for rocket up/down control

//#define speakerPin 16	// digital pin to drive piezo or high resistance speaker


#define PLAYER 0
#define ROCK1 1
#define ROCK2 2
#define ROCK3 3
#define ROCK4 4
#define ROCK5 5
#define ROCK6 6
#define ROCK7 7
#define ROCK8 8
#define BONUS 9

#define EX1 0
#define EX2 1
#define EX3 2


#define playerX tracker[0][1]
#define playerY tracker[0][2]

#define enemy1type tracker[1][0]
#define enemy1X tracker[3][1]
#define enemy1Y tracker[4][2]

#define playerXOld trackerOld[0][1]
#define playerYOld trackerOld[0][2]
#define enemy1XOld trackerOld[3][1]
#define enemy1YOld trackerOld[4][2]

char lives = 3;
char score = 0;
char level = 0;
char fastSpeed = 25;
char rockAmount = 6;

long speedMillis[] = {
  0, 0, 0, 0, 0, 0};

char tracker[8][5] = {
// Bitmap,  Xpos,   Ypos,          Speed
  {PLAYER,  15,     32,            0}  ,
  {ROCK2,   119,    random(0, 56), random(25, 75)}  ,
  {ROCK5,   119,    random(0, 56), random(25, 75)}  ,
  {ROCK8,   119,    random(0, 56), random(25, 75)}  ,
  {ROCK1,   119,    random(0, 56), random(25, 75)}  ,
  {ROCK3,   119,    random(0, 56), random(25, 75)}  ,
  {BONUS,   119,    random(0, 56), random(25, 75)}
};

char trackerOld[8][5] = {
// Bitmap,  Xpos,   Ypos,          Speed
  {PLAYER,  15,     32,            0}  ,
  {ROCK2,   119,    random(0, 56), random(25, 75)}  ,
  {ROCK5,   119,    random(0, 56), random(25, 75)}  ,
  {ROCK8,   119,    random(0, 56), random(25, 75)}  ,
  {ROCK1,   119,    random(0, 56), random(25, 75)}  ,
  {ROCK3,   119,    random(0, 56), random(25, 75)}  ,
  {BONUS,   119,    random(0, 56), random(25, 75)}
};


void setup(){
  Serial.begin(9600);
  GLCD.Init(NON_INVERTED);

#ifdef glcd_brightness
  pinMode(glcd_brightnessPin, OUTPUT);
  analogWrite(glcd_brightnessPin, glcd_brightness);
#endif
#ifdef speakerPin
    pinMode(speakerPin, OUTPUT);
#endif
    
  GLCD.SelectFont(System5x7);
  randomSeed(analogRead(controlpotPin));
  GLCD.DrawBitmap(startup, 0, 0, BLACK);
  delay(2000);
  GLCD.ClearScreen();
}

/*
******************************
*  Main loop                 *
*                            *
******************************
*/
void  loop(){
  getControls();
  drawFrame();
  drawLives();
  drawScore(); 
}




/*
******************************
*  Draw the remaining lives  *
*                            *
******************************
*/
void drawLives(){
  GLCD.DrawBitmap(heart, 0, 0, BLACK);
  GLCD.CursorTo(1,0);
  GLCD.PrintNumber(lives);
}



/*
******************************
*  Draw the current score    *
*                            *
******************************
*/
void drawScore(){
  GLCD.CursorTo(0,7);
  GLCD.PutChar('S');
  GLCD.PrintNumber(score);
}



/*
******************************
*  Get the cuttent stick     *
*  position                  *
******************************
*/
void getControls(){
  playerY = map(analogRead(controlpotPin), 0, 1023, 0, 56);
}




/*
******************************
*  Update the position of    *
*  the rocks                 *
******************************
*/
void updatePos(int entity){
    if (millis() - speedMillis[entity-1] > tracker[entity][3]) {
      speedMillis[entity-1] = millis();
      tracker[entity][1] --;
      
        if(collision(entity) == true){
          BLOWUP();
        }
      
      if(tracker[entity][1] < 1){
        score++;
        level++;
        constrain(level, 0, 75);
        if(level > 75){
          fastSpeed --;
          constrain(fastSpeed, 10, 25);
        }
        
        tracker[entity][0] = random(1, 8);   // bitmap
        tracker[entity][1] = 119;            // start point
        tracker[entity][2] = random(8, 56);  // height
        tracker[entity][3] = random(fastSpeed, 100-level); // speed
      }  
  }
}




/*
******************************
*  Detect collisions         *
* *False triggers*           *
******************************
*/
boolean collision(char entity){
  for(char playerScanCOL = 0; playerScanCOL<=9; playerScanCOL++){
    if(tracker[0][1]+playerScanCOL == tracker[entity][1]+1){
      for(char playerScanROW = -1; playerScanROW < 6; playerScanROW  ++){
      for(char entityScanROW = -1; entityScanROW < 6; entityScanROW  ++){
        if(tracker[0][2]+playerScanROW == tracker[entity][2]+entityScanROW){
          return true;
         }
      }
     }
    }
  }
  return false;
}




/*
******************************
*  Blow up a ship            *
*                            *
******************************
*/
void BLOWUP(){
  lives--;
  digitalWrite(13, HIGH);
  explosionAnim(tracker[0][1]-2, tracker[0][2]-4);
  digitalWrite(13, LOW);
  GLCD.ClearScreen();
  if(lives < 0){
    gameOver();
    lives = 3;
    level = 0;
  }
  resetTracker();
}




/*
******************************
*  Reset the tracker to a    *
*  fresh state               *
******************************
*/
void resetTracker(){
  char trackerReset[8][5] = {
  {PLAYER, 15, 32, 0}  ,
  {ROCK2,   119, random(0, 56), random(25, 75)}  ,
  {ROCK5,   119, random(0, 56), random(25, 75)}  ,
  {ROCK8,   119, random(0, 56), random(25, 75)}  ,
  {ROCK1,   119, random(0, 56), random(25, 75)}  ,
  {ROCK3,   119, random(0, 56), random(25, 75)}  ,
  {BONUS,   119, random(0, 56), random(25, 75)}
  };
  
  for(byte entity = 0; entity <= 6; entity++){
    for(byte data = 0; data <= 3; data++){
      tracker[entity][data] = trackerReset[entity][data];
    }
  }
}




/*
******************************
*  Draw GAME OVER and reset  *
*  the score                 *
******************************
*/
void gameOver(){
  GLCD.DrawBitmap(gameover, 37, 0, BLACK);
  delay(5000);
  score = 0;
  GLCD.ClearScreen();
}




/*
******************************
* Animated 3 frame explosion *
* Needs the frams in 1 array *
******************************
*/
void explosionAnim(char xPos, char yPos){
  GLCD.DrawBitmap(ex1, xPos, yPos, BLACK);
#ifdef speakerPin
  noise(175);
#else
  delay(175);
#endif
  GLCD.DrawBitmap(ex2, xPos, yPos, BLACK);
#ifdef speakerPin
  noise(175);
#else
  delay(175);
#endif
  GLCD.DrawBitmap(ex3, xPos, yPos, BLACK);
#ifdef speakerPin
  noise(175);
#else
  delay(175);
#endif
}




/*
******************************
*  Draw a frame, player and  *
*  rocks                     *
******************************
*/
void drawFrame(){
  for(int i=1; i<=rockAmount; i++){
    updatePos(i);
    drawRock(i);
  }
  if(playerY != playerYOld){
    GLCD.FillRect(playerXOld, playerYOld, 10, 8, WHITE);
    GLCD.DrawBitmap(player, playerX, playerY, BLACK);
  }

  for(byte entity = 0; entity <= 6; entity++){
    for(byte data = 0; data <= 3; data++){
      trackerOld[entity][data] = tracker[entity][data];
    }
  }
}




/*
******************************
*  Draw rocks, way too much  *
*  code...                   *
******************************
*/
void drawRock(char entity){
// Rock bitmaps really need to be in a 2D array, will cut down on the below
  
  if(tracker[entity][1] != trackerOld[entity][1]){

    GLCD.FillRect(trackerOld[entity][1], trackerOld[entity][2], 12, 8, WHITE);
    GLCD.DrawBitmap(rocks[tracker[entity][0]], tracker[entity][1], tracker[entity][2], BLACK);
  }
}



#ifdef speakerPin
/*
******************************
*  make noise for the given
*  duration in milliseconds
* (Addition by Michael Margolis)
******************************
*/
void noise(int duration)
{
  unsigned long start = millis();
  
  while( millis() - start < duration)
  {
    int period = random(8,25);
    digitalWrite(speakerPin, HIGH);
    delay(period);
    digitalWrite(speakerPin, LOW);
    delay(period);
  }
}   

#endif