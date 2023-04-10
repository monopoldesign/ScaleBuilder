class Scale
{
  int root;
  int octave;
  int scale;
  int scaleMode;
  boolean preserve;
 
  int baseNote;
  int newScale;
  IntList curScale;

  char noteNames[] = {'C', 'c', 'D', 'd', 'E', 'F', 'f', 'G', 'g', 'A', 'a', 'H'};

  Scale(int _root, int _octave, int _scale, int _scaleMode, boolean _preserve)
  {
    root = _root;
    octave = _octave;
    scale = _scale;
    scaleMode = _scaleMode - 1;
    preserve = _preserve;

    curScale = new IntList();
    buildScale();
  }

  int getBase()
  {
    return baseNote;
  }

  void setRoot(int _root)
  {
    root = _root;
  }

  void setOctave(int _octave)
  {
    octave = _octave;
  }

  void setScale(int _scale)
  {
    scale = _scale;
  }

  void setMode(int _mode)
  {
    scaleMode = _mode;
  }

  void setPreserve(boolean _preserve)
  {
    preserve = _preserve;
  }

  int getNote(int pos)
  {
    return (curScale.get(pos));
  }

  int getScaleSize()
  {
    return (curScale.size());
  }

  void buildScale()
  {
    newScale = scales[scale];

    if (scaleMode != 0)
    {
      if (preserve)
      {
        if (curScale.size() > 0)
          curScale.clear();
      
        for (int i = 0; i < 12; i++)
        {
          if (bitRead(newScale, i) == 1)
            curScale.append(i);
        }
      
        baseNote = root + curScale.get(scaleMode);
      }
      else
        baseNote = root;
      
      for (int i = 0; i < scaleMode; i++)
      {
        newScale = rotate(newScale);
       
        while (bitRead(newScale, 0) == 0)
          newScale = rotate(newScale);
      }

      if (curScale.size() > 0)
        curScale.clear();
      
      for (int i = 0; i < 12; i++)
      {
        if (bitRead(newScale, i) == 1)
          curScale.append(i);
      }
    }
    else
    {
      if (curScale.size() > 0)
        curScale.clear();
      
      baseNote = root;

      for (int i = 0; i < 12; i++)
      {
        if (bitRead(newScale, i) == 1)
          curScale.append(i);
      }
    }
  }

  int rotate(int _scale)
  {
    int nScale;

    if (bitRead(_scale, 0) == 1)
    {
      nScale = (_scale >> 1) & 0xfff;
      nScale = bitSet(nScale, 11);
    }
    else
      nScale = (_scale >> 1) & 0xfff;

    return nScale;
  }

  int bitRead(int b, int n)
  {
    return (b / int(pow(2, n)) % 2);
  }

  int bitSet (int b, int n)
  {
    return (b | (1 << n));
  }

  void show()
  {
    // Modify UI
    Mode.setLimits(1, curScale.size());
    Mode.setNbrTicks(curScale.size());
    ScaleNo.setText(nfs(newScale, 4));

    print("Scale: ");

    for (int i = 0; i < curScale.size(); i++)
    {
      print((octave * 12) + baseNote + curScale.get(i));
      if (i < curScale.size() - 1)
        print(", ");
      else
        println();
    }
  }

  void drawCircle()
  {
    int xm = 208 + 95;              // middle x
    int ym = 8 + 110;              // middle y
    int r = 60;                // radius
    int div = curScale.size();  // Number of Notes
    int angle = 0;              // Start-Angle (Top)
    int pos;

    noFill();
    circle(xm, ym, 2 * r);

    // Note-Circle
    for (int i = 0; i < curScale.size(); i++)
    {
      // sin/cos
      float theta = angle * PI / 180.0;
      float xf = - sin(theta);
      float yf = - cos(theta);

      // Circle-Position
      float x = xm + (r * xf);
      float y = ym + (r * yf);

      // draw Note-Position
      if (i == 0)
        pos = i;
      else
        pos = curScale.size() - i;

      if (pos == playPos || (playPos == -1 && i == 0))
      {
        fill(0);
        circle(x, y, 10);
      }
      else
      {
        fill(230);
        circle(x, y, 10);
        noFill();
        circle(x, y, 10);
      }

      // Note-Text-Position
      x = (xm - 8) + ((r + 22) * xf);
      y = (ym + 10) + ((r + 27) * yf);

      pos = (baseNote + curScale.get(pos)) % 12;
      textSize(28);
      fill(0);
      text(noteNames[pos], x, y);

      angle += 360 / div;
    }
  }
}
