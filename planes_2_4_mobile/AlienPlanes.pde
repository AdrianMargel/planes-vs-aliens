class BotPlane extends Plane{
  BotPlane(Vector p,float a){
    super(p,a);
    //bot
    thrustLimit=0.3;
    thrustRecover=5;
    thrustPotential=5;
    thrustPotLim=5;
    
    agilityMin=0.02;
    agilityMax=0.04;
    agilityFall=0.1;
    
    resistanceMin=0.98;
    resistanceMax=0.98;
    fallResistance=0.9995;
    transfer=0.08;
    
    cooldown=0;
    cooldownMax=40;
    bulletSpeed=20;
    
    minSpeed=5;//min speed for lift
    maxSpeed=20;//speed for max efficiency
    
    maxHealth=3;
    
    gravity=0.07;
    
    health=maxHealth;
  }
  @Override
  public void display(Cam c){
    pushMatrix();
    translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom);
    rotate(angle);
    scale(c.zoom,c.zoom);
    if(cos(angle)<0)
      scale(1.0, -1.0);
    image(plane2,-88*1.5/3,-31*1.5/2,88*1.5,31*1.5);
    popMatrix();
  }
}
class Alien extends Plane{
  float thrustMax;
  float agility;
  float resistance;
  Vector moveTarget;
  Alien(Vector p,float a){
    super(p,a);
    //bot
    thrustMax=1;
    agility=0.05;
    resistance=0.95;
    
    cooldown=0;
    cooldownMax=40;
    bulletSpeed=20;
    
    maxHealth=3;
    health=maxHealth;
  }
  public void move(Vector toMove){
    Vector accel=new Vector(toMove);
    accel.subVec(pos);
    accel.limVec(thrustMax);
    velo.addVec(accel);
  }
  public void move(Vector toMove,float maxSpeed){
    Vector accel=new Vector(toMove);
    accel.subVec(pos);
    accel.limVec(thrustMax);
    accel.limVec(maxSpeed);
    velo.addVec(accel);
  }
  public void face(Vector target){
    Vector posDif=getPos();
    posDif.subVec(target);
    face(posDif.getAng());
  }
  public void face(float tarAngle){
    float agile=agility;
    float angDiff=nrm2Ang(tarAngle-getAngle()+PI);
    //println(posDif.getAng()-p1.getAngle());
    if(angDiff<-agile){
      angle-=agile;
    }else if(angDiff>agile){
      angle+=agile;
    }else{
      angle=tarAngle+PI;
    }
  }
  @Override
  public void shoot(ArrayList<Bullet> bs){
    if(cooldown==0){
      float ra=random(-0.2,0.2);
      float s=-bulletSpeed;
      Vector pVelo=new Vector(cos(angle+PI+ra)*s,sin(angle+PI+ra)*s);
      pVelo.addVec(velo);
      Vector pPos=new Vector(cos(angle)*35*1.5/3*2,sin(angle)*35*1.5/3*2);
      pPos.addVec(pos);
      bs.add(new Plasma(pPos,pVelo,40));
      cooldown=cooldownMax;
    }
  }
  @Override
  public void run(ArrayList<Particle> ps){
    velo.sclVec(resistance);
    pos.addVec(velo);
    if(cooldown>0){
      cooldown--;
    }
  }
  @Override
  public boolean hit(Bullet toHit,boolean exaggerate){
    if(exaggerate){
      if(overlaps2(toHit.getPos())){
        health--;
        return true;
      }
    }else{
      if(overlaps(toHit.getPos())){
        health--;
        return true;
      }
    }
    return false;
  }
  @Override
  public boolean overlaps(Vector target){
    return overlaps2(target);
  }
  @Override
  public boolean overlaps2(Vector target){
    float exaggeration=20;
    Vector toTest=new Vector(target);
    toTest.subVec(pos);
    toTest.rotVec(-angle);
    float hitboxX=41*1.5/2+exaggeration;
    float hitboxY=35*1.5/2+exaggeration;
    toTest.addVec(new Vector(hitboxX,hitboxY));
    float hitboxWide=41*1.5+exaggeration*2;
    float hitboxHigh=35*1.5+exaggeration*2;
    return toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh;
  }
  @Override
  public void display(Cam c){
    pushMatrix();
    translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom);
    rotate(angle);
    scale(c.zoom,c.zoom);
    if(cos(angle)<0)
      scale(1.0, -1.0);
    image(dart,-41*1.5/2,-35*1.5/2,41*1.5,35*1.5);
    popMatrix();
  }
}
class Dart extends Alien{
  Dart(Vector p,float a){
    super(p,a);
    thrustMax=0.22;
    agility=0.05;
    resistance=0.99;
    
    maxHealth=3;
    health=maxHealth;
  }
}
class Archer extends Alien{
  Archer(Vector p,float a){
    super(p,a);
    thrustMax=0.2;
    agility=0.02;
    resistance=0.95;
    
    cooldown=0;
    cooldownMax=20;
    bulletSpeed=40;
    
    maxHealth=3;
    health=maxHealth;
  }
  @Override
  public boolean overlaps2(Vector target){
    float exaggeration=30;
    Vector toTest=new Vector(target);
    toTest.subVec(pos);
    toTest.rotVec(-angle);
    float hitboxX=78*1.5/2+exaggeration;
    float hitboxY=86*1.5/2+exaggeration;
    toTest.addVec(new Vector(hitboxX,hitboxY));
    float hitboxWide=50*1.5+exaggeration*2;
    float hitboxHigh=86*1.5+exaggeration*2;
    return toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh;
  }
  @Override
  public void shoot(ArrayList<Bullet> bs){
    if(cooldown==0){
      float ra=random(-0.01,0.01);
      float s=-bulletSpeed;
      Vector pVelo=new Vector(cos(angle+PI+ra)*s,sin(angle+PI+ra)*s);
      pVelo.addVec(velo);
      Vector pPos=new Vector(cos(angle)*78*1.5/3*2,sin(angle)*78*1.5/3*2);
      pPos.addVec(pos);
      bs.add(new Plasma(pPos,pVelo,60));
      cooldown=cooldownMax;
    }
  }
  @Override
  public void display(Cam c){
    pushMatrix();
    translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom);
    rotate(angle);
    scale(c.zoom,c.zoom);
    if(cos(angle)<0)
      scale(1.0, -1.0);
    image(archer,-78*1.5/2,-86*1.5/2,78*1.5,86*1.5);
    popMatrix();
  }
}

class ShotGunner extends Alien{
  int mutliShot;
  ShotGunner(Vector p,float a){
    super(p,a);
    thrustMax=0.4;
    agility=0.04;
    resistance=0.95;
    
    cooldown=0;
    cooldownMax=80;
    bulletSpeed=40;
    
    maxHealth=2;
    health=maxHealth;
    mutliShot=4;
  }
  @Override
  public void shoot(ArrayList<Bullet> bs){
    if(cooldown==0){
      for(int i=0;i<mutliShot;i++){
        float ra=random(-0.4,0.4);
        float s=-bulletSpeed*random(0.8,1);
        Vector pVelo=new Vector(cos(angle+PI+ra)*s,sin(angle+PI+ra)*s);
        pVelo.addVec(velo);
        Vector pPos=new Vector(cos(angle)*30*1.5/3*2,sin(angle)*30*1.5/3*2);
        pPos.addVec(pos);
        bs.add(new Plasma(pPos,pVelo,(int)random(10,15)));
        cooldown=cooldownMax;
      }
    }
  }
  @Override
  public boolean overlaps2(Vector target){
    float exaggeration=20;
    Vector toTest=new Vector(target);
    toTest.subVec(pos);
    toTest.rotVec(-angle);
    float hitboxX=50*1.5+exaggeration;
    float hitboxY=39*1.5/2+exaggeration;
    toTest.addVec(new Vector(hitboxX,hitboxY));
    float hitboxWide=82*1.5+exaggeration*2;
    float hitboxHigh=39*1.5+exaggeration*2;
    return toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh;
  }
  @Override
  public void display(Cam c){
    pushMatrix();
    translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom);
    rotate(angle);
    scale(c.zoom,c.zoom);
    if(cos(angle)<0)
      scale(1.0, -1.0);
    image(shotGunner,-50*1.5,-39*1.5/2,82*1.5,39*1.5);
    popMatrix();
  }
}
class Swarmer extends Alien{
  Bullet bullet;
  Swarmer(Vector p,float a){
    super(p,a);
    thrustMax=6;
    agility=0.03;
    resistance=0.8;
    
    cooldown=0;
    cooldownMax=20;
    bulletSpeed=2;
    
    maxHealth=1;
    health=maxHealth;
  }
  @Override
  public void run(ArrayList<Particle> ps){
    velo.sclVec(resistance);
    pos.addVec(velo);
    if(bullet!=null){
      if(bullet.isAlive()){
        bullet.setPos(getPos());
      }else{
        bullet=null;
      }
    }
    if(cooldown>0){
      cooldown--;
    }
  }
  @Override
  public void shoot(ArrayList<Bullet> bs){
    if(cooldown==0){
      float ra=0;
      float s=-bulletSpeed;
      //Vector pVelo=new Vector(angle+PI/2+ra,s,true);
      //Vector pVelo2=new Vector(angle-PI/2+ra,s,true);
      //pVelo.addVec(velo);
      //pVelo2.addVec(velo);
      Vector pVelo=new Vector(0,0);
      pVelo.sclVec(0.8);
      Vector pPos=new Vector(0,0);
      pPos.addVec(pos);
      //bs.add(new PlasmaLight(pPos,pVelo,15));
      //bs.add(new PlasmaLight(pPos,pVelo2,15));
      bullet=new PlasmaLight(pPos,pVelo,21);
      bs.add(bullet);
      cooldown=cooldownMax;
    }
  }
  @Override
  public boolean overlaps2(Vector target){
    float exaggeration=20;
    Vector toTest=new Vector(target);
    toTest.subVec(pos);
    toTest.rotVec(-angle);
    float hitboxX=20*1.5+exaggeration;
    float hitboxY=17*1.5/2+exaggeration;
    toTest.addVec(new Vector(hitboxX,hitboxY));
    float hitboxWide=30*1.5+exaggeration*2;
    float hitboxHigh=17*1.5+exaggeration*2;
    return toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh;
  }
  @Override
  public void display(Cam c){
    pushMatrix();
    translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom);
    rotate(angle);
    scale(c.zoom,c.zoom);
    if(cos(angle)<0)
      scale(1.0, -1.0);
    image(swarmer,-20*1.5,-17*1.5/2,30*1.5,17*1.5);
    popMatrix();
  }
}

class Bug extends Alien{
  Bug(Vector p,float a){
    super(p,a);
    thrustMax=1;
    agility=0.01;
    resistance=0.95;
    
    maxHealth=1;
    health=maxHealth;
  }
  @Override
  public void shoot(ArrayList<Bullet> bs){
  }
  @Override
  public boolean overlaps2(Vector target){
    float exaggeration=20;
    Vector toTest=new Vector(target);
    toTest.subVec(pos);
    toTest.rotVec(-angle);
    float hitboxX=35*1.5/2+exaggeration;
    float hitboxY=22*1.5/2+exaggeration;
    toTest.addVec(new Vector(hitboxX,hitboxY));
    float hitboxWide=35*1.5+exaggeration*2;
    float hitboxHigh=22*1.5+exaggeration*2;
    return toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh;
  }
  @Override
  public void display(Cam c){
    pushMatrix();
    translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom);
    rotate(angle);
    scale(c.zoom,c.zoom);
    if(cos(angle)<0)
      scale(1.0, -1.0);
    image(bug,-35*1.5/2,-22*1.5/2,35*1.5,22*1.5);
    popMatrix();
  }
}
class Mine extends Alien{
  Mine(Vector p,float a){
    super(p,a);
    thrustMax=0.2;
    agility=0;
    resistance=0.95;
    
    cooldown=0;
    cooldownMax=0;
    bulletSpeed=10;
    
    maxHealth=1;
    health=maxHealth;
  }
  @Override
  public void run(ArrayList<Particle> ps){
    velo.sclVec(resistance);
    pos.addVec(velo);
    if(cooldown>0){
      cooldown--;
    }
    angle+=0.02;
  }
  @Override
  public void shoot(ArrayList<Bullet> bs){
    health=0;
    for(int i=0;i<10;i++){
      float a=i*TWO_PI/10+random(-0.2,0.2);
      float s=-bulletSpeed*random(0.8,1);
      Vector pVelo=new Vector(a,s,true);
      pVelo.addVec(velo);
      Vector pPos=new Vector(0,0);
      pPos.addVec(pos);
      bs.add(new Plasma(pPos,pVelo,(int)random(10,25)));
      cooldown=cooldownMax;
    }
  }
  @Override
  public boolean overlaps2(Vector target){
    float exaggeration=30;
    Vector toTest=new Vector(target);
    toTest.subVec(pos);
    toTest.rotVec(-angle);
    float hitboxX=17*1.5/2+exaggeration;
    float hitboxY=17*1.5/2+exaggeration;
    toTest.addVec(new Vector(hitboxX,hitboxY));
    float hitboxWide=17*1.5+exaggeration*2;
    float hitboxHigh=17*1.5+exaggeration*2;
    return toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh;
  }
  @Override
  public void display(Cam c){
    pushMatrix();
    translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom);
    rotate(angle);
    scale(c.zoom,c.zoom);
    if(cos(angle)<0)
      scale(1.0, -1.0);
    image(mine,-17*1.5/2,-17*1.5/2,17*1.5,17*1.5);
    popMatrix();
  }
}

class Gunner extends Alien{
  Gunner(Vector p,float a){
    super(p,a);
    thrustMax=0.8;
    agility=0.05;
    resistance=0.95;
    
    cooldown=0;
    cooldownMax=30;
    bulletSpeed=15;
    
    maxHealth=2;
    health=maxHealth;
  }
  @Override
  public boolean overlaps2(Vector target){
    float exaggeration=20;
    Vector toTest=new Vector(target);
    toTest.subVec(pos);
    toTest.rotVec(-angle);
    float hitboxX=57*1.5/2+exaggeration;
    float hitboxY=31*1.5/2+exaggeration;
    toTest.addVec(new Vector(hitboxX,hitboxY));
    float hitboxWide=57*1.5+exaggeration*2;
    float hitboxHigh=31*1.5+exaggeration*2;
    return toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh;
  }
  @Override
  public void shoot(ArrayList<Bullet> bs){
    if(cooldown==0){
      float ra=random(-0.2,0.2);
      float s=-bulletSpeed;
      Vector pVelo=new Vector(cos(angle+PI+ra)*s,sin(angle+PI+ra)*s);
      pVelo.addVec(velo);
      Vector pPos=new Vector(57*1.5/2,4*1.5);
      if(cos(angle)<0)
        pPos.y*=-1;
      pPos.rotVec(angle);
      pPos.addVec(pos);
      bs.add(new Plasma(pPos,pVelo,60));
      cooldown=cooldownMax;
    }
  }
  @Override
  public void display(Cam c){
    pushMatrix();
    translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom);
    rotate(angle);
    scale(c.zoom,c.zoom);
    if(cos(angle)<0)
      scale(1.0, -1.0);
    image(gunner,-57*1.5/2,-31*1.5/2,57*1.5,31*1.5);
    popMatrix();
  }
}

class HeavyGunner extends Alien{
  HeavyGunner(Vector p,float a){
    super(p,a);
    thrustMax=0.6;
    agility=0.05;
    resistance=0.95;
    
    cooldown=0;
    cooldownMax=20;
    bulletSpeed=20;
    
    maxHealth=4;
    health=maxHealth;
  }
  @Override
  public boolean overlaps2(Vector target){
    float exaggeration=20;
    Vector toTest=new Vector(target);
    toTest.subVec(pos);
    toTest.rotVec(-angle);
    float hitboxX=88*1.5/2+10*1.5+exaggeration;
    float hitboxY=32*1.5/2+exaggeration;
    toTest.addVec(new Vector(hitboxX,hitboxY));
    float hitboxWide=88*1.5+exaggeration*2;
    float hitboxHigh=32*1.5+exaggeration*2;
    return toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh;
  }
  @Override
  public void display(Cam c){
    pushMatrix();
    translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom);
    rotate(angle);
    scale(c.zoom,c.zoom);
    if(cos(angle)<0)
      scale(1.0, -1.0);
    image(heavyGunner,-88*1.5/2-10*1.5,-32*1.5/2,88*1.5,32*1.5);
    popMatrix();
  }
}

class Shield extends Alien{
  Shield(Vector p,float a){
    super(p,a);
    thrustMax=0.2;
    agility=0.01;
    resistance=0.95;
    
    cooldown=0;
    cooldownMax=0;
    bulletSpeed=0;
    
    maxHealth=12;
    health=maxHealth;
  }
  @Override
  public boolean hit(Bullet toHit,boolean exaggerate){
    if(overlaps2(toHit.getPos())){
      health--;
      return true;
    }
    if(overlapsBack(toHit.getPos())){
      health-=3;
      return true;
    }
    return false;
  }
  @Override
  public boolean overlaps2(Vector target){
    float exaggeration=20;
    Vector toTest=new Vector(target);
    toTest.subVec(pos);
    toTest.rotVec(-angle);
    float hitboxX=0+exaggeration;
    float hitboxY=102*1.5/2+exaggeration;
    toTest.addVec(new Vector(hitboxX,hitboxY));
    float hitboxWide=30*1.5+exaggeration*2;
    float hitboxHigh=102*1.5+exaggeration*2;
    return toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh;
  }
  public boolean overlapsBack(Vector target){
    float exaggeration=10;
    Vector toTest=new Vector(target);
    toTest.subVec(pos);
    toTest.rotVec(-angle);
    float hitboxX=30*1.5+exaggeration;
    float hitboxY=90*1.5/2+exaggeration;
    toTest.addVec(new Vector(hitboxX,hitboxY));
    float hitboxWide=30*1.5+exaggeration*2;
    float hitboxHigh=90*1.5+exaggeration*2;
    return toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh;
  }
  @Override
  public void shoot(ArrayList<Bullet> bs){
  }
  @Override
  public void display(Cam c){
    pushMatrix();
    translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom);
    rotate(angle);
    scale(c.zoom,c.zoom);
    if(cos(angle)<0)
      scale(1.0, -1.0);
    image(shield,-57*1.5/2,-102*1.5/2,57*1.5,102*1.5);
    popMatrix();
  }
}
class FlagShip extends Alien{
  FlagShip(Vector p){
    super(p,0);
    thrustMax=0.1;
    agility=0;
    resistance=0.8;
    
    cooldown=0;
    cooldownMax=0;
    bulletSpeed=0;
    
    maxHealth=80;
    health=maxHealth;
  }
  @Override
  public void shoot(ArrayList<Bullet> bs){
  }
  @Override
  public boolean overlaps2(Vector target){
    {
      float exaggeration=10;
      Vector toTest=new Vector(target);
      toTest.subVec(pos);
      toTest.rotVec(-angle);
      float hitboxX=267*1.5/2+exaggeration;
      float hitboxY=187*1.5/2+exaggeration;
      toTest.addVec(new Vector(hitboxX,hitboxY));
      float hitboxWide=267*1.5+exaggeration*2;
      float hitboxHigh=120*1.5+exaggeration*2;
      if(toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh)
        return true;
    }
    {
      float exaggeration=20;
      Vector toTest=new Vector(target);
      toTest.subVec(pos);
      toTest.rotVec(-angle);
      float hitboxX=64*1.5/2+exaggeration;
      float hitboxY=187*1.5/2+exaggeration;
      toTest.addVec(new Vector(hitboxX,hitboxY));
      float hitboxWide=64*1.5+exaggeration*2;
      float hitboxHigh=187*1.5+exaggeration*2;
      if(toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh)
        return true;
    }
    return false;
  }
  @Override
  public void display(Cam c){
    pushMatrix();
    translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom);
    rotate(angle);
    scale(c.zoom,c.zoom);
    if(cos(angle)<0)
      scale(1.0, -1.0);
    image(flagShip,-267*1.5/2,-187*1.5/2,267*1.5,187*1.5);
    popMatrix();
  }
}
