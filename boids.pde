int nbBoids = 200;

Flock flock;
Boolean debug = false;

void setup () {
  //size (600, 360);
  fullScreen(0);
  flock = new Flock();
  
  for (int i = 0; i < nbBoids; i++) {
    Boid b = new Boid();
    
    if (i % 2 == 0) {
      b.setXY (width / 2, height / 2);
    }
    
    flock.addBoid(b);
  }  
}



void update() {
  flock.run();
  
  if (mousePressed) {
    Boid b = new Boid();
    b.setXY (mouseX, mouseY);
    b.setColor (color(255, 0, 0, 255));
    flock.addBoid(b);
    
  }
  
  //saveFrame("frames/####.png");
}

void render () {
  background (255);
  
  flock.render();

}



void draw () {
  update();
  render();

}

void keyPressed() {
  if (key == '+') {
  }
  
  if (key == 'd') {
    flock.debug = !flock.debug;
    println("test");
  }
}