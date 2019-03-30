// Some real-time FFT! This visualizes music in the frequency domain using a
// polar-coordinate particle system. Particle size and radial distance are modulated
// using a filtered FFT. Color is sampled from an image.

import ddf.minim.analysis.*;
import ddf.minim.*;
//midi
import themidibus.*; //Import the library
import javax.sound.midi.MidiMessage; //Import the MidiMessage classes http://java.sun.com/j2se/1.5.0/docs/api/javax/sound/midi/MidiMessage.html
import javax.sound.midi.SysexMessage;
import javax.sound.midi.ShortMessage;

MidiBus myBus; // The MidiBus

OPC opc;
PImage dot;
PImage colors;
Minim minim;
AudioInput in;
FFT fft;
float[] fftFilter;

float spin = 0.002; //how fast it spins  JD default = 0.0015
float radiansPerBucket = radians(7); //ehhh...
float decay = 0.4;  //more = glowy, less = flashy. JD defaul: 0.98 
float opacity = 60; // default: 15
float minSize = 0.1; // default: 0.1
float sizeScale = 0.4; // default: 0.7

void setup()
{
  size(1600, 800, P2D);

  minim = new Minim(this); 

  // Small buffer size!
  in = minim.getLineIn();

  fft = new FFT(in.bufferSize(), in.sampleRate());
  fftFilter = new float[fft.specSize()];

  dot = loadImage("dot2.png");
  colors = loadImage("colors.png");

  // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);
  // opc.setColorCorrection(2.6, 1.05, 1.0, 0.79);
  float[] angles = {80, 100, 110, 135, 170, 10, 45, 70};
  for (int i = 0; i < angles.length; i++){
    angles[i] = radians(angles[i]);
  }
  opc.ledStrip(0, 92, width/2 - (cos(angles[0])*(height/92)*46), height/2, height/92, angles[0], true);
  opc.ledStrip(128, 92, width/2 - (cos(angles[1])*(height/92)*46), height/2, height/92, angles[1], true);
  opc.ledStrip(256, 64, width/2 - (cos(angles[2])*(height/92)*32), height/1.51, height/92, angles[2], true);
  opc.ledStrip(320, 64, width/2 - (cos(angles[3])*(height/92)*32), height/1.37, height/92, angles[3], true);
  opc.ledStrip(384, 92, width/2 - (cos(angles[4])*(height/92)*46), height/1.14, height/92, angles[4], true);
  opc.ledStrip(512, 92, width/2 - (cos(angles[5])*(height/92)*46), height/1.14, height/92, angles[5], true);
  opc.ledStrip(640, 64, width/2 - (cos(angles[6])*(height/92)*32), height/1.37, height/92, angles[6], true);
  opc.ledStrip(704, 64, width/2 - (cos(angles[7])*(height/92)*32), height/1.51, height/92, angles[7], true);
  
  MidiBus.list();
  myBus = new MidiBus(this, 0, 0);
  
}
  

void draw()
{
  background(0);

  fft.forward(in.mix);
  for (int i = 0; i < fftFilter.length; i++) {
    fftFilter[i] = max(fftFilter[i] * decay, log(1 + fft.getBand(i)));
  }
 
  for (int i = 0; i < fftFilter.length; i += 3) {   
    color rgb = colors.get(int(map(i, 0, fftFilter.length-1, 0, colors.width-1)), colors.height/2);
    tint(rgb, fftFilter[i] * opacity);
    blendMode(ADD);
 
    float size = height * (minSize + sizeScale * fftFilter[i]);
    PVector center = new PVector(width * (fftFilter[i] * 0.2), 0);
    center.rotate(millis() * spin + i * radiansPerBucket);
    center.add(new PVector(width * 0.5, height * 0.96));
 
    image(dot, center.x - size/2, center.y - size/2, size, size);
  }
}

void midiMessage(MidiMessage msg){
  int type = msg.getStatus();
  int control = msg.getMessage()[1] & 0xFF;
  float value = msg.getMessage()[2] & 0xFF;
  //println(type+"    "+control+"    "+value);
  //Map parameters to MIDI knobs
  //1: Opacity
  //2: Decay
  //3: Scale
  //4: Min Size
  if (type == 185){
      if (control==1){
        opacity = map(value, 0, 127, 0, 100);
        println("Opacity set to "+opacity);
      }
      else if (control==2){
        decay = map(value, 0, 127, 0.1, 1.0);
        println("Decay set to "+decay);
      }
      else if (control==3){
        sizeScale = map(value, 0, 127, 0.1, 5.0);
        println("Size set to "+sizeScale);
      }
      else if (control==4){
        minSize = map(value, 0, 127, 0.001, 0.5);
        println("Min Size set to "+minSize);
      }
      else if (control==5){
        spin = map(value, 0, 127, 0.0001, 0.003);
        println("Spin set to "+spin);
      }
  }
  else if (type==128){
      if (control==40){
        colors = loadImage("colors.png");
        println("Colors set to default");
      }
      else if (control==41){
        colors = loadImage("enl.png");
        println("Colors set to ENL-Ingress");
      }
      else if (control==42){
        colors = loadImage("hype.png");
        println("Colors set to HYPE MODE!");
      }
      else if (control==43){
        colors = loadImage("rainbow.jpg");
        println("Colors set to Rainbow");
      }
      else if (control==36){
        colors = loadImage("sunset.jpg");
        println("Colors set to Sunset");
      }
      else if (control==37){
        colors = loadImage("asot.jpg");
        println("Colors set to ASOT");
      }
  }
}
