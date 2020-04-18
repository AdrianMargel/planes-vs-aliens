public class Plane{
  Vector pos;
  Vector velo;
  float angle;
  float thrust;
  
  int turnRequest=0;
  
  float thrustLimit;
  float thrustRecover;
  float thrustPotential;
  float thrustPotLim;
  
  float agilityMin;
  float agilityMax;
  float agilityFall;
  
  float resistanceMin;
  float resistanceMax;
  float fallResistance;
  float transfer;
  
  int cooldown;
  int cooldownMax;
  float bulletSpeed;
  
  float minSpeed;//min speed for lift
  float maxSpeed;//speed for max efficiency
  
  int maxHealth;
  int health;
  
  float gravity;
  
  float ceilingStart;//how high before the plane starts losing thrust
  float ceilingEnd;//how high before the plane has no thrust
  
  //private int PCD=0;
  //private int PCDM=3;
  
  public Plane(Vector p,float a){
    //player
    thrustLimit=1;
    thrustRecover=0.25;
    thrustPotential=15;
    thrustPotLim=15;
    
    agilityMin=0.04;
    agilityMax=0.08;
    agilityFall=0.08;
    
    resistanceMin=0.9995;
    resistanceMax=0.995;
    fallResistance=0.9995;
    transfer=0.15;
    
    cooldown=0;
    cooldownMax=10;
    bulletSpeed=50;
    
    minSpeed=5;//min speed for lift
    maxSpeed=40;//speed for max efficiency
    
    maxHealth=20;
    
    gravity=0.1;
    
    health=maxHealth;
    pos=new Vector(p);
    velo=new Vector(0,0);
    angle=a;
    
    ceilingStart=2000;
    ceilingEnd=6000;
  }
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
  public boolean overlaps(Vector target){
    Vector toTest=new Vector(target);
    toTest.subVec(pos);
    toTest.rotVec(-angle);
    float hitboxX=88*1.5/3;
    float hitboxY=31*1.5/2;
    toTest.addVec(new Vector(hitboxX,hitboxY));
    float hitboxWide=88*1.5;
    float hitboxHigh=31*1.5;
    return toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh;
  }
  public boolean overlaps2(Vector target){
    float exaggeration=30;
    Vector toTest=new Vector(target);
    toTest.subVec(pos);
    toTest.rotVec(-angle);
    float hitboxX=88*1.5/3+exaggeration;
    float hitboxY=31*1.5/2+exaggeration;
    toTest.addVec(new Vector(hitboxX,hitboxY));
    float hitboxWide=88*1.5+exaggeration*2;
    float hitboxHigh=31*1.5+exaggeration*2;
    return toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh;
  }
  public void run(ArrayList<Particle> ps){
    float t=thrust*5;
    if(t>0&&t<1){
      t+=random(0,1);
    }
    float pSpeed=1;
    for(int i=0;i<(int)t;i++){
    //if(t>0&&PCD==0){
      float ra=random(-0.1,0.1);
      float rs=random(-1,1);
      Vector pVelo=new Vector(cos(angle+PI+ra)*(pSpeed+rs),sin(angle+PI+ra)*(pSpeed+rs));
      pVelo.addVec(velo);
      Vector pPos=new Vector(-cos(angle)*88*1.5/3,-sin(angle)*88*1.5/3);
      pPos.addVec(pos);
      ps.add(new Particle(pPos,pVelo,100,10));
      //PCD=PCDM;
    }
    //if(PCD>0){
    //  PCD--;
    //}
    
    velo.addVec(new Vector(cos(angle)*thrust,sin(angle)*thrust));
    thrust=0;
    if(thrustPotential<thrustPotLim){
      thrustPotential+=thrustRecover;
    }
    
    float speedEff=getEfficiency();
    
    velo.y+=gravity;
    velo.sclVec(resistanceMin+(resistanceMax-resistanceMin)*speedEff);
    
    pos.addVec(velo);
    
    float vSpeed=velo.getMag();
    float vAngle=velo.getAng();
    float dotP=cos(angle-vAngle);
    //println(vSpeed);
    
    if(dotP>=0){
      float eff=dotP*transfer*speedEff;
      velo.subVec(new Vector(cos(vAngle)*vSpeed*eff,sin(vAngle)*vSpeed*eff));
      velo.addVec(new Vector(cos(angle)*vSpeed*eff,sin(angle)*vSpeed*eff));
      
      if(turnRequest>0){
        angle+=agilityMin+(agilityMax-agilityMin)*speedEff;
      }else if(turnRequest<0){
        angle-=agilityMin+(agilityMax-agilityMin)*speedEff;
      }
    }else{
      velo.sclVec(fallResistance);
      if(turnRequest>0){
        angle+=agilityFall;
      }else if(turnRequest<0){
        angle-=agilityFall;
      }
    }
    
    /*if(turnRequest>0){
      angle+=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }else if(turnRequest<0){
      angle-=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }*/
    turnRequest=0;
    
    if(cooldown>0){
      cooldown--;
    }
    
    if(pos.y>waterline){
      velo.y-=0.5;
      velo.sclVec(0.97);
      if(sin(angle-vAngle)>=0){
        angle-=0.02;
      }else{
        angle+=0.02;
      }
    }
  }
  public float getAgility(){
    return agilityMin+(agilityMax-agilityMin)*getEfficiency();
  }
  public float getEfficiency(){
    float vSpeed=velo.getMag();
    return max(min((vSpeed-minSpeed)/(maxSpeed-minSpeed),1),0);
  }
  public void turn(boolean isClockwise){
    if(isClockwise){
      turnRequest+=1;
    }else{
      turnRequest-=1;
    }
  }
  public void setTurn(float toAng){
    angle=toAng+PI;
  }
  public void boost(){
    float bPower=min(thrustLimit,thrustPotential);
    bPower*=heightEfficiency();
    thrust+=bPower;
    thrustPotential-=bPower;
  }
  public float heightEfficiency(){
    float alt=-pos.y;
    if(alt>ceilingStart){
      float altScale=max((ceilingEnd-alt)/(ceilingEnd-ceilingStart),0);
      return altScale;
    }
    return 1;
  }
  public void shoot(ArrayList<Bullet> bs){
    if(cooldown==0){
      float ra=random(-0.01,0.01);
      float s=-bulletSpeed;
      Vector pVelo=new Vector(cos(angle+PI+ra)*s,sin(angle+PI+ra)*s);
      pVelo.addVec(velo);
      Vector pPos=new Vector(cos(angle)*88*1.5/3*2,sin(angle)*88*1.5/3*2);
      pPos.addVec(pos);
      bs.add(new Bullet(pPos,pVelo,50));
      cooldown=cooldownMax;
    }
  }
  public Vector getPos(){
    return new Vector(pos);
  }
  public Vector getVelo(){
    return new Vector(velo);
  }
  public float getAngle(){
    return angle;
  }
  public float getHealth(){
    return health;
  }
  public float getHealthPercent(){
    return (float)health/maxHealth;
  }
  public boolean isAlive(){
    return health>0;
  }
  public Vector dispPos(Cam c){
    Vector disp=new Vector(pos);
    disp.subVec(c.pos);
    disp.sclVec(c.zoom);
    return disp;
  }
  public void display(Cam c){
    pushMatrix();
    translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom);
    rotate(angle);
    scale(c.zoom,c.zoom);
    if(cos(angle)<0)
      scale(1.0, -1.0);
    image(plane4,-88*1.5/3,-31*1.5/2,88*1.5,31*1.5);
    popMatrix();
    //stroke(0);
    //fill(255);
    //ellipse(pos.x-c.pos.x,pos.y-c.pos.y,10,10);
    //line(pos.x-c.pos.x,pos.y-c.pos.y,pos.x+cos(angle)*15-c.pos.x,pos.y+sin(angle)*15-c.pos.y);
  }
}

class Bomber extends Plane{
  Bomber(Vector p,float a){
    super(p,a);
    thrustLimit=0.3;
    thrustRecover=0.14;
    thrustPotential=1;
    thrustPotLim=1;
    
    agilityMin=0.02;
    agilityMax=0.04;
    agilityFall=0.08;
    
    ceilingStart=4000;
    ceilingEnd=8000;
    cooldownMax=6;
    bulletSpeed=12;
    
    maxHealth=15;
    health=maxHealth;
    
  }
  @Override
  public boolean hit(Bullet toHit,boolean exaggerate){
    if(overlaps(toHit.getPos())){
      health--;
      return true;
    }
    return false;
  }
  @Override
  public boolean overlaps(Vector target){
    {
      Vector toTest=new Vector(target);
      toTest.subVec(pos);
      toTest.rotVec(-angle);
      float hitboxX=-(-20)*1.5;
      float hitboxY=(60)*1.5/2;
      toTest.addVec(new Vector(hitboxX,hitboxY));
      float hitboxWide=50*1.5;
      float hitboxHigh=60*1.5;
      if(toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh){
        return true;
      }
    }
    {
      Vector toTest=new Vector(target);
      toTest.subVec(pos);
      toTest.rotVec(-angle);
      float hitboxX=-(10)*1.5;
      float hitboxY=(30)*1.5/2;
      toTest.addVec(new Vector(hitboxX,hitboxY));
      float hitboxWide=36*1.5;
      float hitboxHigh=30*1.5;
      return toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh;
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
    image(bomber,-70*1.5/3,-59*1.5/2,70*1.5,59*1.5);
    popMatrix();
    //stroke(0);
    //fill(255);
    //ellipse(pos.x-c.pos.x,pos.y-c.pos.y,10,10);
    //line(pos.x-c.pos.x,pos.y-c.pos.y,pos.x+cos(angle)*15-c.pos.x,pos.y+sin(angle)*15-c.pos.y);
  }
  @Override
  public void shoot(ArrayList<Bullet> bs){
    if(cooldown==0){
      float ra=random(-0.5,0.5);
      float s=bulletSpeed;
      Vector pVelo=new Vector(cos(-PI/2+ra)*s,sin(-PI/2+ra)*s);
      pVelo.addVec(velo);
      Vector pPos=new Vector(0,0);
      pPos.addVec(pos);
      bs.add(new Bomb(pPos,pVelo));
      cooldown=cooldownMax;
    }
  }
  @Override
  public void run(ArrayList<Particle> ps){
    //if(PCD>0){
    //  PCD--;
    //}
    
    velo.addVec(new Vector(cos(angle)*thrust,sin(angle)*thrust));
    thrust=0;
    if(thrustPotential<thrustPotLim){
      thrustPotential+=thrustRecover;
    }
    
    float speedEff=getEfficiency();
    
    velo.y+=gravity;
    velo.sclVec(resistanceMin+(resistanceMax-resistanceMin)*speedEff);
    
    pos.addVec(velo);
    
    float vSpeed=velo.getMag();
    float vAngle=velo.getAng();
    float dotP=cos(angle-vAngle);
    //println(vSpeed);
    
    if(dotP>=0){
      float eff=dotP*transfer*speedEff;
      velo.subVec(new Vector(cos(vAngle)*vSpeed*eff,sin(vAngle)*vSpeed*eff));
      velo.addVec(new Vector(cos(angle)*vSpeed*eff,sin(angle)*vSpeed*eff));
      
      if(turnRequest>0){
        angle+=agilityMin+(agilityMax-agilityMin)*speedEff;
      }else if(turnRequest<0){
        angle-=agilityMin+(agilityMax-agilityMin)*speedEff;
      }
    }else{
      velo.sclVec(fallResistance);
      if(turnRequest>0){
        angle+=agilityFall;
      }else if(turnRequest<0){
        angle-=agilityFall;
      }
    }
    
    /*if(turnRequest>0){
      angle+=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }else if(turnRequest<0){
      angle-=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }*/
    turnRequest=0;
    
    if(cooldown>0){
      cooldown--;
    }
    
    if(pos.y>waterline){
      velo.y-=0.5;
      velo.sclVec(0.97);
      if(sin(angle-vAngle)>=0){
        angle-=0.02;
      }else{
        angle+=0.02;
      }
    }
  }
}

class NyanCat extends Plane{
  NyanBullet[] lastShot;
  float frame;
  boolean clear;
  NyanCat(Vector p,float a){
    super(p,a);
    clear=true;
    thrustLimit=0.5;
    thrustRecover=0.5;
    thrustPotential=0.5;
    thrustPotLim=0.5;
    
    agilityMin=0.08;
    agilityMax=0.08;
    agilityFall=0.08;
    
    resistanceMin=0.9995;
    resistanceMax=0.99;
    fallResistance=0.9995;
    transfer=0;
    
    cooldown=0;
    cooldownMax=1;
    bulletSpeed=2;
    
    maxHealth=100;
    
    gravity=0.05;
    
    health=maxHealth;
    lastShot=new NyanBullet[6];
  }
  @Override
  public boolean hit(Bullet toHit,boolean exaggerate){
    if(overlaps(toHit.getPos())){
      health--;
      return true;
    }
    return false;
  }
  @Override
  public boolean overlaps(Vector target){
    {
      Vector toTest=new Vector(target);
      toTest.subVec(pos);
      toTest.rotVec(-angle);
      float hitboxX=(23)*3/2;
      float hitboxY=(21)*3/2;
      toTest.addVec(new Vector(hitboxX,hitboxY));
      float hitboxWide=23*3;
      float hitboxHigh=21*3;
      return toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh;
    }
  }
  @Override
  public void display(Cam c){
    float speed=1;
    Vector animateSpin=new Vector(frame*speed/TWO_PI,3,true);
    int tailF=(int)(frame*speed/10%5+1);
    PImage tail;
    if(tailF==1){
      tail=tail1;
    }else if(tailF==2){
      tail=tail2;
    }else if(tailF==3){
      tail=tail3;
    }else if(tailF==4){
      tail=tail4;
    }else{
      tail=tail5;
    }
    pushMatrix();
    if((int)(frame*speed/10%5+1)<4){
      translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y-3)*c.zoom);
    }else{
      translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom);
    }
    rotate(angle);
    scale(c.zoom,c.zoom);
    if(cos(angle)<0)
      scale(1.0, -1.0);
    
    image(tail,(-37)*3/2,(-6)*3/2,8*3,11*3);
    
    image(foot,(-16+20+animateSpin.x)*3/2,(15)*3/2,4*3,4*3);
    image(foot,(-16+29+animateSpin.x)*3/2,(15)*3/2,4*3,4*3);
    
    image(foot,(-16-3+animateSpin.x)*3/2,(15)*3/2,4*3,4*3);
    image(foot,(-16+6+animateSpin.x)*3/2,(15)*3/2,4*3,4*3);
    
    image(body,-21*3/2,-18*3/2,21*3,18*3);
    image(head,(-16+14+animateSpin.x)*3/2,(-8+animateSpin.y)*3/2,16*3,13*3);
    
    popMatrix();
    //stroke(0);
    //fill(255);
    //ellipse(pos.x-c.pos.x,pos.y-c.pos.y,10,10);
    //line(pos.x-c.pos.x,pos.y-c.pos.y,pos.x+cos(angle)*15-c.pos.x,pos.y+sin(angle)*15-c.pos.y);
  }@Override
  public void shoot(ArrayList<Bullet> bs){
    clear=false;
    if(cooldown==0){
      float s=bulletSpeed;
      
      //pVelo.addVec(velo);
      float rainbowWidth=6;
      int age=40;
      Vector pPos;
      Vector pVelo;
      float ra;
      float variation=0;
      float variationS=1;
      float rainbowAng=velo.getAng();
      
      ra=random(-variation,variation);
      pVelo=new Vector(angle+PI+ra,s*random(1,variationS),true);
      pPos=new Vector(rainbowAng+PI/2,-2*rainbowWidth,true);
      pPos.addVec(pos);
      bs.add(new NyanBullet(pPos,pVelo,age,color(255,100,100),lastShot[0]));
      lastShot[0]=(NyanBullet)bs.get(bs.size()-1);
      
      ra=random(-variation,variation);
      pVelo=new Vector(angle+PI+ra,s*random(1,variationS),true);
      pPos=new Vector(rainbowAng+PI/2,-rainbowWidth,true);
      pPos.addVec(pos);
      bs.add(new NyanBullet(pPos,pVelo,age,color(255,180,85),lastShot[1]));
      lastShot[1]=(NyanBullet)bs.get(bs.size()-1);
      
      ra=random(-variation,variation);
      pVelo=new Vector(angle+PI+ra,s*random(1,variationS),true);
      pPos=new Vector(rainbowAng+PI/2,0,true);
      pPos.addVec(pos);
      bs.add(new NyanBullet(pPos,pVelo,age,color(255,255,100),lastShot[2]));
      lastShot[2]=(NyanBullet)bs.get(bs.size()-1);
      
      ra=random(-variation,variation);
      pVelo=new Vector(angle+PI+ra,s*random(1,variationS),true);
      pPos=new Vector(rainbowAng+PI/2,rainbowWidth,true);
      pPos.addVec(pos);
      bs.add(new NyanBullet(pPos,pVelo,age,color(140,255,130),lastShot[3]));
      lastShot[3]=(NyanBullet)bs.get(bs.size()-1);
      
      ra=random(-variation,variation);
      pVelo=new Vector(angle+PI+ra,s*random(1,variationS),true);
      pPos=new Vector(rainbowAng+PI/2,2*rainbowWidth,true);
      pPos.addVec(pos);
      bs.add(new NyanBullet(pPos,pVelo,age,color(110,200,255),lastShot[4]));
      lastShot[4]=(NyanBullet)bs.get(bs.size()-1);
      
      ra=random(-variation,variation);
      pVelo=new Vector(angle+PI+ra,s*random(1,variationS),true);
      pPos=new Vector(rainbowAng+PI/2,3*rainbowWidth,true);
      pPos.addVec(pos);
      bs.add(new NyanBullet(pPos,pVelo,age,color(180,150,255),lastShot[5]));
      lastShot[5]=(NyanBullet)bs.get(bs.size()-1);
      cooldown=cooldownMax;
    }
  }
  @Override
  public void run(ArrayList<Particle> ps){
    frame+=1+velo.getMag()/15f;
    
    if(clear){
      lastShot=new NyanBullet[6];
    }else{
      clear=true;
    }
    //if(PCD>0){
    //  PCD--;
    //}
    
    velo.addVec(new Vector(cos(angle)*thrust,sin(angle)*thrust));
    thrust=0;
    if(thrustPotential<thrustPotLim){
      thrustPotential+=thrustRecover;
    }
    
    float speedEff=getEfficiency();
    
    velo.y+=gravity;
    velo.sclVec(resistanceMin+(resistanceMax-resistanceMin)*speedEff);
    
    pos.addVec(velo);
    
    float vSpeed=velo.getMag();
    float vAngle=velo.getAng();
    float dotP=cos(angle-vAngle);
    //println(vSpeed);
    
    if(dotP>=0){
      float eff=dotP*transfer*speedEff;
      velo.subVec(new Vector(cos(vAngle)*vSpeed*eff,sin(vAngle)*vSpeed*eff));
      velo.addVec(new Vector(cos(angle)*vSpeed*eff,sin(angle)*vSpeed*eff));
      
      if(turnRequest>0){
        angle+=agilityMin+(agilityMax-agilityMin)*speedEff;
      }else if(turnRequest<0){
        angle-=agilityMin+(agilityMax-agilityMin)*speedEff;
      }
    }else{
      velo.sclVec(fallResistance);
      if(turnRequest>0){
        angle+=agilityFall;
      }else if(turnRequest<0){
        angle-=agilityFall;
      }
    }
    
    /*if(turnRequest>0){
      angle+=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }else if(turnRequest<0){
      angle-=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }*/
    turnRequest=0;
    
    if(cooldown>0){
      cooldown--;
    }
    
    if(pos.y>waterline){
      velo.y-=0.5;
      velo.sclVec(0.97);
      if(sin(angle-vAngle)>=0){
        angle-=0.02;
      }else{
        angle+=0.02;
      }
    }
  }
}


class Dragon extends Plane{
  ArrayList<DragonSegment> body;
  int sements=20;
  Dragon(Vector p,float a){
    super(p,a);
    
    thrustLimit=1;
    thrustRecover=0.5;
    thrustPotential=15;
    thrustPotLim=15;
    
    agilityMin=0.1;
    agilityMax=0.1;
    agilityFall=0.1;
    
    resistanceMin=0.98;
    resistanceMax=0.98;
    fallResistance=0.98;
    transfer=1;
    
    cooldown=0;
    cooldownMax=2;
    bulletSpeed=20;
    
    minSpeed=5;//min speed for lift
    maxSpeed=40;//speed for max efficiency
    
    maxHealth=1000;
    health=maxHealth;
    
    gravity=0.1;
    
    body=new ArrayList<DragonSegment>();
    for(int i=0;i<sements;i++){
      body.add(new DragonSegment(pos));
    }
  }
  @Override
  public boolean hit(Bullet toHit,boolean exaggerate){
    if(overlaps(toHit.getPos())){
      health--;
      return true;
    }
    return false;
  }
  @Override
  public boolean overlaps(Vector target){
    Vector toTest=new Vector(target);
    toTest.subVec(pos);
    toTest.rotVec(-angle);
    float hitboxX=-(-84+30+40)*1.5;
    float hitboxY=(54-12)*1.5/2;
    toTest.addVec(new Vector(hitboxX,hitboxY));
    float hitboxWide=50*1.5;
    float hitboxHigh=40*1.5;
    if(toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh){
      return true;
    }
    for(int i=0;i<body.size();i++){
      if(body.get(i).overlaps(target)){
        return true;
      }
    }
    return false;
  }
  @Override
  public void shoot(ArrayList<Bullet> bs){
    if(cooldown==0){
      float ra=random(-0.5,0.5);
      float s=-random(5,bulletSpeed);
      Vector pVelo=new Vector(cos(angle+PI+ra)*s,sin(angle+PI+ra)*s);
      pVelo.addVec(velo);
      Vector pPos=new Vector(cos(angle)*88*1.5/3*2,sin(angle)*88*1.5/3*2);
      pPos.addVec(pos);
      bs.add(new Bullet(pPos,pVelo,(int)random(5,15)));
      cooldown=cooldownMax;
    }
  }
  @Override
  public void run(ArrayList<Particle> ps){
    //if(PCD>0){
    //  PCD--;
    //}
    
    velo.addVec(new Vector(cos(angle)*thrust,sin(angle)*thrust));
    thrust=0;
    if(thrustPotential<thrustPotLim){
      thrustPotential+=thrustRecover;
    }
    
    float speedEff=getEfficiency();
    
    velo.y+=gravity;
    velo.sclVec(resistanceMin+(resistanceMax-resistanceMin)*speedEff);
    
    pos.addVec(velo);
    
    float vSpeed=velo.getMag();
    float vAngle=velo.getAng();
    float dotP=cos(angle-vAngle);
    //println(vSpeed);
    
    if(dotP>=0){
      float eff=dotP*transfer*speedEff;
      velo.subVec(new Vector(cos(vAngle)*vSpeed*eff,sin(vAngle)*vSpeed*eff));
      velo.addVec(new Vector(cos(angle)*vSpeed*eff,sin(angle)*vSpeed*eff));
      
      if(turnRequest>0){
        angle+=agilityMin+(agilityMax-agilityMin)*speedEff;
      }else if(turnRequest<0){
        angle-=agilityMin+(agilityMax-agilityMin)*speedEff;
      }
    }else{
      velo.sclVec(fallResistance);
      if(turnRequest>0){
        angle+=agilityFall;
      }else if(turnRequest<0){
        angle-=agilityFall;
      }
    }
    
    /*if(turnRequest>0){
      angle+=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }else if(turnRequest<0){
      angle-=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }*/
    turnRequest=0;
    
    if(cooldown>0){
      cooldown--;
    }
    
    if(pos.y>waterline){
      velo.y-=0.5;
      velo.sclVec(0.97);
      if(sin(angle-vAngle)>=0){
        angle-=0.02;
      }else{
        angle+=0.02;
      }
    }
    Vector lastPos=new Vector(pos);
    for(int i=0;i<body.size();i++){
      Vector toSet=body.get(i).getPos();
      toSet.subVec(lastPos);
      float segAng=toSet.getAng();
      toSet.nrmVec(32);
      toSet.addVec(lastPos);
      lastPos=toSet;
      body.get(i).setPos(toSet);
      body.get(i).setAngle(segAng);
    }
  }
  @Override
  public void display(Cam c){
    for(int i=0;i<body.size();i++){
      body.get(i).display(c,i==body.size()-1);
    }
    pushMatrix();
    translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom);
    rotate(angle);
    scale(c.zoom,c.zoom);
    if(cos(angle)<0)
      scale(1.0, -1.0);
    image(dragonHead,(-84+30)*1.5,-(54+12)*1.5/2,84*1.5,54*1.5);
    popMatrix();
    //stroke(0);
    //fill(255);
    //ellipse(pos.x-c.pos.x,pos.y-c.pos.y,10,10);
    //line(pos.x-c.pos.x,pos.y-c.pos.y,pos.x+cos(angle)*15-c.pos.x,pos.y+sin(angle)*15-c.pos.y);
  }
}
class DragonSegment{
  Vector pos;
  float angle;
  DragonSegment(Vector p){
    pos=new Vector(p);
  }
  public boolean overlaps(Vector target){
    Vector toTest=new Vector(target);
    toTest.subVec(pos);
    toTest.rotVec(-angle);
    float hitboxX=20*1.5;
    float hitboxY=30*1.5/2;
    toTest.addVec(new Vector(hitboxX,hitboxY));
    float hitboxWide=20*1.5;
    float hitboxHigh=30*1.5;
    return toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh;
  }
  void setPos(Vector toSet){
    pos=new Vector(toSet);
  }
  Vector getPos(){
    return new Vector(pos);
  }
  void setAngle(float toSet){
    angle=toSet;
  }
  void display(Cam c,boolean tail){
    PImage img;
    if(tail){
      img=dragonTail;
    }else{
      img=dragonBody;
    }
    pushMatrix();
    translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom);
    rotate(angle);
    scale(c.zoom,c.zoom);
    //if(cos(angle)<0)
    //  scale(1.0, -1.0);
    fill(0,0,0);
    noStroke();
    ellipse(0,0,10,10);
    image(img,-26*1.5/3,-21*1.5/2,26*1.5,21*1.5);
    popMatrix();
  }
  
}
class Balloon extends Plane{
  Basket basket;
  float tipAng;
  float knockback;
  float kickback;
  float floor;
  
  Balloon(Vector p,float a){
    super(p,a);
    thrustLimit=1;
    thrustRecover=1;
    thrustPotential=0;
    thrustPotLim=1;
    
    agilityMin=0.1;
    agilityMax=0.1;
    agilityFall=0.1;
    
    resistanceMin=0.98;
    resistanceMax=0.98;
    fallResistance=0.98;
    transfer=0;
    
    cooldown=0;
    cooldownMax=5;
    bulletSpeed=50;
    
    minSpeed=5;//min speed for lift
    maxSpeed=40;//speed for max efficiency
    
    maxHealth=18;
    health=maxHealth;
    
    gravity=0.05;
    
    knockback=4;
    kickback=2;
    floor=600;
    tipAng=0;
    basket=new Basket(attachPos());
    
  }
  Vector attachPos(){
    Vector attach=new Vector(pos);
    Vector offset=new Vector(0,80);
    offset.rotVec(tipAng);
    attach.addVec(offset);
    return attach;
  }
  Vector basketPos(){
    return basket.getPos();
  }
  Vector shootPos(){
    return basket.getShootPos();
  }
  public void run(ArrayList<Particle> ps){
    tipAng*=0.95;
    basket.move(attachPos(),velo);
    //if(PCD>0){
    //  PCD--;
    //}
    
    //provide buoyancy if it goes too low
    if(pos.y>waterline-floor){
      velo.y*=0.9;
      velo.y-=0.3;
    }
    
    if(-pos.y>ceilingStart){
      velo.y*=0.9;
      velo.y+=0.3;
    }
    
    //velo.addVec(new Vector(0,-thrust));
    thrust=0;
    if(thrustPotential<thrustPotLim){
      thrustPotential+=thrustRecover;
    }
    
    float speedEff=getEfficiency();
    
    velo.y+=gravity;
    velo.sclVec(resistanceMin+(resistanceMax-resistanceMin)*speedEff);
    
    pos.addVec(velo);
    
    float vSpeed=velo.getMag();
    float vAngle=velo.getAng();
    float dotP=cos(angle-vAngle);
    //println(vSpeed);
    
    if(dotP>=0){
      float eff=dotP*transfer*speedEff;
      velo.subVec(new Vector(cos(vAngle)*vSpeed*eff,sin(vAngle)*vSpeed*eff));
      velo.addVec(new Vector(cos(angle)*vSpeed*eff,sin(angle)*vSpeed*eff));
      
      if(turnRequest>0){
        angle+=agilityMin+(agilityMax-agilityMin)*speedEff;
      }else if(turnRequest<0){
        angle-=agilityMin+(agilityMax-agilityMin)*speedEff;
      }
    }else{
      velo.sclVec(fallResistance);
      if(turnRequest>0){
        angle+=agilityFall;
      }else if(turnRequest<0){
        angle-=agilityFall;
      }
    }
    
    /*if(turnRequest>0){
      angle+=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }else if(turnRequest<0){
      angle-=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }*/
    turnRequest=0;
    
    if(cooldown>0){
      cooldown--;
    }
    
    if(pos.y>waterline){
      velo.y-=0.5;
      velo.sclVec(0.97);
      if(sin(angle-vAngle)>=0){
        angle-=0.02;
      }else{
        angle+=0.02;
      }
    }
    Vector lastPos=new Vector(pos);
  }
  
  @Override
  public boolean hit(Bullet toHit,boolean exaggerate){
    if(overlaps(toHit.getPos())){
      Vector hitPos=toHit.getPos();
      hitPos.subVec(pos);
      hitPos.nrmVec(knockback);
      if(hitPos.x>0){
        tipAng-=0.1;
      }else{
        tipAng+=0.1;
      }
      velo.subVec(hitPos);
      return true;
    }
    //if not hitting envelope then try hitting the basket
    if(basket.overlaps(toHit.getPos())){
      health--;
      return true;
    }
    return false;
  }
  @Override
  public boolean overlaps(Vector target){
    Vector toTest=new Vector(target);
    toTest.subVec(pos);
    toTest.rotVec(-tipAng);
    float hitboxX=(100)*1.5/2;
    float hitboxY=(148+50)*1.5/2;
    toTest.addVec(new Vector(hitboxX,hitboxY));
    float hitboxWide=100*1.5;
    float hitboxHigh=120*1.5;
    if(toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh){
      return true;
    }
    return false;
  }
  @Override
  public void shoot(ArrayList<Bullet> bs){
    if(cooldown==0){
      float ra=random(-0.01,0.01);
      float s=-bulletSpeed;
      Vector pVelo=new Vector(cos(angle+PI+ra)*s,sin(angle+PI+ra)*s);
      pVelo.addVec(velo);
      Vector pPos=shootPos();
      bs.add(new Bullet(pPos,pVelo,100));
      cooldown=cooldownMax;
      
      Vector accel=new Vector(angle+PI,kickback,true);
      if(accel.x>0){
        tipAng-=0.05;
      }else{
        tipAng+=0.05;
      }
      velo.addVec(accel);
      accel.sclVec(3);
      basket.push(accel);
    }
  }
  @Override
  public void display(Cam c){
    basket.display(c,angle);
    pushMatrix();
    translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom);
    rotate(tipAng);
    scale(c.zoom,c.zoom);
    image(envelope,(-130)*1.5/2,(-148-70)*1.5/2,130*1.5,148*1.5);
    popMatrix();
    //stroke(0);
    //fill(255);
    //ellipse(pos.x-c.pos.x,pos.y-c.pos.y,10,10);
    //line(pos.x-c.pos.x,pos.y-c.pos.y,pos.x+cos(angle)*15-c.pos.x,pos.y+sin(angle)*15-c.pos.y);
  }
}
class Basket{
  Vector pos;
  Vector velo;
  Basket(Vector p){
    pos=new Vector(p);
    velo=new Vector(0,0);
  }
  void move(Vector attractor,Vector balloonVelo){
    
    Vector accel=new Vector(attractor);
    accel.subVec(pos);
    accel.sclVec(0.05);
    
    velo.addVec(accel);
    velo.subVec(balloonVelo);
    velo.sclVec(0.9);
    velo.addVec(balloonVelo);
    pos.addVec(velo);
    
  }
  public void push(Vector push){
    pos.addVec(push);
  }
  public boolean overlaps(Vector target){
    Vector toTest=new Vector(target);
    toTest.subVec(pos);
    float hitboxX=(18)*1.5/2;
    float hitboxY=(10)*1.5/2;
    toTest.addVec(new Vector(hitboxX,hitboxY));
    float hitboxWide=18*1.5;
    float hitboxHigh=18*1.5;
    if(toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh){
      return true;
    }
    return false;
  }
  public Vector getPos(){
    return new Vector(pos);
  }
  public Vector getShootPos(){
    Vector shoot=new Vector(pos);
    shoot.addVec(new Vector(0,12));
    return shoot;
  }
  public void display(Cam c,float angle){
    Vector shootPos=getShootPos();
    pushMatrix();
    translate((shootPos.x-c.pos.x)*c.zoom,(shootPos.y-c.pos.y)*c.zoom);
    rotate(angle);
    scale(c.zoom,c.zoom);
    image(gunBarrel,(0)*1.5/2,(-6)*1.5/2,16*1.5,6*1.5);
    popMatrix();
    
    pushMatrix();
    translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom);
    //rotate(angle);
    scale(c.zoom,c.zoom);
    image(basket,(-20)*1.5/2,(-32)*1.5/2,20*1.5,32*1.5);
    popMatrix();
    //stroke(0);
    //fill(255);
    //ellipse(pos.x-c.pos.x,pos.y-c.pos.y,10,10);
    //line(pos.x-c.pos.x,pos.y-c.pos.y,pos.x+cos(angle)*15-c.pos.x,pos.y+sin(angle)*15-c.pos.y);
  }
}

class Triebflugel extends Plane{
  float time;
  Triebflugel(Vector p,float a){
    super(p,a);
    
     //player
    thrustLimit=1;
    thrustRecover=0.12;
    thrustPotential=4;
    thrustPotLim=4;
    
    agilityMin=0.04;
    agilityMax=0.06;
    agilityFall=0.03;
    
    resistanceMin=0.9999;
    resistanceMax=0.998;
    fallResistance=0.9999;
    transfer=0.2;
    
    cooldown=0;
    cooldownMax=50;
    bulletSpeed=50;
    
    minSpeed=20;//min speed for lift
    maxSpeed=60;//speed for max efficiency
    
    maxHealth=40;
    
    gravity=0.1;
    
    health=maxHealth;
  }@Override
  public boolean hit(Bullet toHit,boolean exaggerate){
    if(overlaps(toHit.getPos())){
      health--;
      return true;
    }
    return false;
  }
  @Override
  public boolean overlaps(Vector target){
    {
      Vector toTest=new Vector(target);
      toTest.subVec(pos);
      toTest.rotVec(-angle);
      if(cos(angle)<0)
        toTest.y*=-1;
      float hitboxX=(89)*1.5/2;
      float hitboxY=(25)*1.5/2;
      toTest.addVec(new Vector(hitboxX,hitboxY));
      float hitboxWide=89*1.5;
      float hitboxHigh=25*1.5;
      if(toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh){
        return true;
      }
    }
    return false;
  }
  @Override
  public void run(ArrayList<Particle> ps){
    //println(velo.getMag());
    time+=min(0.05+velo.getMag()/200,1);
    //println(thrust);
    
    float t=thrust*5;
    if(t>0&&t<1){
      t+=random(0,1);
    }
    //if(PCD>0){
    //  PCD--;
    //}
    
    float outerRing=35;
    float pSpeed=2;
    for(int c=0;c<t;c++){
      for(int i=0;i<3;i++){
        float propAng=time+i*TWO_PI/3;
        float propSin=sin(propAng);
          float ra=0;
          float rs=random(-2,2);
          Vector pVelo=new Vector(cos(angle+PI+ra)*(pSpeed+rs),sin(angle+PI+ra)*(pSpeed+rs));
          float end=propSin*outerRing;
          Vector pPos=new Vector(10*1.5/3,end*1.5);
          if(cos(angle)<0)
            pPos.y*=-1;
          pPos.rotVec(angle);
          pPos.addVec(pos);
          ps.add(new Particle(pPos,pVelo,100,10));
      }
    }
    
    velo.addVec(new Vector(cos(angle)*thrust,sin(angle)*thrust));
    thrust=0;
    if(thrustPotential<thrustPotLim){
      thrustPotential+=thrustRecover;
    }
    
    float speedEff=getEfficiency();
    
    velo.y+=gravity;
    velo.sclVec(resistanceMin+(resistanceMax-resistanceMin)*speedEff);
    
    pos.addVec(velo);
    
    float vSpeed=velo.getMag();
    float vAngle=velo.getAng();
    float dotP=cos(angle-vAngle);
    //println(vSpeed);
    
    if(dotP>=0){
      float eff=dotP*transfer*speedEff;
      velo.subVec(new Vector(cos(vAngle)*vSpeed*eff,sin(vAngle)*vSpeed*eff));
      velo.addVec(new Vector(cos(angle)*vSpeed*eff,sin(angle)*vSpeed*eff));
      
      if(turnRequest>0){
        angle+=agilityMin+(agilityMax-agilityMin)*speedEff;
      }else if(turnRequest<0){
        angle-=agilityMin+(agilityMax-agilityMin)*speedEff;
      }
    }else{
      velo.sclVec(fallResistance);
      if(turnRequest>0){
        angle+=agilityFall;
      }else if(turnRequest<0){
        angle-=agilityFall;
      }
    }
    
    /*if(turnRequest>0){
      angle+=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }else if(turnRequest<0){
      angle-=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }*/
    turnRequest=0;
    
    if(cooldown>0){
      float speedBonus=velo.getMag()/5;
      if(speedBonus<2){
        speedBonus+=random(0,1);
      }
      cooldown=max(cooldown-1-(int)speedBonus,0);
    }
    
    if(pos.y>waterline){
      velo.y-=0.5;
      velo.sclVec(0.97);
      if(sin(angle-vAngle)>=0){
        angle-=0.02;
      }else{
        angle+=0.02;
      }
    }
  }
  @Override
  public void shoot(ArrayList<Bullet> bs){
    if(cooldown==0){
      float outerRing=35;
      for(int i=0;i<3;i++){
        float propAng=time+i*TWO_PI/3;
        float propSin=sin(propAng);
        float ra=0;
        float s=bulletSpeed;
        Vector pVelo=new Vector(cos(angle+ra)*(s),sin(angle+ra)*(s));
        pVelo.addVec(velo);
        float end=propSin*outerRing;
        Vector pPos=new Vector(10*1.5/3,end*1.5);
        if(cos(angle)<0)
          pPos.y*=-1;
        pPos.rotVec(angle);
        pPos.addVec(pos);
        bs.add(new Bullet(pPos,pVelo,(int)random(15,20)));
      }
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
      
    float innerRing=10;
    float outerRing=35;
    for(int i=0;i<3;i++){
      float propAng=time+i*TWO_PI/3;
      float propCos=cos(propAng);
      float propSin=sin(propAng);
      if(propCos>0){
        float start=propSin*innerRing;
        float end=propSin*outerRing;
        float size=end-start;
        if(propCos>0.95){
          image(triebJet1,1*1.5,(end-15/2)*1.5,15*1.5,(12)*1.5);
        }else{
          if(propSin<0){
            image(triebJet2,1*1.5,(end-15/2)*1.5,15*1.5,(12)*1.5);
          }else{
            image(triebJet3,1*1.5,(end-15/2)*1.5,15*1.5,(12)*1.5);
          }
        }
        image(triebProp,1*1.5,start*1.5,15*1.5,(size)*1.5);
      }
    }
    image(trieb,-45*1.5,-81*1.5/2,89*1.5,81*1.5);
    for(int i=0;i<3;i++){
      float propAng=time+i*TWO_PI/3;
      float propCos=cos(propAng);
      float propSin=sin(propAng);
      if(propCos<=0){
        float start=propSin*innerRing;
        float end=propSin*outerRing;
        float size=end-start;
        image(triebProp,1*1.5,start*1.5,15*1.5,(size)*1.5);
        if(propCos<-0.95){
          image(triebJet1,1*1.5,(end-15/2)*1.5,15*1.5,(12)*1.5);
        }else{
          if(propSin<0){
            image(triebJet2,1*1.5,(end-15/2)*1.5,15*1.5,(12)*1.5);
          }else{
            image(triebJet3,1*1.5,(end-15/2)*1.5,15*1.5,(12)*1.5);
          }
        }
      }
    }
    
    popMatrix();
    //stroke(0);
    //fill(255);
    //ellipse(pos.x-c.pos.x,pos.y-c.pos.y,10,10);
    //line(pos.x-c.pos.x,pos.y-c.pos.y,pos.x+cos(angle)*15-c.pos.x,pos.y+sin(angle)*15-c.pos.y);
  }
}
class FlyingFortress extends Plane{
  float time;
  float gunAng;
  float gunSpin;
  FlyingFortress(Vector p,float a){
    super(p,a);
    
     //player
    thrustLimit=1;
    thrustRecover=0.25;
    thrustPotential=10;
    thrustPotLim=10;
    
    agilityMin=0.02;
    agilityMax=0.03;
    agilityFall=0.03;
    
    cooldown=0;
    cooldownMax=10;
    bulletSpeed=50;
    
    resistanceMin=0.995;
    resistanceMax=0.99;
    fallResistance=0.995;
    transfer=0.15;
    
    minSpeed=5;//min speed for lift
    maxSpeed=20;//speed for max efficiency
    
    maxHealth=50;
    
    gravity=0.2;
    
    health=maxHealth;
  }
 @Override
  public boolean hit(Bullet toHit,boolean exaggerate){
    if(overlaps(toHit.getPos())){
      health--;
      return true;
    }
    return false;
  }
  @Override
  public boolean overlaps(Vector target){
    {
      Vector toTest=new Vector(target);
      toTest.subVec(pos);
      toTest.rotVec(-angle);
      if(cos(angle)<0)
        toTest.y*=-1;
      float hitboxX=(78)*1.5;
      float hitboxY=(60)*1.5/2;
      toTest.addVec(new Vector(hitboxX,hitboxY));
      float hitboxWide=20*1.5;
      float hitboxHigh=40*1.5;
      if(toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh){
        return true;
      }
    }
    {
      Vector toTest=new Vector(target);
      toTest.subVec(pos);
      toTest.rotVec(-angle);
      if(cos(angle)<0)
        toTest.y*=-1;
      float hitboxX=(78)*1.5;
      float hitboxY=(40)*1.5/2;
      toTest.addVec(new Vector(hitboxX,hitboxY));
      float hitboxWide=155*1.5;
      float hitboxHigh=30*1.5;
      if(toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh){
        return true;
      }
    }
    {
      Vector toTest=new Vector(target);
      toTest.subVec(pos);
      toTest.rotVec(-angle);
      if(cos(angle)<0)
        toTest.y*=-1;
      float hitboxX=(10)*1.5;
      float hitboxY=(40)*1.5/2;
      toTest.addVec(new Vector(hitboxX,hitboxY));
      float hitboxWide=35*1.5;
      float hitboxHigh=50*1.5;
      if(toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh){
        return true;
      }
    }
    return false;
  }
  @Override
  public void run(ArrayList<Particle> ps){
    if(time%50==0){
      if(random(0,1)<0.5){
        gunSpin=-0.02;
      }else{
        gunSpin=0.02;
      }
    }
    //println(velo.getMag());
    time+=1;
    //println(thrust);
    
    float t=thrust*5;
    if(t>0&&t<1){
      t+=random(0,1);
    }
    //if(PCD>0){
    //  PCD--;
    //}
    
    velo.addVec(new Vector(cos(angle)*thrust,sin(angle)*thrust));
    thrust=0;
    if(thrustPotential<thrustPotLim){
      thrustPotential+=thrustRecover;
    }
    
    float speedEff=getEfficiency();
    
    velo.y+=gravity;
    velo.sclVec(resistanceMin+(resistanceMax-resistanceMin)*speedEff);
    
    pos.addVec(velo);
    
    float vSpeed=velo.getMag();
    float vAngle=velo.getAng();
    float dotP=cos(angle-vAngle);
    //println(vSpeed);
    
    if(dotP>=0){
      float eff=dotP*transfer*speedEff;
      velo.subVec(new Vector(cos(vAngle)*vSpeed*eff,sin(vAngle)*vSpeed*eff));
      velo.addVec(new Vector(cos(angle)*vSpeed*eff,sin(angle)*vSpeed*eff));
      
      if(turnRequest>0){
        angle+=agilityMin+(agilityMax-agilityMin)*speedEff;
      }else if(turnRequest<0){
        angle-=agilityMin+(agilityMax-agilityMin)*speedEff;
      }
    }else{
      velo.sclVec(fallResistance);
      if(turnRequest>0){
        angle+=agilityFall;
      }else if(turnRequest<0){
        angle-=agilityFall;
      }
    }
    
    /*if(turnRequest>0){
      angle+=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }else if(turnRequest<0){
      angle-=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }*/
    turnRequest=0;
    
    if(cooldown>0){
      cooldown--;
    }
    
    if(pos.y>waterline){
      velo.y-=0.5;
      velo.sclVec(0.97);
      if(sin(angle-vAngle)>=0){
        angle-=0.02;
      }else{
        angle+=0.02;
      }
    }
  }
  @Override
  public void shoot(ArrayList<Bullet> bs){
    gunAng=min(max(gunAng+gunSpin,0),PI);
    if(time%50>35){
      if(time%4==0){
        float ra=random(-0.01,0.01);
        float s=-bulletSpeed;
        Vector pVelo=new Vector(cos(gunAng+ra)*s,sin(gunAng+ra)*s);
        Vector pPos=new Vector(25*1.5,-20*1.5);
        if(cos(angle)<0){
          pPos.y*=-1;
          pVelo.y*=-1;
        }
        pVelo.rotVec(angle);
        pVelo.addVec(velo);
        pPos.rotVec(angle);
        pPos.addVec(pos);
        bs.add(new Bullet(pPos,pVelo,50));
      }
    }
    
    if(cooldown==0){
      float ra=random(-0.01,0.01);
      float s=-bulletSpeed;
      Vector pVelo1=new Vector(cos(angle+PI+ra)*s,sin(angle+PI+ra)*s);
      Vector pVelo2=new Vector(cos(angle+ra)*s,sin(angle+ra)*s);
      pVelo1.addVec(velo);
      pVelo2.addVec(velo);
      Vector pPos1=new Vector(cos(angle)*88*1.5/3*2,sin(angle)*88*1.5/3*2);
      Vector pPos2=new Vector(25*1.5,-20*1.5);
      if(cos(angle)<0){
        pPos2.y*=-1;
      }
      pPos2.rotVec(angle);
      pPos1.addVec(pos);
      pPos2.addVec(pos);
      bs.add(new Bullet(pPos1,pVelo1,50));
      bs.add(new Bullet(pPos2,pVelo2,50));
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
      
    image(fortress,-155*1.5/2,-63*1.5/2,155*1.5,63*1.5);
    if((int)time%6<3){
      image(fortressPropF1,(39-10)*1.5,-4*1.5,4*1.5,17*1.5);
      image(fortressPropF1,(32-10)*1.5,3*1.5,4*1.5,17*1.5);
    }else{
      image(fortressPropF2,(39-10)*1.5,-4*1.5,4*1.5,17*1.5);
      image(fortressPropF2,(32-10)*1.5,3*1.5,4*1.5,17*1.5);
    }
    
    translate(25*1.5,-20*1.5);
    rotate(gunAng+PI);
    image(fortressGun,0,-1*1.5,13*1.5,2*1.5);
    
    popMatrix();
    //stroke(0);
    //fill(255);
    //ellipse(pos.x-c.pos.x,pos.y-c.pos.y,10,10);
    //line(pos.x-c.pos.x,pos.y-c.pos.y,pos.x+cos(angle)*15-c.pos.x,pos.y+sin(angle)*15-c.pos.y);
  }
}

class PodRacer extends Plane{
  Thruster thruster1;
  Thruster thruster2;
  Rope rope1;
  Rope rope2;
  float podDist;
  float podResist;
  ArrayList<LightningBullet> boltRender;
  PodRacer(Vector p,float a){
    super(p,a);
    
     //player
    thrustLimit=1;
    thrustRecover=0.6;
    thrustPotential=10;
    thrustPotLim=10;
    
    agilityMin=0.05;
    agilityMax=0.05;
    agilityFall=0.05;
    
    cooldown=0;
    cooldownMax=1;
    bulletSpeed=50;
    
    resistanceMin=0.999;
    resistanceMax=0.995;
    fallResistance=0.999;
    transfer=0.15;
    
    minSpeed=5;//min speed for lift
    maxSpeed=20;//speed for max efficiency
    
    maxHealth=80;
    
    gravity=0.1;
    
    health=maxHealth;
    
    podDist=200;
    podResist=0.9999;
    thruster1=new Thruster(pos);
    thruster2=new Thruster(pos);
    rope1=new Rope(10,pos);
    rope2=new Rope(10,pos);
    boltRender=new ArrayList<LightningBullet>();
  }
 @Override
  public boolean hit(Bullet toHit,boolean exaggerate){
    if(overlaps(toHit.getPos())){
      health--;
      return true;
    }
    return false;
  }
  @Override
  public boolean overlaps(Vector target){
    {
      Vector toTest=new Vector(target);
      toTest.subVec(pos);
      toTest.rotVec(-angle);
      if(cos(angle)<0)
        toTest.y*=-1;
      float hitboxX=(46)*1.5/2;
      float hitboxY=(18)*1.5/2;
      toTest.addVec(new Vector(hitboxX,hitboxY));
      float hitboxWide=46*1.5;
      float hitboxHigh=18*1.5;
      if(toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh){
        return true;
      }
    }
    if(thruster1.overlaps(target))
      return true;
    if(thruster2.overlaps(target))
      return true;
    return false;
  }
  @Override
  public void run(ArrayList<Particle> ps){
    //println(velo.getMag());
    //println(thrust);
    
    float t=thrust*5;
    if(t>0&&t<1){
      t+=random(0,1);
    }
    //if(PCD>0){
    //  PCD--;
    //}
    
    float speedEff=getEfficiency();
    float resist=resistanceMin+(resistanceMax-resistanceMin)*speedEff;
    
    {
      Vector tDiff=new Vector(pos);
      tDiff.subVec(thruster1.getPos());
      float dist=tDiff.getMag();
      float ang=tDiff.getAng();
      dist-=podDist;
      if(dist>0){
        Vector force=new Vector(ang+PI,dist*0.1,true);
        velo.addVec(force);
        ang=force.getAng();
        Vector slow=new Vector(velo);
        slow.subVec(thruster1.getVelo());
        slow.rotVec(-ang);
        slow.x*=0.8;
        slow.y*=0.99;
        slow.rotVec(ang);
        slow.addVec(thruster1.getVelo());
        velo=slow;
        
      }
    }
    {
      Vector tDiff=new Vector(pos);
      tDiff.subVec(thruster2.getPos());
      float dist=tDiff.getMag();
      float ang=tDiff.getAng();
      dist-=podDist;
      if(dist>0){
        Vector force=new Vector(ang+PI,dist*0.1,true);
        velo.addVec(force);
        ang=force.getAng();
        Vector slow=new Vector(velo);
        slow.subVec(thruster1.getVelo());
        slow.rotVec(-ang);
        slow.x*=0.8;
        slow.rotVec(ang);
        slow.addVec(thruster1.getVelo());
        velo=slow;
        
      }
    }
    thruster1.run(thrust,resist,getPos(),getVelo(),podDist,gravity,ps);
    thruster2.run(thrust,resist,getPos(),getVelo(),podDist,gravity,ps);
    
    if(thrust==0){
      velo.y+=gravity;
    }
    
    thrust=0;
    if(thrustPotential<thrustPotLim){
      thrustPotential+=thrustRecover;
    }
    
    //velo.y+=gravity;
    velo.sclVec(podResist);
    pos.addVec(velo);
    
    float vSpeed=velo.getMag();
    float vAngle=velo.getAng();
    float dotP=cos(angle-vAngle);
    //println(vSpeed);
    
    if(turnRequest>0){
      angle+=agilityMin+(agilityMax-agilityMin)*speedEff;
    }else if(turnRequest<0){
      angle-=agilityMin+(agilityMax-agilityMin)*speedEff;
    }
    thruster1.setAng(angle);
    thruster2.setAng(angle);
    
    /*if(turnRequest>0){
      angle+=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }else if(turnRequest<0){
      angle-=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }*/
    turnRequest=0;
    
    if(cooldown>0){
      cooldown--;
    }
    
    if(pos.y>waterline){
      velo.y-=0.7;
      velo.sclVec(0.95);
      if(sin(angle-vAngle)>=0){
        angle-=0.02;
      }else{
        angle+=0.02;
      }
    }
    
    rope1.run(attachPos(),thruster1.getPos(),getVelo(),thruster1.getVelo());
    rope2.run(attachPos(),thruster2.getPos(),getVelo(),thruster2.getVelo());
  }
  Vector attachPos(){
    Vector attach=new Vector(10*1.5,4*1.5);
    if(cos(angle)<0)
      attach.y*=-1;
    attach.rotVec(angle);
    attach.addVec(pos);
    return attach;
  }
  @Override
  public void shoot(ArrayList<Bullet> bs){
    boltRender=new ArrayList<LightningBullet>();
    if(cooldown==0){
      Vector t1Pos=thruster1.getPos();
      Vector t2Pos=thruster2.getPos();
      ArrayList<Vector> bolt=new ArrayList<Vector>();
      bolt.add(t1Pos);
      bolt.add(t2Pos);
      
      for(int n=0;n<5;n++){
        ArrayList<Vector> nextBolt=new ArrayList<Vector>();
        //distort
        for(int i=1;i<bolt.size()-1;i++){
          float ang=bolt.get(i+1).getAng(bolt.get(i-1));
          float mag=bolt.get(i+1).getMag(bolt.get(i-1));
          mag*=0.1;
          ang+=PI/2;
          Vector distort=new Vector(ang,random(-mag,mag),true);
          bolt.get(i).addVec(distort);
        }
        //divide
        for(int i=1;i<bolt.size();i++){
          Vector split=new Vector(bolt.get(i));
          split.subVec(bolt.get(i-1));
          split.sclVec(0.5);
          split.addVec(bolt.get(i-1));
          nextBolt.add(bolt.get(i-1));
          nextBolt.add(split);
        }
        nextBolt.add(bolt.get(bolt.size()-1));
        bolt=nextBolt;
      }
      LightningBullet lastAdded=new LightningBullet(bolt.get(0),null);
      bs.add(lastAdded);
      boltRender.add(lastAdded);
      for(int i=1;i<bolt.size();i++){
        lastAdded=new LightningBullet(bolt.get(i),lastAdded);
        boltRender.add(lastAdded);
        bs.add(lastAdded);
      }
      
      Vector pPos=new Vector(cos(angle)*88*1.5/3*2,sin(angle)*88*1.5/3*2);
      pPos.addVec(pos);
      //bs.add(new Bullet(pPos,pVelo,50));
      cooldown=cooldownMax;
    }
  }
  @Override
  public void display(Cam c){
    rope1.display(c);
    thruster1.display(c,true);
    
    for(int i=0;i<boltRender.size();i++){
      boltRender.get(i).display(c);
    }
    pushMatrix();
    translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom);
    rotate(angle);
    scale(c.zoom,c.zoom);
    if(cos(angle)<0)
      scale(1.0, -1.0);
      
    image(pod,-46*1.5/2,-13*1.5/2,46*1.5,13*1.5);
    
    popMatrix();
    rope2.display(c);
    thruster2.display(c,false);
    //stroke(0);
    //fill(255);
    //ellipse(pos.x-c.pos.x,pos.y-c.pos.y,10,10);
    //line(pos.x-c.pos.x,pos.y-c.pos.y,pos.x+cos(angle)*15-c.pos.x,pos.y+sin(angle)*15-c.pos.y);
  }
}
class Rope{
  ArrayList<RopePoint> points;
  Rope(int count,Vector start){
    points=new ArrayList<RopePoint>();
    for(int i=0;i<count;i++){
      points.add(new RopePoint(start));
    }
  }
  void run(Vector start,Vector end,Vector startVelo,Vector endVelo){
    
    for(int t=0;t<1;t++){
      for(int i=1;i<points.size();i++){
        points.get(i).attract(points.get(i-1));
      }
      for(int i=0;i<points.size();i++){
        points.get(i).move();
      }
      
      points.get(0).setPoint(start,startVelo);
      points.get(points.size()-1).setPoint(end,endVelo);
    }
  }
  void display(Cam c){
    stroke(0);
    strokeWeight(4*c.zoom);
    for(int i=1;i<points.size();i++){
      //noFill();
      //ellipse((points.get(i-1).pos.x-c.pos.x)*c.zoom,(points.get(i-1).pos.y-c.pos.y)*c.zoom,4,4);
      line((points.get(i-1).pos.x-c.pos.x)*c.zoom,(points.get(i-1).pos.y-c.pos.y)*c.zoom,(points.get(i).pos.x-c.pos.x)*c.zoom,(points.get(i).pos.y-c.pos.y)*c.zoom);
    }
  }
}
class RopePoint{
  Vector pos;
  Vector last;
  RopePoint(Vector p){
    pos=new Vector(p);
    last=new Vector(pos);
    //last.x+=10;
  }
  void setPoint(Vector setPos,Vector setVelo){
    pos=new Vector(setPos);
    Vector toSet=new Vector(pos);
    toSet.subVec(setVelo);
    last=new Vector(toSet);
  }
  void attract(RopePoint target){
    Vector diff=new Vector(target.pos);
    diff.subVec(pos);
    float mag=diff.getMag();
    
    diff.sclVec((mag-12)/mag);
    diff.sclVec(0.5);
    if(mag>12){
      target.pos.subVec(diff);
      pos.addVec(diff);
    }
  }
  void move(){
    Vector diff=new Vector(pos);
    diff.subVec(last);
    //diff.sclVec(0.99);
    
    last=new Vector(pos);
    pos.addVec(diff);
    pos.addVec(new Vector(0,0.1));
  }
}
class Thruster{
  Vector pos;
  Vector velo;
  float angle;
  Thruster(Vector p){
    pos=new Vector(p);
    velo=new Vector(0,0);
  }
  public boolean overlaps(Vector target){
    {
      Vector toTest=new Vector(target);
      toTest.subVec(pos);
      toTest.rotVec(-angle);
      if(cos(angle)<0)
        toTest.y*=-1;
      float hitboxX=(84)*1.5/2;
      float hitboxY=(20)*1.5/2;
      toTest.addVec(new Vector(hitboxX,hitboxY));
      float hitboxWide=84*1.5;
      float hitboxHigh=20*1.5;
      if(toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh){
        return true;
      }
    }
    return false;
  }
  void run(float thrust,float resist,Vector tarPos,Vector tarVelo,float podDist,float gravity,ArrayList<Particle> ps){
    if(thrust==0){
      velo.y+=gravity;
    }
    
    if(random(0,1)<0.5){
      velo.addVec(new Vector(angle,thrust,true));
    }
    
    Vector tDiff=new Vector(pos);
    tDiff.subVec(tarPos);
    float dist=tDiff.getMag();
    float ang=tDiff.getAng();
    dist-=podDist;
    if(dist>0){
      Vector force=new Vector(ang+PI,dist*0.1,true);
      velo.addVec(force);
      ang=force.getAng();
      Vector slow=new Vector(velo);
      slow.subVec(tarVelo);
      slow.rotVec(-ang);
      slow.y*=0.9;
      slow.rotVec(ang);
      slow.addVec(tarVelo);
      velo=slow;
    }
    
    velo.sclVec(resist);
    
    pos.addVec(velo);
  }
  void setAng(float toSet){
    angle=toSet;
  }
  public Vector getPos(){
    return new Vector(pos);
  }
  public Vector getVelo(){
    return new Vector(velo);
  }
  public void display(Cam c,boolean flipped){
    pushMatrix();
    translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom);
    rotate(angle);
    scale(c.zoom,c.zoom);
    if(cos(angle)<0)
      scale(1.0, -1.0);
    
    if(flipped){
      image(podThruster1,-84*1.5/2,-20*1.5/2,84*1.5,20*1.5);
    }else{
      image(podThruster2,-84*1.5/2,-20*1.5/2,84*1.5,20*1.5);
    }
    
    popMatrix();
  }
}

class Biplane extends Plane{
  float time;
  Biplane(Vector p,float a){
    super(p,a);
    //bot
    thrustLimit=0.3;
    thrustRecover=0.3;
    thrustPotential=0.3;
    thrustPotLim=0.3;
    
    agilityMin=0.06;
    agilityMax=0.08;
    agilityFall=0.08;
    
    transfer=0.05;
    
    cooldown=0;
    cooldownMax=15;
    bulletSpeed=30;
    
    resistanceMin=0.999;
    resistanceMax=0.98;
    fallResistance=0.999;
    transfer=0.15;
    
    minSpeed=5;//min speed for lift
    maxSpeed=30;//speed for max efficiency
    
    gravity=0.1;
    
    health=25;
    maxHealth=health;
  }
  @Override
  public void run(ArrayList<Particle> ps){
    float t=thrust*2;
    time+=t;
    
    velo.addVec(new Vector(cos(angle)*thrust,sin(angle)*thrust));
    thrust=0;
    if(thrustPotential<thrustPotLim){
      thrustPotential+=thrustRecover;
    }
    
    float speedEff=getEfficiency();
    
    velo.y+=gravity;
    velo.sclVec(resistanceMin+(resistanceMax-resistanceMin)*speedEff);
    
    pos.addVec(velo);
    
    float vSpeed=velo.getMag();
    float vAngle=velo.getAng();
    float dotP=cos(angle-vAngle);
    //println(vSpeed);
    
    if(dotP>=0){
      float eff=dotP*transfer*speedEff;
      velo.subVec(new Vector(cos(vAngle)*vSpeed*eff,sin(vAngle)*vSpeed*eff));
      velo.addVec(new Vector(cos(angle)*vSpeed*eff,sin(angle)*vSpeed*eff));
      
      if(turnRequest>0){
        angle+=agilityMin+(agilityMax-agilityMin)*speedEff;
      }else if(turnRequest<0){
        angle-=agilityMin+(agilityMax-agilityMin)*speedEff;
      }
    }else{
      velo.sclVec(fallResistance);
      if(turnRequest>0){
        angle+=agilityFall;
      }else if(turnRequest<0){
        angle-=agilityFall;
      }
    }
    
    /*if(turnRequest>0){
      angle+=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }else if(turnRequest<0){
      angle-=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }*/
    turnRequest=0;
    
    if(cooldown>0){
      cooldown--;
    }
    
    if(pos.y>waterline){
      velo.y-=0.5;
      velo.sclVec(0.97);
      if(sin(angle-vAngle)>=0){
        angle-=0.02;
      }else{
        angle+=0.02;
      }
    }
  }
  @Override
  public boolean hit(Bullet toHit,boolean exaggerate){
    if(overlaps(toHit.getPos())){
      health--;
      return true;
    }
    return false;
  }
  @Override
  public boolean overlaps(Vector target){
    {
      Vector toTest=new Vector(target);
      toTest.subVec(pos);
      toTest.rotVec(-angle);
      float hitboxX=(75)*1.5/2;
      float hitboxY=(35)*1.5/2;
      toTest.addVec(new Vector(hitboxX,hitboxY));
      float hitboxWide=75*1.5;
      float hitboxHigh=35*1.5;
      return(toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh);
    }
  }
  @Override
  public void shoot(ArrayList<Bullet> bs){
    if(cooldown==0){
      float ra=random(-0.01,0.01);
      float s=-bulletSpeed;
      {
        Vector pVelo=new Vector(cos(angle+PI+ra)*s,sin(angle+PI+ra)*s);
        pVelo.addVec(velo);
        Vector pPos=new Vector(30*1.5,6*1.5);
        if(cos(angle)<0)
          pPos.y*=-1;
        pPos.rotVec(angle);
        pPos.addVec(pos);
        bs.add(new Bullet(pPos,pVelo,30));
      }
      {
        Vector pVelo=new Vector(cos(angle+PI+ra)*s,sin(angle+PI+ra)*s);
        pVelo.addVec(velo);
        Vector pPos=new Vector(30*1.5,-14*1.5);
        if(cos(angle)<0)
          pPos.y*=-1;
        pPos.rotVec(angle);
        pPos.addVec(pos);
        bs.add(new Bullet(pPos,pVelo,30));
      }
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
    image(biplane,-75*1.5/2,-35*1.5/2,75*1.5,35*1.5);
    if((int)time%4==0){
      image(biplanePropF1,34*1.5,-35*1.5/2,3*1.5,35*1.5);
    }else if((int)time%4==1){
      image(biplanePropF2,34*1.5,-35*1.5/2,3*1.5,35*1.5);
    }else if((int)time%4==2){
      image(biplanePropF3,34*1.5,-35*1.5/2,3*1.5,35*1.5);
    }else if((int)time%4==3){
      image(biplanePropF2,34*1.5,-35*1.5/2,3*1.5,35*1.5);
    }
    popMatrix();
    //stroke(0);
    //fill(255);
    //ellipse(pos.x-c.pos.x,pos.y-c.pos.y,10,10);
    //line(pos.x-c.pos.x,pos.y-c.pos.y,pos.x+cos(angle)*15-c.pos.x,pos.y+sin(angle)*15-c.pos.y);
  }
}
class WarPlane extends Plane{
  float time;
  WarPlane(Vector p,float a){
    super(p,a);
    //bot
    thrustLimit=0.8;
    thrustRecover=0.3;
    thrustPotential=15;
    thrustPotLim=15;
    
    agilityMin=0.04;
    agilityMax=0.05;
    agilityFall=0.05;
    
    transfer=0.05;
    
    cooldown=0;
    cooldownMax=6;
    bulletSpeed=30;
    
    resistanceMin=0.999;
    resistanceMax=0.98;
    fallResistance=0.999;
    transfer=0.15;
    
    minSpeed=10;//min speed for lift
    maxSpeed=35;//speed for max efficiency
    
    gravity=0.15;
    
    health=30;
    maxHealth=health;
  }
  @Override
  public void run(ArrayList<Particle> ps){
    float t=thrust*2;
    time+=t;
    
    velo.addVec(new Vector(cos(angle)*thrust,sin(angle)*thrust));
    thrust=0;
    if(thrustPotential<thrustPotLim){
      thrustPotential+=thrustRecover;
    }
    
    float speedEff=getEfficiency();
    
    velo.y+=gravity;
    velo.sclVec(resistanceMin+(resistanceMax-resistanceMin)*speedEff);
    
    pos.addVec(velo);
    
    float vSpeed=velo.getMag();
    float vAngle=velo.getAng();
    float dotP=cos(angle-vAngle);
    //println(vSpeed);
    
    if(dotP>=0){
      float eff=dotP*transfer*speedEff;
      velo.subVec(new Vector(cos(vAngle)*vSpeed*eff,sin(vAngle)*vSpeed*eff));
      velo.addVec(new Vector(cos(angle)*vSpeed*eff,sin(angle)*vSpeed*eff));
      
      if(turnRequest>0){
        angle+=agilityMin+(agilityMax-agilityMin)*speedEff;
      }else if(turnRequest<0){
        angle-=agilityMin+(agilityMax-agilityMin)*speedEff;
      }
    }else{
      velo.sclVec(fallResistance);
      if(turnRequest>0){
        angle+=agilityFall;
      }else if(turnRequest<0){
        angle-=agilityFall;
      }
    }
    
    /*if(turnRequest>0){
      angle+=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }else if(turnRequest<0){
      angle-=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }*/
    turnRequest=0;
    
    if(cooldown>0){
      cooldown--;
    }
    
    if(pos.y>waterline){
      velo.y-=0.5;
      velo.sclVec(0.97);
      if(sin(angle-vAngle)>=0){
        angle-=0.02;
      }else{
        angle+=0.02;
      }
    }
  }
  @Override
  public boolean hit(Bullet toHit,boolean exaggerate){
    if(overlaps(toHit.getPos())){
      health--;
      return true;
    }
    return false;
  }
  @Override
  public boolean overlaps(Vector target){
    {
      Vector toTest=new Vector(target);
      toTest.subVec(pos);
      toTest.rotVec(-angle);
      float hitboxX=(80)*1.5/2;
      float hitboxY=(35)*1.5/2;
      toTest.addVec(new Vector(hitboxX,hitboxY));
      float hitboxWide=80*1.5;
      float hitboxHigh=35*1.5;
      return(toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh);
    }
  }
  @Override
  public void shoot(ArrayList<Bullet> bs){
    if(cooldown==0){
      float ra=random(-0.01,0.01);
      float s=-bulletSpeed;
      {
        Vector pVelo=new Vector(cos(angle+PI+ra)*s,sin(angle+PI+ra)*s);
        pVelo.addVec(velo);
        Vector pPos=new Vector(30*1.5,0);
        if(cos(angle)<0)
          pPos.y*=-1;
        pPos.rotVec(angle);
        pPos.addVec(pos);
        bs.add(new Bullet(pPos,pVelo,40));
      }
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
    image(warPlane,-80*1.5/2,-35*1.5/2,80*1.5,35*1.5);
    if((int)time%4==0){
      image(warPlanePropF1,34*1.5,-35*1.5/2,6*1.5,35*1.5);
    }else if((int)time%4==1){
      image(warPlanePropF2,34*1.5,-35*1.5/2,6*1.5,35*1.5);
    }else if((int)time%4==2){
      image(warPlanePropF3,34*1.5,-35*1.5/2,6*1.5,35*1.5);
    }else if((int)time%4==3){
      image(warPlanePropF2,34*1.5,-35*1.5/2,6*1.5,35*1.5);
    }
    popMatrix();
    //stroke(0);
    //fill(255);
    //ellipse(pos.x-c.pos.x,pos.y-c.pos.y,10,10);
    //line(pos.x-c.pos.x,pos.y-c.pos.y,pos.x+cos(angle)*15-c.pos.x,pos.y+sin(angle)*15-c.pos.y);
  }
}

class Helicopter extends Plane{
  float time;
  Helicopter(Vector p,float a){
    super(p,a);
    //bot
    thrustLimit=0.8;
    thrustRecover=0.5;
    thrustPotential=15;
    thrustPotLim=15;
    
    agilityMin=0.04;
    agilityMax=0.04;
    agilityFall=0.05;
    
    transfer=0.05;
    
    cooldown=0;
    cooldownMax=8;
    bulletSpeed=30;
    
    resistanceMin=0.999;
    resistanceMax=0.98;
    fallResistance=0.999;
    transfer=0;
    
    minSpeed=10;//min speed for lift
    maxSpeed=35;//speed for max efficiency
    
    gravity=0.3;
    
    health=30;
    maxHealth=health;
  }
  @Override
  public void run(ArrayList<Particle> ps){
    float t=thrust*2;
    time+=t;
    
    velo.addVec(new Vector(cos(angle)*thrust,sin(angle)*thrust));
    thrust=0;
    if(thrustPotential<thrustPotLim){
      thrustPotential+=thrustRecover;
    }
    
    float speedEff=getEfficiency();
    
    velo.y+=gravity;
    velo.sclVec(resistanceMin+(resistanceMax-resistanceMin)*speedEff);
    
    pos.addVec(velo);
    
    float vSpeed=velo.getMag();
    float vAngle=velo.getAng();
    float dotP=cos(angle-vAngle);
    //println(vSpeed);
    
    if(dotP>=0){
      float eff=dotP*transfer*speedEff;
      velo.subVec(new Vector(cos(vAngle)*vSpeed*eff,sin(vAngle)*vSpeed*eff));
      velo.addVec(new Vector(cos(angle)*vSpeed*eff,sin(angle)*vSpeed*eff));
      
      if(turnRequest>0){
        angle+=agilityMin+(agilityMax-agilityMin)*speedEff;
      }else if(turnRequest<0){
        angle-=agilityMin+(agilityMax-agilityMin)*speedEff;
      }
    }else{
      velo.sclVec(fallResistance);
      if(turnRequest>0){
        angle+=agilityFall;
      }else if(turnRequest<0){
        angle-=agilityFall;
      }
    }
    
    /*if(turnRequest>0){
      angle+=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }else if(turnRequest<0){
      angle-=agilityMin+(1-min(dotP,0))*(agilityMax-agilityMin);
    }*/
    turnRequest=0;
    
    if(cooldown>0){
      cooldown--;
    }
    
    if(pos.y>waterline){
      velo.y-=1;
      velo.sclVec(0.94);
      if(sin(angle-vAngle)>=0){
        angle-=0.02;
      }else{
        angle+=0.02;
      }
    }
  }
  @Override
  public boolean hit(Bullet toHit,boolean exaggerate){
    if(overlaps(toHit.getPos())){
      health--;
      return true;
    }
    return false;
  }
  @Override
  public boolean overlaps(Vector target){
    {
      Vector toTest=new Vector(target);
      toTest.subVec(pos);
      toTest.rotVec(-angle);
      float hitboxX=(35)*1.5/2;
      float hitboxY=(70)*1.5/2;
      if(cos(angle)>0)
        toTest.y*=-1;
      toTest.addVec(new Vector(hitboxX,hitboxY));
      float hitboxWide=35*1.5;
      float hitboxHigh=104*1.5;
      return(toTest.x>0&&toTest.y>0&&toTest.x<hitboxWide&&toTest.y<hitboxHigh);
    }
  }
  @Override
  public void shoot(ArrayList<Bullet> bs){
    if(cooldown==0){
      float ra=random(-0.01,0.01);
      float s=-bulletSpeed;
      {
        Vector pVelo=new Vector(cos(angle+PI+ra)*s,sin(angle+PI+ra)*s);
        Vector pPos=new Vector(0,30*1.5);
        if(cos(angle)<0){
          pPos.y*=-1;
          pVelo.rotVec(-PI/2);
          pVelo.rotVec(0.3);
        }else{
          pVelo.rotVec(PI/2);
          pVelo.rotVec(-0.3);
        }
        pVelo.addVec(velo);
        pPos.rotVec(angle);
        pPos.addVec(pos);
        bs.add(new Bullet(pPos,pVelo,60));
      }
      cooldown=cooldownMax;
    }
  }
  @Override
  public void display(Cam c){
    float dispAng=nrm2Ang(angle+PI/2);
    pushMatrix();
    translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom);
    rotate(dispAng);
    scale(c.zoom,c.zoom);
    if(cos(angle)<0)
      scale(-1.0, 1.0);
    float propSize=cos(time*0.5)*85;
    image(heli,-70*1.5,-25*1.5/2,104*1.5,25*1.5);
    image(heliProp,(2-propSize/2)*1.5,-10*1.5,propSize*1.5,2*1.5);
    
    popMatrix();
    //stroke(0);
    //fill(255);
    //ellipse(pos.x-c.pos.x,pos.y-c.pos.y,10,10);
    //line(pos.x-c.pos.x,pos.y-c.pos.y,pos.x+cos(angle)*15-c.pos.x,pos.y+sin(angle)*15-c.pos.y);
  }
}
