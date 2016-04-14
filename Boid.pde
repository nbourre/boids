class Boid {
  PVector location;
  PVector velocity;
  PVector acceleration;
  
  float r; // Rayon du boid
  
  float topSpeed; // Vitesse maximum
  float topSteer; // Braquage maximum
  
  float cohesionRadius;
  float separationRadius;
  float alignmentRadius;
  
  float separationWeight;
  float cohesionWeight;
  float alignmentWeight;
  
  
  PVector size; 
  float mass = 1;
  
  PVector separation;
  PVector cohesion;
  PVector alignment;
  
  color c;
  
  Boolean debug;
  
  Boid () {
    
    this.location = new PVector (random (width), random (height));    
    
    float angle = random(TWO_PI);
    this.velocity = new PVector(cos(angle), sin(angle));
    
    initDefautValues();
  }
  
  Boid (PVector loc) {
    this.location = loc;
    this.velocity = new PVector (0, 0);
    
    initDefautValues();
  }
  
  Boid (PVector loc, PVector vel) {
    this.location = loc;
    this.velocity = vel;
    
    initDefautValues();
  }
  
  Boid (float m, float x, float y) {
    mass = m;
    location = new PVector (x, y);
    
    velocity = new PVector(0, 0);
    
    initDefautValues();
  }
  
  Boid (float x, float y) {
    acceleration = new PVector (0, 0);
    float angle = random (TWO_PI);
    velocity = new PVector (cos(angle), sin(angle));
    
    location = new PVector (x, y);
    
    r = 2.0;
    topSpeed = 2;
    topSteer = 0.03;
  }
  
  private void initDefautValues() {
    cohesionRadius = 50;
    separationRadius = 25;
    alignmentRadius = 50;
    
    cohesionWeight = 1;
    separationWeight = 1.5;
    alignmentWeight = 1;
    
    r = 2;
    
    topSpeed = 2;
    topSteer = .03;
    
    this.acceleration = new PVector (0 , 0);
    this.size = new PVector (16, 16);
    
    this.c = color(127, 127, 127, 127);
    
    debug = true;
  }
  
  void run (ArrayList <Boid> boids) {
    flock(boids);
    update();
    checkEdges();
  }  
  
  void applyForce (PVector force) {
    PVector f;
    
    if (mass != 1)
      f = PVector.div (force, mass);
    else
      f = force;
   
    this.acceleration.add(f);
  }
  
  void flock(ArrayList <Boid> boids) {
    PVector sep = separate(boids);
    PVector ali = align(boids);
    PVector coh = cohesion(boids);
    
    // Pondérer chacune des forces
    sep.mult (separationWeight);
    ali.mult (alignmentWeight);
    coh.mult (cohesionWeight);
    
    // Ajouter chacune des forces
    applyForce (sep);
    applyForce (ali);
    applyForce (coh);
    
    if (debug) {
      this.separation = sep;
      this.cohesion = coh;
      this.alignment = ali;
    }
  }
  
  void update () {
    velocity.add (acceleration);
    velocity.limit(topSpeed);
    
    location.add (velocity);

    acceleration.mult (0);
  }

  // Méthode qui calcule et applique une force de rotation vers une cible
  // STEER = CIBLE moins VITESSE
  PVector seek (PVector target) {
    // Vecteur différentiel vers la cible
    PVector desired = PVector.sub (target, this.location);
    
    // VITESSE MAXIMALE VERS LA CIBLE
    desired.setMag(topSpeed);
    
    // Braquage
    PVector steer = PVector.sub (desired, velocity);
    steer.limit(topSteer);
    
    return steer;    
  }
  
  
  void render () {
    stroke (0);
    fill (c);
    
    float theta = velocity.heading2D() + radians(90);
    
    pushMatrix();
    translate(location.x, location.y);
    rotate (theta);
    
    beginShape(TRIANGLES);
    vertex(0, -r * 2);
    vertex(-r, r * 2);
    vertex(r, r * 2);
    
    endShape();
    
    popMatrix();
    
    if (debug) {
      renderDebug();
    }
  }
  
  void checkEdges() {
    if (location.x < -r) location.x = width + r;
    if (location.y < -r) location.y = height + r;
    if (location.x > width + r) location.x = -r;
    if (location.y > height + r) location.y = -r;
  }
  
  
  Rectangle getRectangle() {
    Rectangle r = new Rectangle(location.x, location.y, size.x, size.y);
    
    return r;
  }
  
  void setXY(int x, int y) {
    this.location.x = x;
    this.location.y = y;
  }
  
  // REGARDE LES AGENTS DANS LE VOISINAGE ET CALCULE UNE FORCE DE RÉPULSION
  PVector separate (ArrayList<Boid> boids) {
    PVector steer = new PVector(0, 0, 0);
    
    int count = 0;
    
    for (Boid other : boids) {
      float d = PVector.dist (this.location, other.location);
      
      if ((d > 0) && (d < separationRadius)) {
        // Calculer le vecteur qui pointe contre le voisin
        PVector diff = PVector.sub (this.location, other.location);
        
        diff.normalize();
        diff.div(d);
        
        steer.add(diff);
        count++;
      }
    }
      
    if (count > 0) {
      steer.div((float)count);
    }
    
    if (steer.mag() > 0) {
      steer.setMag(topSpeed);
      steer.sub(velocity);
      steer.limit(topSteer);
    }
    
    
    return steer;
  }
  
  // ALIGNEMENT DE L'AGENTS AVEC LE RESTANT DU GROUPE
  // MOYENNE DE VITESSE AVEC TOUS LES AGENTS DANS LE VOISINAGE
  PVector align (ArrayList<Boid> boids) {
    PVector sum = new PVector(0, 0);
    
    int count = 0;
    
    for (Boid other : boids) {
      float d = PVector.dist (this.location, other.location);
      
      if (d > 0 && d < alignmentRadius) {
        sum.add (other.velocity);
        count++;
      }
    }
    
    if (count > 0) {
      sum.div((float)count);
      sum.setMag(topSpeed);
      
      PVector steer = PVector.sub (sum, this.velocity);
      steer.limit (topSteer);
      
      return steer;
    }
    else {
      return new PVector(0, 0);
    }
  }
  
  // REGARDE LE GROUPE ET 
  PVector cohesion(ArrayList<Boid> boids) {
    PVector sum = new PVector(0, 0);
    
    int count = 0;
    
    for (Boid other : boids) {
      float d = PVector.dist(this.location, other.location);
      if (d > 0 && d < cohesionRadius) {
        sum.add(other.location);
        count++;
      }
    }
    
    if (count > 0) {
      sum.div(count);
      return seek(sum);
    
    }
    else {
      return new PVector(0, 0);
    }
  }
  
 
  void setColor (color c) {
    this.c = c;
  }
  
  void renderDebug() {
    //textByLine ("Sep : " + pvectorToString(separation), 1);
    //textByLine ("Coh : " + pvectorToString(cohesion), 2);
    //textByLine ("Ali : " + pvectorToString(alignment), 3);
    
    noFill();
    stroke(200, 0, 0);
    ellipse(location.x, location.y, cohesionRadius, cohesionRadius);
  }
  
  void textByLine (String msg, int line) {
    int tPoint = 16;
    textSize(tPoint);
    fill (0);
    text (msg, 10, 15 + ((line - 1) * tPoint));
  }
  
  String pvectorToString(PVector v) {
    if (v != null)
      return "(" + v.x + ", " + v.y + ")";
    return "null";
  }
  
}