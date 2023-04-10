// Need G4P library
import g4p_controls.*;
import beads.*;

Scale myScale;
int scales[] = {4095, 2741, 1453, 2477, 2733, 2509, 2483, 1365, 661, 425, 1257}; 
AudioContext ac;
boolean isPlaying = false;
int playPos = -1;

public void setup()
{
  size(408, 270, JAVA2D);
  createGUI();
  customGUI();
  // Place your setup code here

  myScale = new Scale(0, 1, 1, 1, true);

  Scale.setSelected(myScale.scale);  
  preserve.setSelected(myScale.preserve);
  ScaleNo.setText(nfs(myScale.newScale, 4));

  myScale.show();

  frameRate(200);
  ac = AudioContext.getDefaultContext();

  Clock clock = new Clock(250);
  clock.addMessageListener(
    //this is the on-the-fly bead
    new Bead()
    {
        //this is the method that we override to make the Bead do something
        public void messageReceived(Bead message)
        {
            Clock c = (Clock)message;
            if(c.isBeat())
            {
              playPos++;

              if (playPos >= myScale.getScaleSize())
                playPos = 0;

              int note = myScale.getBase() + myScale.getNote(playPos);
              float freq = Pitch.mtof(((Octave.getValueI() + 3) * 12) + note);

              WavePlayer wp = new WavePlayer(ac, freq, Buffer.TRIANGLE);
              Envelope ge = new Envelope(ac, 0);
              Gain g = new Gain(ac, 1, ge);
              g.addInput(wp);

              /* Delay implementation (No proper feedback ?)
              TapIn delayIn = new TapIn(ac, 1000);
              delayIn.addInput(g);

              TapOut delayOut = new TapOut(ac, delayIn, 500.0);
              Gain delayGain = new Gain(ac, 1, 0.5);
              delayGain.addInput(delayOut);

              ac.out.addInput(delayGain);
              */

              ac.out.addInput(g);

              ge.addSegment(0.1, 5);
              ge.addSegment(0, 100, new KillTrigger(g));
            }
        }
    });
    ac.out.addDependent(clock);
}

public void draw(){
  background(230);
  drawFrame(8, 8, 190, 220);
  drawFrame(208, 8, 190, 220);
  myScale.drawCircle();
}

// Use this method to add additional statements
// to customise the GUI controls
public void customGUI(){

}

public void drawFrame(int x, int y, int w, int h)
{
  // white rectangle
  stroke(255);
  noFill();
  rect(x, y, w, h);

  // black bevels
  stroke(0);
  line(x, y, w + x, y);
  line(x, y, x, h + y);
}
