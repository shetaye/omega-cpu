/*
* This file is part of the Omega CPU Core
* Copyright 2015 - 2016 Joseph Shetaye

* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU Lesser General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.

* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.

* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

// This software was designed for the ZPUino.
 
#define circuit LogicStart_Shield

#include "HQVGA.h"
#include <math.h>
#include <SevenSegHW.h>
#define LS_JOY_UP    11


SEVENSEGHW sevenseg;

const int switchPins[] = { 
  0, 1, 2, 3, 4, 42, 44, 46 };       // an array of pin numbers to which Buttons are attached
const int switchCount = 8;

unsigned char calculateColor(int hue){
  //int C = 1;
  //int M = 0;
  float X = (float) hue;
  switch(hue/60){
   case 0:
     X = X/60;
     return 0xE0 | ((int)(X*8)) << 2;
     break;
   case 1:
     X = 1 - ((X - 59.999) / 60);
     return ((int)(X*8)) << 5 | 0x1C;
     break;
   case 2:
     X =(X-120)/60;
     return 0x1C | (int)(X*4); 
     break;
   case 3:
     X = 1-((X-179.999)/60);
     return ((int)(X*8)) << 2 | 0x03;
     break;
   case 4:
    X = (X-240)/60;
     return ((int)(X*8)) << 5 | 0x03;
   case 5:
     X = 1-((X-299.999)/60);
     return 0xE0 | (int)(X*4); 
     break;
   default:
     return 0;
  }
}

void setup() {
  VGA.begin(VGAWISHBONESLOT(9),CHARMAPWISHBONESLOT(10));
  VGA.clear();
  sevenseg.begin(11);
  sevenseg.setBrightness(8);
  for (int thisPin = 0; thisPin < switchCount; thisPin++)  {
    pinMode(switchPins[thisPin], INPUT);      
  } 
}

void loop() {
  int counter;
  int oldSwitchValue = -1;
  int newSwitchValue;
  int angle = 30;
  float dx = cos((float)angle * M_PI/180);
  float dy = sin((float)angle * M_PI/180);
  sevenseg.setIntValue(angle,0);
  float x = VGA.getHSize()/2;
  float y = VGA.getVSize()/2;
  static int hue = 0;
  int xInt = (int) x,yInt = (int) y;
  while(1){
    newSwitchValue = 0;
    for(int i=switchCount-1;i>=0;i--){
     newSwitchValue = (newSwitchValue << 1) | (digitalRead(switchPins[i]) ? 1 : 0); 
    }
    if(newSwitchValue != oldSwitchValue){
     angle = (int) (newSwitchValue*1.407843137254902);
     dx = cos((float)angle * M_PI/180);
     dy = sin((float)angle * M_PI/180);
     sevenseg.setIntValue(angle,0);
     oldSwitchValue = newSwitchValue;
    }
    x = x+dx;
    y = y+dy;
    if(x<0){
     dx = -dx;
     x = 0; 
    }else if(x >= VGA.getHSize()){
      dx = -dx;
      x = VGA.getHSize()-1;
    }
    if(y < 0){
      dy = -dy;
      y = 0;
    }else if(y >= VGA.getVSize()){
      dy = -dy;
      y = VGA.getVSize()-1; 
    }
    
    if((int) x != xInt || (int) y != yInt){
      xInt = (int) x;
      yInt = (int) y;
      VGA.putPixel(xInt,yInt,calculateColor(hue));
      counter++;
      hue = (hue+1)%360; 
    }
    if(digitalRead(LS_JOY_UP)||counter >= 240*160){
     VGA.clear();
     counter = 0;
    } 
    delay(10);
  }
}
