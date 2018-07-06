import themidibus.*;
import javax.sound.midi.MidiMessage;
import javax.sound.midi.SysexMessage;
import javax.sound.midi.ShortMessage;

MidiBus myBus;
int numNotes = 24;
int startNote;
sTouch[] touches = new sTouch[numNotes];

ArrayList<Attractor> attractors;
ArrayList<Agent> agents;

boolean doClear = true;
boolean play = true;
boolean mirror = true;
boolean rotate = true;

void setup() {   

  attractors = new ArrayList<Attractor>();
  agents = new ArrayList<Agent>();

  for (int i = 0; i < 1500; i++) {
    Agent a = new Agent();    
    agents.add(a);
  }

  size(450,150,P3D);
  //size(1280, 360);
  background(0);
  smooth();
  strokeWeight(2);
  ellipseMode(CENTER);

  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  myBus = new MidiBus(this, 0, 1); // Select Seaboard GRAND device

  // handles the size of the keyboard variable
  if (numNotes == 24) startNote = 48;
  if (numNotes == 25) startNote = 60;
  if (numNotes == 63) startNote = 35;
  if (numNotes == 88) startNote = 0;

  for (int i = 0; i < numNotes; ++i)
  {
    sTouch tem = new sTouch();
    tem.noteNumber = i;
    tem.noteOnVel = 0.0f;
    tem.noteOffVel = 0.0f;
    tem.pitchBend = 0.0f;
    tem.afterTouch = 0.0f;
    tem.isTouched = false;
    touches[i] = tem;
  }
}

void draw() {
  
  for (int i = 0; i < numNotes; i++)
  { 
    if(touches[i].isTouched==true){
      float tempX=width-i*width/numNotes+ touches[i].pitchBend * 12 * width/numNotes/ 8192;
      float tempY=map(touches[i].controllerChange, 0, 127, 0, height);
      float r1 = map(touches[i].afterTouch, 0, 127, 0, 60)+touches[i].pitchBend * 12 * width/numNotes/ 8192;
      float r2 = map(touches[i].noteOnVel, 0, 127, 0, 40);
      Attractor a = new Attractor(tempX,tempY,r1,r2);    
      attractors.add(a);
    }
  }

  if (play) {
    fill(0, 0, 0, 10);
    noStroke();
    rect(0, 0, width, height);
    for (int i = 0; i < agents.size(); i++) {
      agents.get(i).update();
    }
  }

  for (int i = 0; i < attractors.size(); i++) {
    attractors.get(i).update();
  }
  
  attractors.clear();
  
}
/*
void mouseClicked() {
  Attractor a = new Attractor(mouseX, mouseY,30,30);
  attractors.add(a);

  if (mirror) {
    a = new Attractor(width-mouseX, height-mouseY,30,30);
    attractors.add(a);
  }
}
*/

void keyPressed() {
  if (key == 32) {    
    //doClear = true;
  }

  if (key == 'Q' || key == 'q') {
    for (int i = 0; i < agents.size(); i++) {
      agents.get(i).reset();
    }
  }

  if (key == 'M' || key == 'm') {
    mirror = !mirror;
  }

  if (key == 10) {    
    play = !play;
  }
}

class Agent {
  public PVector oPos;//lastFramePosition
  public PVector nPos;//nowPosition
  public PVector vel;//velocity
  public float mass;
  public color c;

  Agent() {
    oPos = new PVector(0, 0);
    nPos = new PVector(0, 0);
    vel = new PVector(0, 0);
    c = color(0, 100, 100); 
    //c=color(random(360), 50, 70);
    mass = 1;
    reset();
  }
  
  public void reset() {
    vel = new PVector(0, 0);

    int dir = int(random(4));

    if (dir == 0) {
      nPos = new PVector(random(width), 0);
    }
    if (dir == 1) {
      nPos = new PVector(random(width), height);
    }
    if (dir == 2) {
      nPos = new PVector(0, random(height));
    }
    if (dir == 3) {
      nPos = new PVector(width, random(height));
    }

    oPos = new PVector(nPos.x, nPos.y);
  }

  void update() {
    boolean doReset = false;

    for (int i = 0; i < attractors.size(); i++) {
      Attractor a = attractors.get(i);

      if (PVector.dist(nPos, a.pos) < 10) {
        doReset = true;
      }

      float d2 = pow(PVector.dist(nPos, a.pos), 2);

      PVector n = PVector.sub(a.pos, nPos);
      n.normalize();
      float f = 100 * (a.mass*mass) / d2;

      n.mult(f);
      vel.add(n);
    }    

    nPos.add(vel);    

    if (doReset == true) {
      reset();
    }
    if (nPos.x < 0) {
      reset();
    }
    if (nPos.y < 0) {
      reset();
    }
    if (nPos.x > width) {
      reset();
    }
    if (nPos.y > height) {
      reset();
    }

    c = color(vel.mag()*30, map(nPos.x+vel.mag()*10,0,width,0,255), 200); 
    stroke(c);
    strokeWeight(3);
    line(oPos.x, oPos.y, nPos.x, nPos.y);
    oPos = new PVector(nPos.x, nPos.y);
  }

}

class Attractor {
  public PVector pos;
  public float mass;
  public float r1;
  public float r2;
  
  Attractor() {
    pos = new PVector(0, 0);
    mass = 1;
  }
  Attractor(float x, float y,float r1,float r2) {    
    pos = new PVector(x, y);
    mass = 1;
    
    noFill();
    stroke(200, map(pos.x,0,width,0,255), 60);
    strokeWeight(3);
    ellipse(x, y, r1, r1);

    colorMode(RGB);
    fill(200, map(pos.x,0,width,0,255), 60);
    noStroke();
    ellipse(x, y, r2, r2);
  }

  void update() {
    noFill();
    stroke(random(0,255), random(0,255), random(0,255));
    strokeWeight(3);
    ellipse(pos.x, pos.y, r1, r1);

    colorMode(RGB);
    fill(200,200,0);
    ellipse(pos.x, pos.y, r2, r2);
  }
}


void rawMidi(byte[] data) {

  int noteNum = (int)(data[1]);
  int channel = (int)(data[0] & 0x0F);
  int value =   0;
  if (data.length > 2) {
    value = (int)(data[2]);
  }
  switch ((byte)(data[0] & 0xF0))
  {
    case (byte)0x90: // NOTE ON

    touches[noteArrayIndex(noteNum)].isTouched = true;
    touches[noteArrayIndex(noteNum)].noteOnVel = value;
    touches[noteArrayIndex(noteNum)].channel = channel;


    println("noteOn: " + noteArrayIndex(noteNum) + " - Channel: " + channel + " - velocity: " + value);
    break;

    case (byte)0x80: // NOTE OFF
    touches[noteArrayIndex(noteNum)].isTouched = false;
    touches[noteArrayIndex(noteNum)].noteOffVel = value;
    touches[noteArrayIndex(noteNum)].noteOnVel = 0.0f;
    touches[noteArrayIndex(noteNum)].afterTouch = 0.0f;
    touches[noteArrayIndex(noteNum)].pitchBend = 0.0f;
    touches[noteArrayIndex(noteNum)].channel = 0;
    touches[noteArrayIndex(noteNum)].controllerChange = 0.0f;

    println("noteOff: " + noteArrayIndex(noteNum) + " - Channel: " + channel + " - velocity: " + value);
    break;

    case (byte)0xD0: // POLY AFTERTOUCH
    value = (int)(data[1]);

    for (int i = 0; i<touches.length; i++) {
      if (touches[i].channel==channel) {
        touches[i].afterTouch = value;
        println("Aftertouch: " + i +" - Channel: " + channel + " - pressure: " + value);
      }
    }
    break;

    case (byte)0xE0: // PITCH BEND
    //gets double byte of pitch bend
    value = (int)(data[2] << 7) + (int) data[1] - 8192;
    for (int i = 0; i<touches.length; i++) {
      if (touches[i].channel==channel) {
        touches[i].pitchBend = value;
        println("Pitch Bend: " + i + " - Channel: " + channel + " - bend: " + value);
      }
    }

    break;

    case (byte)0xB0://controller change
    for (int i = 0; i<touches.length; i++) {
      if (touches[i].channel==channel) {
        touches[i].controllerChange = value;
        println("ControllerChange: " + i + " - Channel: " + channel + " - value: " + value);
      }
    }

    break;

  default:
    break;
  }
}

// handles the note indexes based on the size of the seaboard
int noteArrayIndex( int n )
{
  int idx = 0;

  if ((n >= 0 && n < startNote) || n > startNote+numNotes-1 || n < 0) 
  {
    println("index Zeroed"); 
    idx = 0;
  } else
  { 
    idx = n - startNote;
  }

  if (!(idx < numNotes && idx >= 0)) 
    println("INDEX OUT OF BOUNDS " + idx);

  return idx;
}
